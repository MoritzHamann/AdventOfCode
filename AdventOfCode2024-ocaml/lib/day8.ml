type frequency = char
type coord = {row: int; column: int} [@@deriving show]

module FreqMap = Map.Make(Char)

module CoordSet = Set.Make(struct
    type t = coord
    let compare = compare
end)

module CoordMap = Map.Make(struct type
    t = coord
    let compare = compare
end)

module Grid = struct

    include CoordMap

    type grid = frequency CoordMap.t
    type t = {
         map: grid;
         height: int;
         width: int;
    }

    let pp_t fmt (t:t) =
        for y = 0 to t.height do
            for x = 0 to t.width do
                match find_opt {row=y; column=x} t.map with
                | None -> Format.fprintf fmt "."
                | Some c -> Format.fprintf fmt "%c" c
            done;
            Format.fprintf fmt "\n";
        done

    let of_lines (lines: string list): t =
        let add_freq ~row ~column ~map freq = add {row;column} freq map in

        let parse_freq ~row map column char =
            match char with
            | c when c == '.' -> map
            | c -> add_freq ~row ~column ~map c
        in

        let parse_line (freq:grid) (row: int) (line:string): grid =
            let string_seq = String.to_seq line in
            Seq.fold_lefti (parse_freq ~row) freq string_seq
        in

        let seq = List.to_seq lines in
        let map = Seq.fold_lefti parse_line empty seq in

        {map=map; height=List.length lines; width=String.length ( List.hd lines)}

    let group_by_frequency (t:t): CoordSet.t FreqMap.t =

        let collect_frequency_location freq_to_coords (coordinate, freq) =
            freq_to_coords |> FreqMap.update freq (fun old_set ->
                match old_set with
                | Some set -> Some (CoordSet.add coordinate set)
                | None -> Some (CoordSet.(empty |> add coordinate))
            )
        in

        let empty: CoordSet.t FreqMap.t = FreqMap.empty in
        let values = bindings t.map in
        List.fold_left collect_frequency_location empty values

    let contains t coord =
        coord.row >= 0 && coord.row < t.height && coord.column >= 0 && coord.column < t.width
end

let find_antinodes ((left, right):coord * coord): coord list =
    let dy = left.row - right.row in
    let dx = left.column - right.column in
    
    [
        {row=left.row+dy;column=left.column+dx};
        {row=right.row-dy;column=right.column-dx};
    ]

let find_antinodes_with_harmonic ~(grid:Grid.t) ((left, right):coord * coord): coord list =
    let dy = left.row - right.row in
    let dx = left.column - right.column in

    let rec extend ~dx ~dy (last_coord) =
        let new_coord = {row=last_coord.row+dy;column=last_coord.column+dx} in
        match Grid.contains grid new_coord with
        | false -> []
        | true -> new_coord::(extend ~dx ~dy new_coord)
    in
    
    let left_extension = extend ~dx:dx ~dy:dy left in
    let right_extension = extend ~dx:(-dx) ~dy:(-dy) left in

    List.flatten [left_extension; right_extension; [left; right]]

let rec pair_permutations (coords: CoordSet.t) =
    match CoordSet.cardinal coords with
    | num when num == 0 -> []
    | _ -> begin
        let next_coord = CoordSet.find_first (fun _ -> true) coords in
        let new_set = CoordSet.remove next_coord coords in
        let permutations = CoordSet.fold (fun coord list -> (next_coord, coord)::list) new_set [] in
        List.append permutations (pair_permutations new_set)
    end

let antinodes_for_freq ~(grid:Grid.t) (_:frequency) (coordinates: CoordSet.t) (all_antinodes: CoordSet.t): CoordSet.t =
    let permutations = pair_permutations coordinates in
    let antinodes =
        List.map find_antinodes permutations
        |> List.flatten
        |> List.filter (Grid.contains grid)
    in
    CoordSet.add_seq (List.to_seq antinodes) all_antinodes

let question1 (filename: string) =
    let lines = Util.Input.read_lines filename in
    let m = Grid.of_lines lines in
    
    let groups = Grid.group_by_frequency m in
    let antinodes = FreqMap.fold (antinodes_for_freq ~grid:m) groups CoordSet.empty in

    Printf.sprintf "%d" (CoordSet.cardinal antinodes)

let question2 (filename: string) =
    let lines = Util.Input.read_lines filename in
    let m = Grid.of_lines lines in
    
    let groups = Grid.group_by_frequency m in
    let antinodes = FreqMap.fold (fun (_:frequency) (coords: CoordSet.t) (all_antinodes: CoordSet.t) ->
        let permutations = pair_permutations coords in
        let antinodes =
            List.map (find_antinodes_with_harmonic ~grid:m) permutations
            |> List.flatten
            |> List.filter (Grid.contains m)
        in
        CoordSet.add_seq (List.to_seq antinodes) all_antinodes

    ) groups CoordSet.empty in

    Printf.sprintf "%d" (CoordSet.cardinal antinodes)
