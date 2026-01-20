package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

type Movement struct {
	amount int
	dir    string
}

type Wire []Movement

func NewMovement(input string) Movement {
	var dir string
	var amount int

	switch input[0] {
	case 'U':
		dir = "UP"
	case 'L':
		dir = "LEFT"
	case 'R':
		dir = "RIGHT"
	case 'D':
		dir = "DOWN"
	default:
		panic("Wrong direction")
	}

	amount, _ = strconv.Atoi(input[1:])
	return Movement{amount: amount, dir: dir}
}

func NewWire(line string) Wire {
	movements := make([]Movement, 0)
	for _, token := range strings.Split(line, ",") {
		move := NewMovement(token)
		movements = append(movements, move)
	}
	return movements
}

func fillAreaOfWire(wire Wire) map[[2]int]int {
	area := make(map[[2]int]int)
	posX := 0
	posY := 0
	dirX := 0
	dirY := 0
	step := 0

	for _, move := range wire {
		dirX = 0
		dirY = 0

		switch move.dir {
		case "UP":
			dirY = 1
		case "DOWN":
			dirY = -1
		case "LEFT":
			dirX = -1
		case "RIGHT":
			dirX = 1
		}
		for i := 0; i < move.amount; i++ {
			posX += dirX
			posY += dirY
			step++
			area[[2]int{posX, posY}] = step
		}
	}
	return area
}

func distanceToOrigin(x, y int) int {
	return int(math.Abs(float64(x))) + int(math.Abs(float64(y)))
}

func part1(wires []Wire) {
	area1 := fillAreaOfWire(wires[0])
	area2 := fillAreaOfWire(wires[1])

	var minDistance *int
	for loc := range area1 {
		if loc[0] == 0 && loc[1] == 0 {
			continue
		}

		if _, ok := area2[loc]; ok {
			distance := distanceToOrigin(loc[0], loc[1])

			if minDistance == nil {
				minDistance = new(int)
				*minDistance = distance
			}
			if *minDistance > distance {
				*minDistance = distance
			}
		}
	}
	if minDistance == nil {
		fmt.Println("Not found")
	} else {
		fmt.Println("Part1: ", *minDistance)
	}
}

func part2(wires []Wire) {
	area1 := fillAreaOfWire(wires[0])
	area2 := fillAreaOfWire(wires[1])

	var minDistance *int
	for loc := range area1 {
		if loc[0] == 0 && loc[1] == 0 {
			continue
		}
		if _, ok := area2[loc]; ok {
			distance := area1[loc] + area2[loc]
			if minDistance == nil {
				minDistance = new(int)
				*minDistance = distance
			}
			if *minDistance > distance {
				*minDistance = distance
			}
		}
	}
	if minDistance == nil {
		fmt.Println("Not found")
	} else {
		fmt.Println("Part1: ", *minDistance)
	}
}

func main() {
	f, _ := os.Open("./input")
	scanner := bufio.NewScanner(f)

	wires := make([]Wire, 0)
	for scanner.Scan() {
		wire := NewWire(scanner.Text())
		wires = append(wires, wire)
	}

	part1(wires)
	part2(wires)
}
