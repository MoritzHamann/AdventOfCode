open System.Text.RegularExpressions

type Rect = {id:int; x: int; y: int; w: int; h: int}

let parseLine line =
    let m = Regex.Match(line, "#(\d+) @ (\d+),(\d+): (\d+)x(\d+)")
    assert m.Success
    {
        id = int(m.Groups.[1].Value)
        x  = int(m.Groups.[2].Value)
        y  = int(m.Groups.[3].Value)
        w  = int(m.Groups.[4].Value)
        h  = int(m.Groups.[5].Value)
    }

let incFields (state:(int * int list)[][]) r = 
    for x = r.x to r.x + r.w - 1 do
        for y = r.y to r.y + r.h - 1 do
            state.[x].[y] <- (fst state.[x].[y] + 1, r.id::(snd state.[x].[y]))
    state

let visFields (state:int[][]) =
    for x = 0 to 9 do
        for y = 0 to 9 do
            printf "%A " state.[x].[y]
        printf "\n"

let part1 rects =
    let overlapping x = Seq.filter (fun i -> (fst i) >= x) >> Seq.length
    let state = Array.init 3000 (fun i -> Array.init 3000 (fun i -> (0, [])))
    let state = rects |> Seq.fold incFields state
    state  |> Seq.map (overlapping 2) |> Seq.sum


let intersectsH a b = 
    match a.x < b.x with
    | true -> b.x < a.x + a.w
    | false -> a.x < b.x + b.w
let intersectsV a b =
    match a.y < b.y with
    | true  -> b.y < a.y + a.h
    | false -> a.y < b.y + b.h
let overlaps a b =
    intersectsH a b && intersectsV a b

let testAgainstAll state rect =
    let intersections = Map.filter (fun r _ -> overlaps r rect) state
    let updateState r count =
        match Map.containsKey r intersections with
        | true -> (count + 1)
        | false -> count
    let state = Map.map updateState state
    Map.add rect (Map.count intersections) state
   

let part2 rects =
    let state = Seq.fold testAgainstAll Map.empty rects
    let r = Map.filter (fun r c -> c = 0) state |> Map.toSeq |> Seq.item 0 |> fst
    r.id

[<EntryPoint>]
let main argv =
    assert not (Array.isEmpty argv)
    let rects = System.IO.File.ReadLines argv.[0] |> Seq.map parseLine
    printf "%A\n" (part1 rects)
    printf "%A\n" (part2 rects)
    0
