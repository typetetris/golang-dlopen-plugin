# golang-dlopen-plugin
## What is this about?
I tried to extend some application written in C with plugins written
in Googles Go and `-buildmode=c-shared` didn't work as I expected it to.

### Oh and it is a specific example for x86_64_linux

## What was the problem?
If you want to create an API for plugins in C, you can simply define the
functions you need for the API and link them together with the application
in a way, that they can be found later by libraries, which you open with
`dlopen`.

So your plugin will become a shared library, which will contain some unresolved
symbols, which will be resolved, when it is loaded via dlopen.

go build didn't let me do this, when I tried to do it naively.

I got the following error:

    $ GOPATH=$(pwd)/go go build -buildmode=c-shared plugin
    # plugin
    /tmp/go-build980489944/plugin/_obj/plugin.cgo2.o: In function `_cgo_6f12656e94c4_Cfunc_func_for_go_plugin_to_find_at_dlopen_time':
    go/src/plugin/plugin.go:43: undefined reference to `func_for_go_plugin_to_find_at_dlopen_time'
    collect2: error: ld returned 1 exit status

## First try to get around this
In the out put of `go build -x -buildmode=c-shared plugin` there is a line like this:

    gcc -I . -fPIC -m64 -pthread -fmessage-length=0 -fdebug-prefix-map=$WORK=/tmp/go-build -gno-record-gcc-switches -o $WORK/plugin/_obj/_cgo_.o $WORK/plugin/_obj/_cgo_main.o $WORK/plugin/_obj/_cgo_export.o $WORK/plugin/_obj/plugin.cgo2.o -g -O2

here I simply added the flag `-shared`. I couldn't do this with cgo's `LDFLAGS` or `CFLAGS` as those are
added in other places too, there they caused different errors.

So afterwards it looks like that:

    gcc -I . -fPIC -m64 -pthread -fmessage-length=0 -fdebug-prefix-map=$WORK=/tmp/go-build -gno-record-gcc-switches -o $WORK/plugin/_obj/_cgo_.o $WORK/plugin/_obj/_cgo_main.o $WORK/plugin/_obj/_cgo_export.o $WORK/plugin/_obj/plugin.cgo2.o -g -O2 -shared

It turned out, that was unnecessary convoluted and probably wrong.

## Second try to get around this
I learned about three methods to get around this. The following answer on golang-nuts was very
[helpful](https://groups.google.com/d/msg/golang-nuts/NPEKogRR9Q0/IC-IUUy7CQAJ).

1. Use
    `__attribute__((weak))`
   to declare a weak symbol. Be aware, that a weak symbol can be overwritten by any shared library loaded into the process or any archive or object file used in the linking process. There can be as to my knowledge only one strong symbol
of a name.

2. Use the
    `--unresolved-symbols=ignore-all`
   linker command line option to ignore undefined references. The symbol in question will show as undefined 'U' if you exermine your artifact with nm.

3. Use the
    `--warn-unresolved-symbols`
   linker command line option to turn errors about undefined references into warnings. The symbol in question will show as undefined 'U' if you exermine your artifact with nm. You probably want to filter the linker output for undefined references to catch unintended undefined references.

## How to run the example?
You will need a go installation in a place, where your user can write to it. If you never used cgo or cgo with
`-buildmode=c-shared` some cgo packages will be `go install`ed into the `$GOROOT`. I don't know why that is and why
they can't go into your `$GOPATH` which would be gentler in my opinion.

    cd golang-dlopen-plugin
    make test
