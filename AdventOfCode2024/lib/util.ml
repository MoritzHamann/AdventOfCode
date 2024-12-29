module String = struct

    let extended_split ~sep ?(keep_empty=false) input_string =
        let splits = StringLabels.split_on_char ~sep input_string in
        if keep_empty then
            splits
        else
            List.filter (fun s -> not (String.equal s "")) splits

end


module List = struct

    let shift_right ~(until: 'a list -> bool) (element: 'a) (list: 'a list) =
        let rec loop left right element =
            let new_list = left @ element::right in
            match until new_list with
            | true -> Some new_list
            | false -> match right with
                        | [] -> None
                        | _ -> loop (List.append left [List.hd right]) (List.tl right) element
        in
        loop [] list element
            
    let chunk num list =
        let add_to_chunk chunks element =
            match chunks with
            | [] -> [[element]]
            | c::rest when List.length c = num -> [element]::(List.rev c)::rest
            | c::rest -> (element::c)::rest
                
        in
        List.fold_left add_to_chunk [[]] list |> List.rev

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

module Print = struct
    let list ?(endline="\n") fmt l =
        Stdlib.List.iter (Printf.printf fmt) l;
        Printf.printf "%s" endline
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

let%expect_test "shift element to right" =
    let list = [1;2;3] in
    let checker = (fun l -> Stdlib.List.nth l 1 = 4) in
    let result = List.shift_right ~until:checker 4 list in
    match result with
    | None ->
        begin
            Printf.printf "%s" "None";
            [%expect.unreachable]
        end
    | Some l -> begin
            Print.list "%d," l;
            [%expect {| 1,4,2,3, |}]
        end

let%expect_test "shift element to right: unable to fullfill criteria" =
    let list = [1;2;3] in
    let checker = (fun l -> Stdlib.List.nth l 1 = 5) in
    let result = List.shift_right ~until:checker 4 list in
    match result with
    | Some l ->
        begin
            Print.list "%d," l;
            [%expect.unreachable]
        end
    | None ->
        begin
            Printf.printf "%s" "None";
            [%expect {| None |}]
        end

let%expect_test "shift element to right: unable to fullfill criteria" =
    let list = [] in
    let checker = (fun l -> Stdlib.List.nth l 0 = 4) in
    let result = List.shift_right ~until:checker 4 list in
    match result with
    | Some l ->
        begin
            Print.list "%d," l;
            [%expect {| 4, |}]
        end
    | None ->
        begin
            Printf.printf "%s" "None";
            [%expect.unreachable]
        end

let%expect_test "chunk list into two elements" =
    let input = [1;2;3;4;5] in
    let chunks = List.chunk 2 input in
    Stdlib.List.iter (Print.list "%d,") chunks;
    [%expect {|
      1,2,
      3,4,
      5,
      |}]

