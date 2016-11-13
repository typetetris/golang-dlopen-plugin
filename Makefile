WORK=/tmp/work
GOPATH=$(shell pwd)/go

hostapp: hostapp.c hostapp.h
	gcc -o $@ hostapp.c -ldl -Wl,--export-dynamic

envtest:
	echo $$GOPATH

simpleplugin: ${GOPATH}/src/simpleplugin/simpleplugin.go
	go install -buildmode=c-shared simpleplugin
	go build -buildmode=c-shared simpleplugin

plugin: ${GOPATH}/src/plugin/plugin.go hostapp.h
	rm -rf ${WORK}
	mkdir -p ${WORK}
	touch ${WORK}/trivial.c
	mkdir -p ${WORK}/plugin/_obj/
	mkdir -p ${WORK}/plugin/_obj/exe/
	cd ${GOPATH}/src/plugin; CGO_LDFLAGS="-g -O2" ${GOROOT}/pkg/tool/linux_amd64/cgo -objdir ${WORK}/plugin/_obj/ -importpath plugin -exportheader=${WORK}/plugin/_obj/_cgo_install.h -- -I ${WORK}/plugin/_obj/ plugin.go
	gcc -I . -fPIC -m64 -pthread -fmessage-length=0 -fdebug-prefix-map=${WORK}=/tmp/go-build -gno-record-gcc-switches -I ${WORK}/plugin/_obj/ -g -O2 -o ${WORK}/plugin/_obj/_cgo_main.o -c ${WORK}/plugin/_obj/_cgo_main.c
	gcc -I . -fPIC -m64 -pthread -fmessage-length=0 -fdebug-prefix-map=${WORK}=/tmp/go-build -gno-record-gcc-switches -I ${WORK}/plugin/_obj/ -g -O2 -o ${WORK}/plugin/_obj/_cgo_export.o -c ${WORK}/plugin/_obj/_cgo_export.c
	gcc -I . -fPIC -m64 -pthread -fmessage-length=0 -fdebug-prefix-map=${WORK}=/tmp/go-build -gno-record-gcc-switches -I ${WORK}/plugin/_obj/ -g -O2 -o ${WORK}/plugin/_obj/plugin.cgo2.o -c ${WORK}/plugin/_obj/plugin.cgo2.c
	gcc -I . -fPIC -m64 -pthread -fmessage-length=0 -fdebug-prefix-map=${WORK}=/tmp/go-build -gno-record-gcc-switches -o ${WORK}/plugin/_obj/_cgo_.o ${WORK}/plugin/_obj/_cgo_main.o ${WORK}/plugin/_obj/_cgo_export.o ${WORK}/plugin/_obj/plugin.cgo2.o -g -O2 -shared
	${GOROOT}/pkg/tool/linux_amd64/cgo -objdir ${WORK}/plugin/_obj/ -dynpackage main -dynimport ${WORK}/plugin/_obj/_cgo_.o -dynout ${WORK}/plugin/_obj/_cgo_import.go
	gcc -I . -fPIC -m64 -pthread -fmessage-length=0 -fdebug-prefix-map=${WORK}=/tmp/go-build -gno-record-gcc-switches -o ${WORK}/plugin/_obj/_all.o ${WORK}/plugin/_obj/_cgo_export.o ${WORK}/plugin/_obj/plugin.cgo2.o -g -O2 -Wl,-r -nostdlib -Wl,--build-id=none
	${GOROOT}/pkg/tool/linux_amd64/compile -o ${WORK}/plugin.a -trimpath ${WORK} -shared -p main -installsuffix shared -buildid 75f24cfe0933d8df5574c5c04c64f2fcf2ca5e86 -D _${GOPATH}/src/plugin -I ${WORK} -pack ${WORK}/plugin/_obj/_cgo_gotypes.go ${WORK}/plugin/_obj/plugin.cgo1.go ${WORK}/plugin/_obj/_cgo_import.go
	go tool pack r ${WORK}/plugin.a ${WORK}/plugin/_obj/_all.o # internal
	${GOROOT}/pkg/tool/linux_amd64/link -o ${WORK}/plugin/_obj/exe/a.out -L ${WORK} -installsuffix shared -extld=gcc -buildmode=c-shared -buildid=75f24cfe0933d8df5574c5c04c64f2fcf2ca5e86 ${WORK}/plugin.a
	mv ${WORK}/plugin/_obj/_cgo_install.h plugin.h
	mv ${WORK}/plugin/_obj/exe/a.out plugin
