let read_lines filename =
    let channel = open_in filename in
    In_channel.input_lines channel

let parse_line pattern receiver line =
    Scanf.sscanf line pattern receiver

let parse_input filename =
    read_lines filename
    |> List.map (parse_line "%u %u" (fun i1 i2 -> (i1, i2)))
    |> List.split

let similarity_score number list =
    let occurences = List.filter (Int.equal number) list |> List.length in
    occurences * number



let question1 (filename:string): string =
    let (first_list, second_list) = parse_input filename in
    let first_list = List.sort Int.compare first_list in
    let second_list = List.sort Int.compare second_list in
    let sum = List.fold_left2 (fun sum v1 v2 ->
        sum + abs(v1 - v2)
    ) 0 first_list second_list
    in
    Printf.sprintf "%u" sum


let question2 (filename:string) =
    let (first, second) = parse_input filename in
    let sum = List.fold_left (fun sum element ->
        sum + (similarity_score element second)
    ) 0 first
    in
    Printf.sprintf "%u" sum
