package intProgram

import (
	"fmt"
	"math"
)

type IntComputer struct {
	original []int
	memory   []int
	ip       int
	input    []int
	output   []int
}

func NewIntComputer(program []int) *IntComputer {
	computer := IntComputer{
		original: make([]int, len(program)),
		memory:   make([]int, len(program)),
		ip:       0,
		output:   make([]int, 0),
	}
	copy(computer.original, program)
	copy(computer.memory, program)

	return &computer
}

func (c *IntComputer) Reset() {
	copy(c.memory, c.original)
	c.ip = 0
	c.input = make([]int, 0)
	c.output = make([]int, 0)
}

func splitIntoNumbers(inputNumber int) []int {
	numbers := make([]int, 0)
	for i := 4; i > 1; i-- {
		exp := int(math.Pow10(i))
		num := inputNumber / exp
		numbers = append(numbers, num)
		inputNumber = inputNumber - (num * exp)
	}
	numbers = append(numbers, inputNumber)

	return numbers
}

func (c *IntComputer) Step() {
	instructions := splitIntoNumbers(c.ValueAtMemoryPos(c.ip, 1))
	opCode := instructions[len(instructions)-1]
	mode1 := instructions[len(instructions)-2]
	mode2 := instructions[len(instructions)-3]

	switch opCode {
	case 1:
		parameter1 := c.ValueAtMemoryPos(c.ip+1, mode1)
		parameter2 := c.ValueAtMemoryPos(c.ip+2, mode2)
		destination := c.ValueAtMemoryPos(c.ip+3, 1)

		c.memory[destination] = parameter1 + parameter2
		c.ip += 4
	case 2:
		parameter1 := c.ValueAtMemoryPos(c.ip+1, mode1)
		parameter2 := c.ValueAtMemoryPos(c.ip+2, mode2)
		destination := c.ValueAtMemoryPos(c.ip+3, 1)

		c.memory[destination] = parameter1 * parameter2
		c.ip += 4
	case 3:
		// pop from input
		value := c.input[len(c.input)-1]
		c.input = c.input[:len(c.input)-1]

		destination := c.ValueAtMemoryPos(c.ip+1, 1)
		c.memory[destination] = value
		c.ip += 2
	case 4:
		parameter1 := c.ValueAtMemoryPos(c.ip+1, mode1)
		c.output = append(c.output, parameter1)
		c.ip += 2
	case 5:
		parameter1 := c.ValueAtMemoryPos(c.ip+1, mode1)
		if parameter1 != 0 {
			parameter2 := c.ValueAtMemoryPos(c.ip+2, mode2)
			c.ip = parameter2
		} else {
			c.ip += 3
		}
	case 6:
		parameter1 := c.ValueAtMemoryPos(c.ip+1, mode1)
		if parameter1 == 0 {
			parameter2 := c.ValueAtMemoryPos(c.ip+2, mode2)
			c.ip = parameter2
		} else {
			c.ip += 3
		}
	case 7:
		parameter1 := c.ValueAtMemoryPos(c.ip+1, mode1)
		parameter2 := c.ValueAtMemoryPos(c.ip+2, mode2)
		destination := c.ValueAtMemoryPos(c.ip+3, 1)
		if parameter1 < parameter2 {
			c.memory[destination] = 1
		} else {
			c.memory[destination] = 0
		}
		c.ip += 4
	case 8:
		parameter1 := c.ValueAtMemoryPos(c.ip+1, mode1)
		parameter2 := c.ValueAtMemoryPos(c.ip+2, mode2)
		destination := c.ValueAtMemoryPos(c.ip+3, 1)
		if parameter1 == parameter2 {
			c.memory[destination] = 1
		} else {
			c.memory[destination] = 0
		}
		c.ip += 4
	case 99:
		c.ip = len(c.memory)
	default:
		fmt.Println("Unexpected opCode. Aborting!")
		fmt.Println("=> opcode: ", opCode)
		fmt.Println("=> ip    : ", c.ip)
		c.ip = len(c.memory)
	}
}

func (c *IntComputer) Run(input []int) []int {
	c.input = input
	for !c.IsFinished() {
		c.Step()
	}
	return c.output
}

func (c *IntComputer) IsFinished() bool {
	if c.ip >= len(c.memory) || c.memory[c.ip] == 99 {
		return true
	}
	return false
}

func (c *IntComputer) ValueAtMemoryPos(pos, mode int) int {
	value := c.memory[pos]
	if mode == 0 {
		value = c.memory[value]
	}
	return value
}
