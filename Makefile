WORK=/tmp/work
GOPATH=$(shell pwd)/go

hostapp: hostapp.c hostapp.h
	gcc -o $@ hostapp.c -ldl -Wl,--export-dynamic

envtest:
	echo $$GOPATH

simpleplugin: ${GOPATH}/src/simpleplugin/simpleplugin.go
	go build -buildmode=c-shared simpleplugin

demoplugin-weak-symbols: ${GOPATH}/src/demoplugin-weak-symbols/plugin.go ${GOPATH}/src/demoplugin-weak-symbols/hostapp-for-plugins.h
	go build -buildmode=c-shared $@

demoplugin-ignore-all: ${GOPATH}/src/demoplugin-ignore-all/plugin.go hostapp.h
	go build -buildmode=c-shared $@

demoplugin-warn-unresolved-symbols: ${GOPATH}/src/demoplugin-warn-unresolved-symbols/plugin.go hostapp.h
	go build -buildmode=c-shared $@

test: hostapp simpleplugin demoplugin-weak-symbols demoplugin-ignore-all demoplugin-warn-unresolved-symbols
	./hostapp ./simpleplugin
	./hostapp ./demoplugin-weak-symbols
	./hostapp ./demoplugin-ignore-all
	./hostapp ./demoplugin-warn-unresolved-symbols
