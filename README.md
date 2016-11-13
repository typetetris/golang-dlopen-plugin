# golang-dlopen-plugin
## What is this about?
I tried to extend some application written in C with plugins written
in Googles Go and `-buildmode=c-shared` didn't work as I expected it to.
So I made this minimal example to ask you, if I probably trying something
stupid that will bite me later.

### Oh and it is a specific example for x86_64_linux with go 1.7.3

## What was the problem?
If you want to create an API for plugins in C, you can simply define the
functions you need for the API and link them together with the application
in a way, that they can be found later by libraries, which you open with
`dlopen`.

So your plugin will become a shared library, which will contain some unresolved
symbols, which will be resolved, when it is loaded via dlopen.

go build didn't let me do this.

I got the following error:

    $ GOPATH=$(pwd)/go go build -buildmode=c-shared plugin
    # plugin
    /tmp/go-build980489944/plugin/_obj/plugin.cgo2.o: In function `_cgo_6f12656e94c4_Cfunc_func_for_go_plugin_to_find_at_dlopen_time':
    go/src/plugin/plugin.go:43: undefined reference to `func_for_go_plugin_to_find_at_dlopen_time'
    collect2: error: ld returned 1 exit status
    
## What I did to get around this?
In the out put of `go build -x -buildmode=c-shared plugin` there is a line like this:

    gcc -I . -fPIC -m64 -pthread -fmessage-length=0 -fdebug-prefix-map=$WORK=/tmp/go-build -gno-record-gcc-switches -o $WORK/plugin/_obj/_cgo_.o $WORK/plugin/_obj/_cgo_main.o $WORK/plugin/_obj/_cgo_export.o $WORK/plugin/_obj/plugin.cgo2.o -g -O2
    
here I simply added the flag `-shared`. I couldn't do this with cgo's `LDFLAGS` or `CFLAGS` as those are
added in other places too, there they caused different errors.

So afterwards it looks like that:

    gcc -I . -fPIC -m64 -pthread -fmessage-length=0 -fdebug-prefix-map=$WORK=/tmp/go-build -gno-record-gcc-switches -o $WORK/plugin/_obj/_cgo_.o $WORK/plugin/_obj/_cgo_main.o $WORK/plugin/_obj/_cgo_export.o $WORK/plugin/_obj/plugin.cgo2.o -g -O2 -shared
    
## Why doesn't the makefile recipe for plugin look exactly like the output of `go build -x -buildmode=c-shared plugin`?
Because there were different errors too  unrelated, I suppose, to the issue at hand. For example the following
line needs to be altered to work:

    CGO_LDFLAGS="-g" "-O2" $GOROOT/pkg/tool/linux_amd64/cgo -objdir $WORK/plugin/_obj/ -importpath plugin -exportheader=$WORK/plugin/_obj/_cgo_install.h -- -I $WORK/plugin/_obj/ plugin.go
    
The value for `CGO_LDFLAGS` needs to be `"-g -O2"` and not `"-g" "-O2"`.

And I needed to alter the paths and get rid of the `cd` commands to make it work as a makefile recipe, which is at least a little bit readable.

## How to run the example?
You will need a go 1.7.3 installation in a place, where your user can write to it. If you never used cgo or cgo with
`-buildmode=c-shared` some cgo packages will be `go install`ed into the `$GOROOT`. I don't know why that is and why
they can't go into your `$GOPATH` which would be gentler in my opinion. The call `make simpleplugin` is all about
this, as I didn't bother to get the commands to build those things, which are installed in the `$GOROOT`, into the
makefile recipe.

    cd golang-dlopen-plugin
    make hostapp
    make simpleplugin
    make plugin
    ./hostapp
