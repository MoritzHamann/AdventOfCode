

def solution1(data: list[str]):
    sum = 0
    for line in data:
        numbers = []
        for char in line:
            if char.isnumeric():
                numbers.append(int(char))
        sum += numbers[0]*10 + numbers[-1]

    print(sum)

def solution2(data: list[str]):
    sum = 0
    words = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

    def matches_word(line):
        for word in words:
            if line.startswith(word):
                return word
        return None

    for line in data:
        numbers = []
        i = 0
        while i < len(line): 
            remaining_line = line[i:]
            if (match := matches_word(remaining_line)):
                numbers.append(words.index(match) + 1)
            elif remaining_line[0].isdigit():
                numbers.append(int(remaining_line[0]))
            i += 1

        value = (numbers[0]*10 + numbers[-1])
        sum += value

    print(sum)

