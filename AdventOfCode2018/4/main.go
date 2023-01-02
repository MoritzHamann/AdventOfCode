package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"sort"
	"strconv"
)

func parseLine(line string) []string {
	pattern := regexp.MustCompile(`(\[.*\]) (.*)`)
	return pattern.FindStringSubmatch(line)[1:3]
}

func getMinute(ts string) int {
	pattern := regexp.MustCompile(`\[.*\s[0-9]{2}:([0-9]{2})\]`)
	matches := pattern.FindStringSubmatch(ts)
	min, _ := strconv.Atoi(matches[1])
	return min
}

func getGuard(entry string) int {
	pattern := regexp.MustCompile(`.*#([0-9]+).*`)
	matches := pattern.FindStringSubmatch(entry)
	guard, _ := strconv.Atoi(matches[1])
	return guard
}

func getMap(input []string) map[int]map[int]int {
	var sleepMinute int
	var guard int
	sleepTime := make(map[int]map[int]int)

	for _, e := range input {
		data := parseLine(e)
		minute := getMinute(data[0])

		switch {
		case data[1] == "falls asleep":
			sleepMinute = minute
		case data[1] == "wakes up":
			if sleepTime[guard] == nil {
				sleepTime[guard] = make(map[int]int)
			}
			for i := sleepMinute; i < minute; i++ {
				sleepTime[guard][i]++
			}
		default:
			guard = getGuard(data[1])
		}
	}
	return sleepTime
}

func part1(input []string) string {
	sleepTime := getMap(input)
	max := 0
	guard := 0
	for g, t := range sleepTime {
		sum := 0
		for _, m := range t {
			sum += m
		}

		if sum > max {
			guard = g
			max = sum
		}
	}
	maxMin := 0
	maxMinAmount := 0
	for m, amount := range sleepTime[guard] {
		if amount > maxMinAmount {
			maxMin = m
			maxMinAmount = amount
		}
	}
	return strconv.Itoa(maxMin * guard)
}

func part2(input []string) string {
	sleepTime := getMap(input)
	amount := 0
	guard := 0
	minute := 0

	for g, allMin := range sleepTime {
		for m, a := range allMin {
			if a > amount {
				guard = g
				amount = a
				minute = m
			}
		}
	}

	return strconv.Itoa(guard * minute)
}

func main() {
	file, _ := os.Open(os.Args[1])
	scanner := bufio.NewScanner(file)

	input := make([]string, 0)
	for scanner.Scan() {
		input = append(input, scanner.Text())
	}
	sort.Strings(input)
	fmt.Println(part1(input))
	fmt.Println(part2(input))
}
