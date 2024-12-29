type equation = {
    result: int;
    values: int list
} [@@deriving show]


module type OperatorsDef = sig
    type t
    val base : t
    val next : t -> t option
    val apply : int -> int -> t -> int
end

module Make_Operators(Def: OperatorsDef) = struct
    include Def
    
    let are_operators_valid (eq: equation) (operators: t list) =
        let first_value = List.hd eq.values in
        let remaining_values = List.tl eq.values in
        let intermediate = List.fold_left2 apply first_value remaining_values operators in
        intermediate == eq.result

    let next_permutation (previous: t list) =
        (*
            we go through the previous list of operations and flip all operations in the list (from left to right) to
            the next. If we have a next operation, stop the recursion. If we no next operation, use the base one and
            recurse into flipping the next position in the list.

            0 0 0
            1 0 0   -> flip the first pos and stop
            2 0 0   -> flip the first pos and stop
            0 1 0   -> no new operation at the first pos, so use base and flip the second pos
            1 1 0
            . . .
            2 2 0
            0 0 1   -> use the base for the first, move to second. use the base, move the third, flip to next position
        *)
        let rec flip ops =
            match ops with
            | [] -> []
            | x::xs -> begin
                match next x with
                | None -> base::(flip xs)
                | Some o -> o::xs
            end
        in
    flip previous

    let is_valid_equation (eq: equation): bool =
        let num_operators = (List.length eq.values) - 1 in
        let initial_operators = List.init num_operators (fun _ -> base) in
        let is_last_operators operators = List.for_all (fun o -> None == next o) operators in

        let rec check_step current_operators =
            match are_operators_valid eq current_operators with
            | true -> true
            | false -> begin
                match is_last_operators current_operators with
                | true -> false
                | false -> check_step (next_permutation current_operators)
            end
        in
        
        check_step initial_operators
end

module Q1_Operators = Make_Operators( struct
    type t = Add | Mul [@@deriving show]

    let base = Add

    let next = function
    | Add -> Some Mul
    | Mul -> None

    let apply v1 v2 op =
        match op with
        | Add -> v1 + v2
        | Mul -> v1 * v2
end)

module Q2_Operators = Make_Operators(struct
    type t = Add | Mul | Con [@@deriving show]

    let base = Add

    let next = function
    | Add -> Some Mul
    | Mul -> Some Con
    | Con -> None

    let apply v1 v2 op =
        match op with
        | Add -> v1 + v2
        | Mul -> v1 * v2
        | Con -> (string_of_int v1) ^ (string_of_int v2) |> int_of_string
end)

let (>>) f g x = g(f(x))

let parse_line (line: string): equation =
    let regex = Re.Pcre.regexp "([0-9]+):(.*)" in
    let m = Re.exec regex line in
    let result = Re.Group.get m 1 |> int_of_string in
    let operands = Re.Group.get m 2
        |> StringLabels.split_on_char ~sep:' '
        |> List.filter (fun s -> not ((String.equal "" s) || (String.equal " " s)))
        |> List.map int_of_string
    in
    {result=result; values=operands}

let test_values = Util.Input.read_lines "input/test7.txt"


let question1 (filename: string) =
    let input = Util.Input.read_lines filename in
    let equations = List.map parse_line input in

    let sum =
        equations
        |> List.filter Q1_Operators.is_valid_equation
        |> List.fold_left (fun sum e -> sum + e.result) 0
    in

    Printf.sprintf "%u" sum


let question2 (filename: string) =
    let input = Util.Input.read_lines filename in
    let equations = List.map parse_line input in

    let sum =
        equations
        |> List.filter Q2_Operators.is_valid_equation
        |> List.fold_left (fun sum e -> sum + e.result) 0
    in

    Printf.sprintf "%u" sum
