package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

func part1(freq []int) string {
	sum := 0
	for _, f := range freq {
		sum += f
	}
	return strconv.Itoa(sum)
}

func part2(freq []int) string {
	f := 0
	idx := 0
	length := len(freq)
	visited := make(map[int]bool)

	for {
		f += freq[idx%length]
		if _, ok := visited[f]; ok {
			return strconv.Itoa(f)
		}
		visited[f] = true
		idx++
	}
}

func main() {
	file, _ := os.Open(os.Args[1])
	scanner := bufio.NewScanner(file)

	var freq []int
	for scanner.Scan() {
		f, _ := strconv.Atoi(scanner.Text())
		freq = append(freq, f)
	}

	fmt.Println(part1(freq))
	fmt.Println(part2(freq))
}
