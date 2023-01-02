package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
)

type area struct {
	id, x, y, w, h int
}

type coord struct {
	x, y int
}

func part1(input []area) string {
	field := make(map[coord]int)

	for _, rect := range input {
		for x := rect.x; x < rect.x+rect.w; x++ {
			for y := rect.y; y < rect.y+rect.h; y++ {
				point := coord{x, y}
				if _, ok := field[point]; ok {
					field[point]++
				} else {
					field[point] = 1
				}
			}
		}
	}
	sum := 0
	for _, n := range field {
		if n >= 2 {
			sum++
		}
	}
	return strconv.Itoa(sum)
}

func overlapX(a area, b area) bool {
	if a.x < b.x {
		return b.x <= a.x+a.w
	}
	return a.x <= b.x+b.w
}
func overlapY(a area, b area) bool {
	if a.y < b.y {
		return b.y <= a.y+a.h
	}
	return a.y <= b.y+b.h
}

func (a area) intersetcs(b area) bool {
	return overlapX(a, b) && overlapY(a, b)
}

func part2(input []area) string {
MainLoop:
	for _, rect := range input {
		for _, test := range input {
			if rect.intersetcs(test) && rect.id != test.id {
				continue MainLoop
			}
		}
		return strconv.Itoa(rect.id)
	}
	return ""
}

func parseInputLine(line string) area {
	pattern := regexp.MustCompile("#([0-9]+) @ ([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)")
	m := pattern.FindStringSubmatch(line)
	id, _ := strconv.Atoi(m[1])
	x, _ := strconv.Atoi(m[2])
	y, _ := strconv.Atoi(m[3])
	w, _ := strconv.Atoi(m[4])
	h, _ := strconv.Atoi(m[5])
	return area{id, x, y, w, h}
}

func main() {
	file, _ := os.Open(os.Args[1])
	scanner := bufio.NewScanner(file)

	input := make([]area, 0)
	for scanner.Scan() {
		input = append(input, parseInputLine(scanner.Text()))
	}
	fmt.Println(part1(input))
	fmt.Println(part2(input))
}
