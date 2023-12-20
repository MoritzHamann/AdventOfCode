#!/usr/bin/env python3

from argparse import ArgumentParser
from importlib import import_module

def parse_args():
    parser = ArgumentParser("Advent of Code 2023")
    parser.add_argument("-d", "--day", type=int, required=True)
    parser.add_argument("-t", "--test", action="store_true")
    

    return parser.parse_args()

def read_data(day, test, solution):
    lines = []
    filename = f"inputs/day{day}"
    if test:
        filename = f"inputs/day{day}_test_{solution}"

    with open(filename) as f:
        lines = [l.strip() for l in f.readlines()]
    return lines

if __name__ == "__main__":
    args = parse_args()

    module_name = f"solutions.day{args.day}"
    day = import_module(module_name)
    
    data = read_data(args.day, args.test, 1)
    day.solution1(data)

    data = read_data(args.day, args.test, 2)
    day.solution2(data)

