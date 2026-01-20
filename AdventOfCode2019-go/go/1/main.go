package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func requiredFuel(weight int) int {
	return weight/3 - 2
}

func part1(lines []string) {
	totalFuel := 0
	for _, l := range lines {
		weight, _ := strconv.Atoi(l)
		totalFuel += requiredFuel(weight)
	}
	fmt.Println("Part1: ", totalFuel)
}

func part2(lines []string) {
	totalFuel := 0
	for _, l := range lines {
		weight, _ := strconv.Atoi(l)
		fuel := requiredFuel(weight)
		for {
			totalFuel += fuel
			fuel = requiredFuel(fuel)
			if fuel <= 0 {
				break
			}
		}
	}
	fmt.Println("Part2: ", totalFuel)
}

func main() {
	bytes, _ := ioutil.ReadFile("./input")
	input := string(bytes)
	lines := strings.Split(input, "\n")

	part1(lines)
	part2(lines)
}
