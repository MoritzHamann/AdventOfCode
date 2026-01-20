let (>>) g f x  = f (g (x))

let read_file (filename: string): string list =
    let channel = open_in filename in
    In_channel.input_lines channel
    

let parse_input (lines: string list): int list list =
    let transform = StringLabels.split_on_char ~sep:' ' >> (List.map int_of_string) in
    List.map transform lines
        

let pairwise (list: 'a list): ('a * 'a) list =
    let rec pair_it_up list =
        match list with
        | [] -> []
        | [_] -> []
        | x::y::xs ->
            let element = (x, y) in
            element :: (pair_it_up (y::xs))
    in
    pair_it_up list

let is_same_direction (diff1, diff2) =
    if diff1 < 0 && diff2 < 0 then
        true
    else if diff1 > 0 && diff2 > 0 then
        true
    else
        false

let is_level_valid diff = abs(diff) >= 1 && abs(diff) <= 3

let safe_report (report: int list): bool =
    if List.length report < 2 then
        true
    else
        let diffs = pairwise report |> List.map (fun (prev, current) -> current - prev) in
        let in_range = List.for_all is_level_valid diffs in

        let diff_pairs = pairwise diffs in
        let same_direction = List.for_all is_same_direction diff_pairs in

        in_range && same_direction


let safe_report_with_dampener (report: int list): bool =
    if List.length report < 2 then
        true
    else
        (* [0; 1; ...; #levels-1]*)
        let range = List.init (List.length report) Fun.id in
        
        (* we pre-build the dampened reports by removing each level *)
        let dampened_reports = List.map (fun i -> Util.List.remove_index i report) range in
        let all_reports = report::dampened_reports in

        match List.find_opt safe_report all_reports with
        | Some _ -> true
        | None -> false   
   

let test_data = [
"7 6 4 2 1";
"1 2 7 8 9";
"9 7 6 2 1";
"1 3 2 4 5";
"8 6 4 4 1";
"1 3 6 7 9"
]

let question1 () =
    let reports = read_file "input/day2.txt" |> parse_input in
    let total = List.filter safe_report reports |> List.length in
    Printf.sprintf "%d" total

let question2 () =
    let reports = read_file "input/day2.txt" |> parse_input in
    let total = List.filter safe_report_with_dampener reports |> List.length in
    Printf.sprintf "%d" total
