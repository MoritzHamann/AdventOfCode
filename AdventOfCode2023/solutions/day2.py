
def is_valid_draw(red, green, blue):
    return red <= 12 and green <= 13 and blue <= 14

def get_colors(draw):
    red = 0
    green = 0
    blue = 0
    for pick in draw.split(","):
        pick = pick.strip()
        number, color = pick.split(" ")
        number = int(number)
        if color == "red":
            red = number
        if color == "green":
            green = number
        if color == "blue":
            blue = number
    
    return {"red": red, "green": green, "blue": blue}

def get_game_data(game_line):
    game_id, cubes = game_line.split(":")
    game_id = int(game_id.split(" ")[1])
    draws = []
    for draw in cubes.split(";"):
        draws.append(get_colors(draw))
    return game_id, draws


def solution1(data):
    valid_games = []
    for game in data:
        game_id, draws = get_game_data(game)
        valid_draws = []
        for draw in draws:
            valid_draws.append(is_valid_draw(**draw))
        
        if all(valid_draws):
            valid_games.append(game_id)

    print(sum(valid_games))


def solution2(data):
    powers = 0
    for game in data:
        _, draws = get_game_data(game)
        max_values = {"red": 0, "blue": 0, "green": 0}
        for draw in draws:
            print(draw)
            for color, value in draw.items():
                if value > max_values[color]:
                    max_values[color] = value
        power = 1
        for v in max_values.values():
            power *= v
        powers += power

    print(powers)
