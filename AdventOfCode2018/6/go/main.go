package main

import (
	"bufio"
	"fmt"
	"os"
	"runtime/pprof"
	"strconv"
	"strings"
)

type point struct {
	x, y int
}

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

func findBoundingBox(points []point) (int, int, int, int) {
	minX, minY, maxX, maxY := -1, -1, 0, 0
	for _, p := range points {
		if p.x < minX || minX < 0 {
			minX = p.x
		}
		if p.y < minY || minY < 0 {
			minY = p.y
		}
		if p.x > maxX {
			maxX = p.x
		}
		if p.y > maxY {
			maxY = p.y
		}
	}
	return minX, minY, maxX, maxY
}

func distance(x, y int, p point) int {
	return abs(p.x-x) + abs(p.y-y)
}

func isOnBorder(p point, minX, minY, maxX, maxY int) bool {
	return p.x == minX || p.x == maxX || p.y == minY || p.y == maxY
}

func part1(points []point) string {
	minX, minY, maxX, maxY := findBoundingBox(points)
	area := make(map[int]int)
	fmt.Println(minX, maxX, minY, maxY)

	for x := minX; x <= maxX; x++ {
		for y := minY; y <= maxY; y++ {
			minIdx, minDis := 0, -1
			sameDistance := false
			for idx, p := range points {
				d := distance(x, y, p)
				if d == minDis {
					sameDistance = true
				}
				if minDis < 0 || d < minDis {
					minIdx, minDis = idx, d
					sameDistance = false
				}
			}
			if isOnBorder(points[minIdx], minX, minY, maxX, maxY) {
				continue
			}
			if !sameDistance {
				area[minIdx]++
			}
		}
	}
	maxArea := 0
	for _, a := range area {
		if a > maxArea {
			maxArea = a
		}
	}
	return strconv.Itoa(maxArea)
}

func part2(points []point) string {
	minX, minY, maxX, maxY := findBoundingBox(points)
	area := 0
	for x := minX; x <= maxX; x++ {
		for y := minY; y <= maxY; y++ {
			d := 0
			for _, p := range points {
				d += distance(x, y, p)
			}
			if d < 10000 {
				area++
			}
		}
	}

	return strconv.Itoa(area)
}

func main() {
	profileFile, _ := os.Create("./profiling.pprof")
	pprof.StartCPUProfile(profileFile)
	defer pprof.StopCPUProfile()

	file, _ := os.Open(os.Args[1])
	scanner := bufio.NewScanner(file)
	points := make([]point, 0)
	for scanner.Scan() {
		coords := strings.Split(scanner.Text(), ",")
		x, _ := strconv.Atoi(strings.Trim(coords[0], " "))
		y, _ := strconv.Atoi(strings.Trim(coords[1], " "))
		p := point{x, y}
		points = append(points, p)
	}

	fmt.Println(part1(points))
	fmt.Println(part2(points))
}
