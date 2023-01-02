package main

import (
    "fmt"
)

func a(input int) (out1, out2 int) {
    return input, input * 2
}

func b(in1, in2 int) int {
    return in1 * in2
}

func main() {
    fmt.Println(b(a(2)))
    d := new(int)
    *d = 4

    c := make(map[int]*int)
    c[1] = d

    fmt.Println(*c[1])
    c[1] = nil
    fmt.Println(*c[1])
}
