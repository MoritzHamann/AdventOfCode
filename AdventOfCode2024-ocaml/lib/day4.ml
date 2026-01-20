
type grid = char array array
type search_function = pos:(int*int) -> grid:grid -> int


let parse_char_into ~row idx char = row.(idx) <- char

let parse_line_into (grid:grid) (idx: int) (line:string) =
    let row = grid.(idx) in
    let parser = parse_char_into ~row in
    String.iteri parser line

let parse_grid (lines: string list): grid =
    let width = String.length (List.hd lines) in
    let height = List.length lines in
    let grid = Array.make_matrix height width ' ' in
    
    List.iteri (parse_line_into grid) lines;
    grid

let is_word_in_dir ~pos ~grid word dir =
    let (dx, dy) = dir in
    let (x, y) = pos in

    let is_valid_pos (x,y) =
        (x >= 0) &&
        (x < Array.length grid) &&
        (y >= 0) &&
        (y < Array.length grid.(x))
    in
    
    let xmas_length = String.length word in
    let positions = List.init xmas_length (fun i -> (x + i * dx, y + i * dy)) in

    if List.for_all is_valid_pos positions then
        let char_append str (x, y) = str ^ (String.make 1 grid.(x).(y)) in
        let extracted = List.fold_left char_append "" positions in
        extracted = word
    else
        false
    

let is_xmas: search_function = fun ~pos ~grid ->
    let directions = [(1, 0); (-1, 0); (0, 1); (0, -1); (1, 1); (-1, 1); (1, -1); (-1,-1)] in
    List.filter (is_word_in_dir ~pos ~grid "XMAS") directions |> List.length



let rec find_in_grid ~(pos:int*int) ~(f:search_function) ~(sum:int) (grid:grid): int =
    match pos with
    | (x, _) when x = Array.length grid -> sum
    | (x, y) when y = Array.length grid.(x) -> find_in_grid ~pos:(x+1,0) ~f ~sum grid
    | (x, y) -> begin
        let sum = sum + f ~pos ~grid in
        find_in_grid ~pos:(x, y+1) ~f ~sum grid
    end


let question1 (filename: string) =
    let input = Util.Input.read_lines filename in
    let grid = parse_grid input in

    let sum = find_in_grid ~pos:(0,0) ~f:is_xmas ~sum:0 grid in

    Printf.sprintf "%d" sum

let is_x_mas: search_function = fun ~pos ~grid ->
    (* (-1, -1)    (-1, 1) *)
    (*          x         *)
    (* (1, -1)     (1, 1) *)

    (*M   S *)
    (*  A  *)
    (*M   S*)
    let ws = is_word_in_dir ~pos ~grid in
    let is_valid =
        ((ws "AS" (-1,1) && ws "AM" (1,-1))  || (ws "AM" (-1,1) && ws "AS" (1,-1))) &&
        ((ws "AS" (1,1)  && ws "AM" (-1,-1)) || (ws "AM" (1,1) && ws "AS" (-1,-1)))
    in
    if is_valid then 1 else 0
        

let question2 (filename: string) =
    let input = Util.Input.read_lines filename in
    let grid = parse_grid input in

    let sum = find_in_grid ~pos:(0,0) ~f:is_x_mas ~sum:0 grid in

    Printf.sprintf "%d" sum
