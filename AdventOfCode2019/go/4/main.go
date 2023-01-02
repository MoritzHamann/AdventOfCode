package main

import (
	"fmt"
	"math"
)

func getListOfNumbers(number int) []int {
	list := make([]int, 0)
	remaining := number
	for exp := 5; exp >= 0; exp-- {
		divider := int(math.Pow10(exp))
		val := remaining / divider
		remaining = remaining - (val * divider)

		list = append(list, val)
	}
	return list
}

func isIncreasinog(numbers []int) bool {
	lastNumber := -1
	for _, n := range numbers {
		if n < lastNumber {
			return false
		}
		lastNumber = n
	}
	return true
}

func hasDoubleDigit(numbers []int) bool {
	for i, n := range numbers[0 : len(numbers)-1] {
		if n == numbers[i+1] {
			return true
		}
	}
	return false
}

func hasExactlyDoubleDigit(numbers []int) bool {
	amount := 1
	for i, n := range numbers[0 : len(numbers)-1] {
		if n == numbers[i+1] {
			amount++
		} else {
			if amount == 2 {
				return true
			}
			amount = 1
		}
	}
	return amount == 2
}

func isValidPasswordPart1(number, lower, upper int) bool {
	if number < 100000 || number > 999999 {
		return false
	}
	numbers := getListOfNumbers(number)
	return isIncreasinog(numbers) && hasDoubleDigit(numbers)
}

func isValidPasswordPart2(number, lower, upper int) bool {
	if number < 100000 || number > 999999 {
		return false
	}
	numbers := getListOfNumbers(number)
	return isIncreasinog(numbers) && hasExactlyDoubleDigit(numbers)
}

func part1(lower, upper int) {
	amount := 0
	for i := lower; i <= upper; i++ {
		if isValidPasswordPart1(i, lower, upper) {
			amount++
		}
	}
	fmt.Println(amount)
}

func part2(lower, upper int) {
	amount := 0
	for i := lower; i <= upper; i++ {
		if isValidPasswordPart2(i, lower, upper) {
			amount++
		}
	}
	fmt.Println(amount)
}

func main() {
	lower := 171309
	upper := 643603

	part1(lower, upper)
	part2(lower, upper)
}
