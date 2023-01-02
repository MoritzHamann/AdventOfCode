package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"unicode"
)

func doReact(a, b rune) bool {
	if unicode.IsLower(a) && unicode.IsUpper(b) {
		return unicode.ToUpper(a) == b
	} else if unicode.IsUpper(a) && unicode.IsLower(b) {
		return a == unicode.ToUpper(b)
	} else {
		return false
	}
}

func collapse(polymer []rune) []rune {
	reacted := make([]rune, 0)
	for _, char := range polymer {
		if len(reacted) == 0 {
			reacted = append(reacted, char)
			continue
		}
		lastChar := reacted[len(reacted)-1]
		if doReact(lastChar, char) {
			reacted = reacted[:len(reacted)-1]
		} else {
			reacted = append(reacted, char)
		}
	}
	return reacted
}

func filterRunes(original []rune, filter func(rune) bool) []rune {
	filtered := make([]rune, 0)
	for _, c := range original {
		if filter(c) {
			filtered = append(filtered, c)
		}
	}
	return filtered
}

func part1(polymer string) string {
	original := []rune(polymer)
	return strconv.Itoa(len(collapse(original)))
}

func part2(polymer string) string {
	letters := []rune{'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z'}
	original := []rune(polymer)
	minLen := -1
	for _, c := range letters {
		removed := filterRunes(original, func(r rune) bool {
			return unicode.ToUpper(r) != unicode.ToUpper(c)
		})
		l := len(collapse(removed))
		if minLen < 0 || l < minLen {
			minLen = l
		}
	}
	return strconv.Itoa(minLen)
}

func main() {
	content, _ := ioutil.ReadFile(os.Args[1])
	polymer := string(content)

	fmt.Println(part1(polymer))
	fmt.Println(part2(polymer))
}
