package main

//#include "hostapp.h"
import "C"

import "fmt"

//export GoFunction
func GoFunction() {
	fmt.Println("Hello from Go!")
	C.func_for_go_plugin_to_find_at_dlopen_time()
}

func main() {
	//needed for buildmode c-shared
}
