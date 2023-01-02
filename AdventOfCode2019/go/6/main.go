package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

type Planet struct {
	name   string
	orbits *Planet
}

func (p Planet) distanceTo(p2 Planet) int {
	distance := 0
	hop := p
	for hop.orbits != nil && hop.name != p2.name {
		distance++
		hop = *hop.orbits
	}
	return distance
}

func (p Planet) pathTo(p2 Planet) []string {
	path := make([]string, 0)
	hop := p
	for hop.name != p2.name {
		path = append(path, hop.name)
		hop = *hop.orbits
	}

	return path
}

func NewPlanet(name string) *Planet {
	return &Planet{name: name}
}

func parseOrbitDescription(description string) (string, string) {
	planetNames := strings.Split(description, ")")
	return planetNames[0], planetNames[1]
}

func pathContains(path []string, name string) bool {
	for _, p := range path {
		if p == name {
			return true
		}
	}
	return false
}

func part1(planetMap map[string]*Planet) {
	totalOrbits := 0
	center := planetMap["COM"]
	for _, planet := range planetMap {
		totalOrbits += planet.distanceTo(*center)
	}
	fmt.Println(totalOrbits)
}

func part2(planetMap map[string]*Planet) {
	you := planetMap["YOU"]
	santa := planetMap["SAN"]
	center := planetMap["COM"]

	yourPathToCOM := you.pathTo(*center)
	santaPathToCOM := santa.pathTo(*center)

	// find common ancestor
	commonAncestor := center
	for _, p := range yourPathToCOM {
		if pathContains(santaPathToCOM, p) {
			commonAncestor = planetMap[p]
			break
		}
	}

	numberOfHops := you.distanceTo(*commonAncestor) + santa.distanceTo(*commonAncestor)
	numberOfHops -= 2 // remove own hops
	fmt.Println(numberOfHops)
}

func main() {
	f, _ := os.Open("./input")
	scanner := bufio.NewScanner(f)

	planetOrbits := make(map[string]*Planet)
	for scanner.Scan() {
		center, planet := parseOrbitDescription(scanner.Text())

		if _, ok := planetOrbits[center]; !ok {
			planetOrbits[center] = NewPlanet(center)
		}
		if _, ok := planetOrbits[planet]; !ok {
			planetOrbits[planet] = NewPlanet(planet)
		}
		planetOrbits[planet].orbits = planetOrbits[center]
	}

	part1(planetOrbits)
	part2(planetOrbits)
}
