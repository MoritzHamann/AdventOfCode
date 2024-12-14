module String = struct

    let extended_split ~sep ?(keep_empty=false) input_string =
        let splits = StringLabels.split_on_char ~sep input_string in
        if keep_empty then
            splits
        else
            List.filter (fun s -> not (String.equal s "")) splits

end


module List = struct

    let transpose list =
        let line_acc (result1, result2) row =
            let first = List.hd row in
            let second = List.nth row 1 in
            (first :: result1, second :: result2)
        in
        let (r1, r2) = List.fold_left line_acc ([], []) list in
        [List.rev r1; List.rev r2]

    let remove_index i list =
        let rec remove acc current list =
            match list with
            | [] -> List.rev acc
            | x::xs ->
                let next = current + 1 in
                if current == i then
                    remove acc next xs
                else
                    remove (x::acc) next xs
        in
        remove [] 0 list

end

module type StringParser = sig
    type t
    val of_string: string -> t
end

(*let m = (module struct*)
(*    type t = int*)
(*    let of_string s = int_of_string s*)
(*end: Util.StringParser with type t = int)*)
(*in*)

type filename = string

module Input = struct
    let read_lines (filename: filename): string list =
        let channel = open_in filename in
        In_channel.input_lines channel
        
    let read_lines_as (type a) (module Parser: StringParser with type t = a) filename: a list = 
        let channel = open_in filename in
        let lines = In_channel.input_lines channel in
        Stdlib.List.map Parser.of_string lines
end


let%test "remove first element from list" =
    let input = [1;2;3;4;5] in
    let remove_first = List.remove_index 0 input in
    Stdlib.List.equal Int.equal remove_first [2;3;4;5]
    
let%test "remove list element from list" =
    let input = [1;2;3;4;5] in
    let remove_last = List.remove_index 4 input in
    Stdlib.List.equal Int.equal remove_last [1;2;3;4]

let%expect_test "split" =
    let input = "Some String with spaces" in
    let output = String.extended_split ~sep:' ' input in
    Stdlib.List.iter (fun s -> Printf.printf "%s," s) output;
    [%expect {| Some,String,with,spaces, |}]

let%expect_test "split with keep_empty" =
    let input = "Some String  with   spaces" in
    let output = String.extended_split ~sep:' ' ~keep_empty:true input in
    Stdlib.List.iter (fun s -> Printf.printf "%s," s) output;
    [%expect {| Some,String,,with,,,spaces, |}]

    
