package main

import (
	"io/ioutil"
	"strconv"
	"strings"

	"./intProgram"
)

func part1(program []int) {
	computer := intProgram.NewIntComputer(program)
	for !computer.IsFinished() {
		computer.Step()
	}
}

func main() {
	input, _ := ioutil.ReadFile("./input")
	tokens := strings.Split(string(input), ",")
	program := make([]int, 0, len(tokens))

	for _, t := range tokens {
		i, _ := strconv.Atoi(t)
		program = append(program, i)
	}

	part1(program)

}
