
module IntSet = Set.Make(Int)
module IntMap = Map.Make(Int)

type rules = IntSet.t IntMap.t
type updates = int list list
type line = string
type line_parser = (rules * updates) -> line -> (rules * updates)
type parser = state:(rules * updates) -> next:line_parser -> line list -> (rules * updates)
exception InvalidRule


let parse_rule state line =
    let (rules, updates) = state in

    let add_rule before after =
        let rule = IntMap.find_opt before rules |> Option.value ~default:IntSet.empty in
        let updated_rule = IntSet.add after rule in
        IntMap.add before updated_rule rules
    in

    let rules = Scanf.sscanf line "%d|%d" add_rule in
    (rules, updates)

let parse_updates (state:rules*updates) (line:string): rules*updates =
    let (rules, updates) = state in
    let new_updates = StringLabels.split_on_char ~sep:',' line |> List.map int_of_string in
    (rules, new_updates::updates)

let rec parse_all_lines: parser = fun ~state ~next lines ->
    match lines with
    | [] -> state
    | x::xs -> begin
        match x with
        | "" -> parse_all_lines ~state ~next:parse_updates xs
        | _ -> begin
            let new_state = next state x in
            parse_all_lines ~state:new_state ~next xs
        end
    end

let parse_lines_into_rules_and_updates (lines: string list): (rules * updates) =
    let rules = IntMap.empty in
    let updates = [] in
    parse_all_lines ~state:(rules, updates) ~next:parse_rule lines

let get_middle_point l = List.nth l ((List.length l) / 2)

let is_valid_update ~(rules:rules) (update:int list): bool =
    let is_valid_position (previous:int list) (current:int) =

        match IntMap.find_opt current rules with
        | None -> current::previous
        | Some set -> begin
            let is_valid = List.for_all (fun p -> not (IntSet.mem p set)) previous in
            match (previous, is_valid) with
            | [], _ -> current::previous
            | _, true -> current::previous
            | _, false -> raise InvalidRule
            
        end
    in
    try List.fold_left is_valid_position [] update |> ignore; true
    with | InvalidRule -> false


let test () = Util.Input.read_lines "input/test5.txt"
let test_update = [75;47;61;53;29]

let question1 (filename: string) =
    (*let lines = test in*)
    let lines = Util.Input.read_lines filename in
    let (rules, updates) = parse_lines_into_rules_and_updates lines in
    
    updates
    |> List.filter (is_valid_update ~rules)
    |> List.map get_middle_point
    |> List.fold_left (+) 0
    |> Printf.sprintf "%d"


let (>>) f g x = g (f x)

(** Idea:
    we build up the new update element by element.
    for each element we shift it to the right (towards the end of the list)
    until the update is valid.
    *)
let correct_update ~rules (update:int list) =
    let checker = is_valid_update ~rules in
    let insert_element new_update element =
        let result = Util.List.shift_right ~until:checker element new_update in
        match result with
        | None -> raise InvalidRule
        | Some l -> l
    in
    List.fold_left insert_element [] update

let question2 (filename: string) =
    let lines = Util.Input.read_lines filename in
    (*let lines = test () in*)
    let (rules, updates) = parse_lines_into_rules_and_updates lines in

    updates
    |> List.filter (is_valid_update ~rules >> not)
    |> List.map (correct_update ~rules)
    |> List.map get_middle_point
    |> List.fold_left (+) 0
    |> Printf.sprintf "%d"
