WORK=/tmp/work
GOPATH=$(shell pwd)/go

hostapp: hostapp.c hostapp.h
	gcc -o $@ hostapp.c -ldl -Wl,--export-dynamic

envtest:
	echo $$GOPATH

simpleplugin: ${GOPATH}/src/simpleplugin/simpleplugin.go
	go build -buildmode=c-shared simpleplugin

plugin: ${GOPATH}/src/plugin/plugin.go ${GOPATH}/src/plugin/hostapp-for-plugins.h
	go build -buildmode=c-shared $@

plugin1: ${GOPATH}/src/plugin1/plugin.go hostapp.h
	go build -buildmode=c-shared $@

plugin2: ${GOPATH}/src/plugin2/plugin.go hostapp.h
	go build -buildmode=c-shared $@

test: hostapp simpleplugin plugin plugin1 plugin2
	./hostapp ./simpleplugin
	./hostapp ./plugin
	./hostapp ./plugin1
	./hostapp ./plugin2
