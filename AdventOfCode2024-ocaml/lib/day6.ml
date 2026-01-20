
type direction = Up | Down | Left | Right
type pos = {x:int; y:int}
type orientation = {pos: pos; dir: direction}
type guard = {pos: pos; dir: direction; on_grid: bool; visited: (orientation, bool) Hashtbl.t}

type cell = Obstacle | Free
type grid = cell array array

module PosSet = Set.Make (struct
    type t = pos
    let compare = Stdlib.compare
end)

(*have to thread the position through the fold state as well*)
let parse_cell ~(grid:grid) (state:guard * pos) char =
    let (guard, pos) = state in
    let cell = match char with
        | '#' -> Obstacle
        | '^' -> Free
        | _ -> Free
    in
    let guard = match char with
        | '^' -> begin
                Hashtbl.add guard.visited {pos;dir=Up} true;
                {guard with pos=pos}
            end
        | _ -> guard
    in
    grid.(pos.x).(pos.y) <- cell;
    let pos = {pos with y = pos.y + 1} in
    (guard, pos)

let parse_line ~(grid:grid) (state:guard * pos) (line:string): (guard * pos) =
    let (guard, pos) = state in
    let (guard, pos) = String.fold_left (parse_cell ~grid) (guard, {pos with y = 0}) line in
    (guard, {pos with x = pos.x + 1})

let parse_input (lines: string list): (grid * guard) =
    let initial_guard = {pos={x=0;y=0}; dir=Up; on_grid=true; visited=Hashtbl.create 1} in
    let height = List.length lines in
    let width = String.length (List.hd lines) in
    let grid = Array.make_matrix height width Free in
    let (guard, _) = List.fold_left (parse_line ~grid) (initial_guard, {x=0;y=0}) lines in
    (grid, guard)

let dir_to_offset = function
    | Up -> (-1, 0)
    | Down -> (1, 0)
    | Left -> (0, -1)
    | Right -> (0, 1)

let turn_right = function
    | Up -> Right
    | Down -> Left
    | Left -> Up
    | Right -> Down

let advance_guard ~grid guard =
    let (dx, dy) = dir_to_offset guard.dir in
    let next_pos = {x=guard.pos.x + dx; y = guard.pos.y + dy} in
    let next_pos_outside = next_pos.x < 0 || next_pos.y < 0 ||
                           next_pos.x >= Array.length grid || next_pos.y >= Array.length grid.(next_pos.x)
    in
    match next_pos_outside with
        | true  -> {guard with on_grid = false}
        | false -> begin
            let next_cell = grid.(next_pos.x).(next_pos.y) in
            match next_cell with
            | Obstacle ->  begin
                    let new_dir = turn_right guard.dir in
                    {guard with dir = new_dir}
                end
            | _ -> begin
                {guard with pos = next_pos}
            end
        end

let rec move_guard ~grid ~until guard =
    match until guard with
    | true -> guard
    | false -> begin
        let new_guard = (advance_guard ~grid guard) in
        Hashtbl.add guard.visited {pos=guard.pos;dir=guard.dir} true;
        move_guard ~until ~grid new_guard
    end


let question1 filename =
    let input = Util.Input.read_lines filename in
    let (grid, guard) = parse_input input in

    let stop_condition guard = not guard.on_grid in
    let moved_guard = move_guard ~until:stop_condition ~grid guard in

    let get_unique_positions set (o:orientation) = PosSet.add o.pos set in
    let sum = Hashtbl.to_seq moved_guard.visited
        |> Seq.fold_left (fun set (o, _) -> get_unique_positions set o) PosSet.empty
        |> PosSet.cardinal
    in
    (*let sum = List.fold_left get_unique_positions PosSet.empty moved_guard.visited |> PosSet.cardinal in*)
    Printf.sprintf "%d" sum

let new_grid_with_obstacle ~(pos:pos) (grid:grid) =
    let new_grid = Array.copy grid in
    Array.iteri (fun x array -> new_grid.(x) <- Array.copy array) new_grid;
    new_grid.(pos.x).(pos.y) <- Obstacle;
    new_grid

let copy_guard guard =
    let htb = Hashtbl.create 1 in
    Hashtbl.add htb {pos=guard.pos;dir=guard.dir} true;
    {guard with visited = htb}

let question2 filename =
    let input = Util.Input.read_lines filename in
    let (grid, initial_guard) = parse_input input in

    (* do a normal run first to get all positions the guard will visit in the first place *)
    let stop_condition guard = not guard.on_grid in
    let guard = copy_guard initial_guard in
    let moved_guard = move_guard ~until:stop_condition ~grid guard in

    let collect_unique list element =
        match List.mem element list with
        | true -> list
        | false -> element::list
    in
    let guard_positions =
        Hashtbl.to_seq_keys moved_guard.visited
        |> Seq.map (fun (o:orientation) -> o.pos)
        |> Seq.filter (fun p -> p <> initial_guard.pos && grid.(p.x).(p.y) = Free)
        |> Seq.fold_left collect_unique []
    in

    (* new stop condition for the infinte loop *)
    let stop_condition (g:guard) =
        not g.on_grid ||
        (Hashtbl.length g.visited > 1 && ((Hashtbl.find_opt g.visited {pos=g.pos; dir=g.dir}) |> Option.is_some))
    in
    
    let test_run sum pos =
        let new_grid = new_grid_with_obstacle ~pos grid in
        let guard = copy_guard initial_guard in

        let moved_guard = move_guard ~until:stop_condition ~grid:new_grid guard in
        match moved_guard.on_grid with
        | true -> sum + 1
        | false -> sum
    in

    (* sequencial *)
    (*let sum = List.fold_left test_run 0 guard_positions in*)

    (* parallel *)
    let num_domains = Domain.recommended_domain_count () in
    Printf.printf "Running %d domains in parrallel\n%!" num_domains;

    let chunks = Util.List.chunk num_domains guard_positions in
    let domains = List.map (fun chunk -> 
        Domain.spawn (fun _ -> List.fold_left test_run 0 chunk)
    ) chunks
    in
    let sum = List.fold_left (fun sum d -> sum + Domain.join d) 0 domains in
    Printf.sprintf "%d" sum
