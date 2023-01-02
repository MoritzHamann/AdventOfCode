package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func readMemory(program []int, pos int) int {
	return program[pos]
}

func addOp(a, b int) int {
	return a + b
}

func multiplyOp(a, b int) int {
	return a * b
}

func executeOperator(program []int, pos int, op func(int, int) int) {
	locA := readMemory(program, pos+1)
	locB := readMemory(program, pos+2)
	dest := readMemory(program, pos+3)
	parameterA := readMemory(program, locA)
	parameterB := readMemory(program, locB)
	result := op(parameterA, parameterB)
	program[dest] = result
}

func runProgram(program []int) []int {
	for pos := 0; pos < len(program); pos += 4 {
		switch program[pos] {
		case 1:
			executeOperator(program, pos, addOp)
		case 2:
			executeOperator(program, pos, multiplyOp)
		case 99:
			break
		default:
			break
		}
	}
	return program
}

func part1(input []int) {
	program := make([]int, len(input))
	copy(program, input)

	program[1] = 12
	program[2] = 2
	runProgram(program)
	fmt.Println("Part1: ", program[0])
}

func part2(input []int) {
	program := make([]int, len(input))
	for x := range [100]int{} {
		for y := range [100]int{} {
			copy(program, input)

			program[1] = x
			program[2] = y
			program = runProgram(program)
			if program[0] == 19690720 {
				fmt.Println("Part2: ", x*100+y)
				break
			}
		}
	}
}

func main() {
	input, _ := ioutil.ReadFile("./input")
	content := string(input)
	program := strings.Split(content, ",")
	intProgram := make([]int, len(program))
	for idx, i := range program {
		j, _ := strconv.Atoi(i)
		intProgram[idx] = j
	}

	part1(intProgram)
	part2(intProgram)
}
