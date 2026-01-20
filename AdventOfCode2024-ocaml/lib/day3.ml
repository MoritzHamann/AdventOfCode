
let get_all_matches_of_line (regex:Re.re) (line:string): (int * int) list =
    let rec get_match ~start =
        let substring = Re.exec_opt ~pos:start regex line in
        match substring with
        | Some hit ->
            let first = Re.Pcre.get_substring hit 1 |> int_of_string in
            let second = Re.Pcre.get_substring hit 2 |> int_of_string in
            let pair = (first, second) in
            let new_start = Re.Pcre.get_substring_ofs hit 2 |> snd in
            pair::(get_match ~start:new_start)
        | None -> []
    in
    get_match ~start: 0


let question1 () =
    let input = Util.Input.read_lines "input/day3.txt" in
    let regex = Re.Pcre.regexp  "mul\\((?<first>[0-9]{1,3}),(?<second>[0-9]{1,3})\\)" in
    let sum = input |> List.fold_left (fun sum line ->
        Re.all regex line
        |> List.map (fun group ->
            let first = Re.Pcre.get_substring group 1 |> int_of_string in
            let second = Re.Pcre.get_substring group 2 |> int_of_string in
            (first, second)
        )
        |> List.fold_left (fun line_sum (first, second) -> (first * second) + line_sum) sum
    ) 0 in
    Printf.sprintf "%d" sum


let all_matches (content:string) =
    let do_regex = Re.Pcre.re "do\\(\\)" in
    let dont_regex = Re.Pcre.re "don't\\(\\)" in
    let mul_regex = Re.Pcre.re "mul\\((?<first>[0-9]{1,3}),(?<second>[0-9]{1,3})\\)" in
    let combined_regex = Re.alt [do_regex; dont_regex; mul_regex] |> Re.compile in
    Re.all combined_regex content


let question2 () =
    let input = Util.Input.read_lines "input/day3.txt" in
    let input = List.fold_left String.cat "" input in
    let groups = all_matches input in
    let (sum, _) = List.fold_left (fun (sum, enabled) group ->
        match Re.Group.get group 0 with
        | s when s = "don't()" -> (sum, false)
        | s when s = "do()" -> (sum, true)
        | _ -> begin
            let first = Re.Pcre.get_substring group 1 |> int_of_string in
            let second = Re.Pcre.get_substring group 2 |> int_of_string in
            if enabled then
                (sum + (first * second), enabled)
            else
                (sum, enabled)
        end
    ) (0, true) groups
    in
    Printf.sprintf "%d" sum
