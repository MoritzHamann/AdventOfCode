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
    pass
