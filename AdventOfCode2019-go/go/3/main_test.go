package main

import (
	"bufio"
	"os"
	"testing"
)

func TestNewMovement(t *testing.T) {
	var m Movement

	m = NewMovement("L1")
	if m.amount != 1 || m.dir != "LEFT" {
		t.Error("Left test failed", m)
	}

	m = NewMovement("R2")
	if m.amount != 2 || m.dir != "RIGHT" {
		t.Error("Right test failed", m)
	}

	m = NewMovement("U3")
	if m.amount != 3 || m.dir != "UP" {
		t.Error("Up test failed", m)
	}

	m = NewMovement("D4")
	if m.amount != 4 || m.dir != "DOWN" {
		t.Error("Down test failed", m)
	}
}

func TestNewMovementWrongDirection(t *testing.T) {
	defer func() {
		if r := recover(); r == nil {
			t.Errorf("The code did not panic")
		}
	}()
	NewMovement("X1")
}

func TestNewMovementMultipleNumbers(t *testing.T) {
	m := NewMovement("U123")
	if m.amount != 123 {
		t.Error("multiple numbers not read correctly, expected 123 got ", m.amount)
	}
}

func TestInput1(t *testing.T) {
	f, _ := os.Open("./test_input1")
	scanner := bufio.NewScanner(f)

	wires := make([]Wire, 0)
	for scanner.Scan() {
		wire := NewWire(scanner.Text())
		wires = append(wires, wire)
	}

	part1(wires)
}
