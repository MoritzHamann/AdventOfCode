package main

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"sort"
	"strconv"
)

func hasMultiples(word string, amount int) bool {
	if amount < 2 {
		return true
	}
	m := make(map[rune]int)
	for _, c := range word {
		if n, ok := m[c]; ok {
			m[c] = n + 1
		} else {
			m[c] = 1
		}
	}
	for _, n := range m {
		if n == amount {
			return true
		}
	}
	return false
}

func part1(input []string) string {
	doubles, tribles := 0, 0
	for _, s := range input {
		if hasMultiples(s, 2) {
			doubles++
		}
		if hasMultiples(s, 3) {
			tribles++
		}
	}
	return strconv.Itoa(doubles * tribles)
}

func charDiff(s1 string, s2 string) int {
	num := 0
	for idx := range s1 {
		if s1[idx] != s2[idx] {
			num++
		}
	}
	return num
}

func sameCharacters(s1 string, s2 string) string {
	res := make([]byte, 0)
	for idx := range s1 {
		if s1[idx] == s2[idx] {
			res = append(res, s1[idx])
		}
	}
	return bytes.NewBuffer(res).String()
}

func part2(input []string) string {
	sort.Strings(input)
	for idx := range input {
		if idx == 0 {
			continue
		}
		s1 := input[idx-1]
		s2 := input[idx]

		if charDiff(s1, s2) == 1 {
			return sameCharacters(s1, s2)
		}
	}
	return ""
}

func main() {
	file, _ := os.Open(os.Args[1])
	input := make([]string, 0)
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		input = append(input, scanner.Text())
	}

	fmt.Println(part1(input))
	fmt.Println(part2(input))
}
