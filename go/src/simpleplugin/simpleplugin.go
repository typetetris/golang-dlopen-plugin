package main

import "C"

import "fmt"

//export GoFunction
func GoFunction() {
	fmt.Println("Hello from Go!")
}

func main() {
	//needed for buildmode c-shared
}
