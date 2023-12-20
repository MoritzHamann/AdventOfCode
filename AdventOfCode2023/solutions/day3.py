from collections import defaultdict
from typing import Tuple


def is_number_adjacent(data: list[str], i, j: int) -> bool:
    access_x = [-1, 0, 1]
    access_y = [-1, 0, 1]

    if i <= 0:
        access_y.remove(-1)
    if j <= 0:
        access_x.remove(-1)
    if i >= len(data)-1:
        access_y.remove(1)
    if j >= len(data[i])-1:
        access_x.remove(1)
    
    for x in access_x:
        for y in access_y:
            if not (data[i+y][j+x].isdigit() or data[i+y][j+x] == '.'):
                return True
    return False

def adjacent_gears(data: list[str], i, j: int)-> set[Tuple[int]]:
    access_x = [-1, 0, 1]
    access_y = [-1, 0, 1]

    if i <= 0:
        access_y.remove(-1)
    if j <= 0:
        access_x.remove(-1)
    if i >= len(data)-1:
        access_y.remove(1)
    if j >= len(data[i])-1:
        access_x.remove(1)
    
    locations = set()
    for x in access_x:
        for y in access_y:
            if data[i+y][j+x] == '*':
                locations.add((i+y,j+x))
    return locations


def solution1(data: list[str]):
    sum = 0
    number_stack = []
    is_adjacent = False
    for i, line in enumerate(data):
        for j, char in enumerate(line):
            if char.isdigit():
                number_stack.append(char)
                is_adjacent = is_adjacent or is_number_adjacent(data, i, j)
            else:
                if is_adjacent:
                    # convert to number and add to sum
                    sum += int(''.join(number_stack))
                number_stack = []
                is_adjacent = False
        # clean up after the end of the line
        if is_adjacent:
            # convert to number and add to sum
            sum += int(''.join(number_stack))
        is_adjacent = False
        number_stack = []
    print(sum)


def solution2(data: list[str]):
    # global dict, mapping gear location (i, j) => [adjacent numbers]
    gears = defaultdict(list)
    
    number_stack = []
    gear_locations = set()

    def handle_end_of_number(g_locs , number):
        if g_locs:
            n = int(''.join(number))
            for loc in g_locs:
                gears[loc].append(n)

    for i, line in enumerate(data):
        for j, char in enumerate(line):
            if char.isdigit():
                number_stack.append(char)
                gear_locations = gear_locations.union(adjacent_gears(data, i, j))
            else:
                handle_end_of_number(gear_locations, number_stack)
                number_stack = []
                gear_locations = set()
        handle_end_of_number(gear_locations, number_stack)
        number_stack = []
        gear_locations = set()
    
    sum = 0
    for numbers in gears.values():
        if len(numbers) == 2:
            sum += (numbers[0] * numbers[1])
    print(sum)
