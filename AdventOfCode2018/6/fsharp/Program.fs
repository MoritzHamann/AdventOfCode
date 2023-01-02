open System
open System.Text.RegularExpressions

type Point = {x:int; y:int} with
    static member New x y = {x = x; y = y}
    static member Origin = Point.New 0 0
    static member Parse line =
        let m = Regex.Match(line, "(\d+), (\d+)")
        {x = int(m.Groups.[1].Value); y=int(m.Groups.[2].Value)}
    member this.distanceTo p =
        abs(this.x - p.x) + abs(this.y - p.y)

let nearestPoint (p:Point) points =
    let mutable minDistance = None
    let mutable sameDistance = false
    let mutable minId = None
    points |> Seq.indexed |> Seq.iter (fun (id, px) ->
        let distance = p.distanceTo px
        match minDistance with
        | None -> minDistance <- Some distance; minId <- Some id
        | Some d when d > distance -> minDistance <- Some distance; minId <- Some id
        | Some d when d = distance -> sameDistance <- true
        | _ -> ()
    ) 
    if sameDistance then None else minId
    
let boundingBox points = 
    points
    |> Seq.fold (fun (left, right) p ->
        let lx = if left.x < p.x then left.x else p.x
        let ly = if left.y < p.y then left.y else p.y
        let rx = if right.x > p.x then right.x else p.x
        let ry = if right.y > p.y then right.y else p.y
        (Point.New lx ly, Point.New rx ry)
    ) (Point.New 1000 1000, Point.Origin)

let idsOnBoundaryBox points (min, max) =
    let vertPoints x yRange = Seq.map (fun y -> {x = x; y = y}) yRange
    let horzPoints xRange y = Seq.map (fun x -> {x = x; y = y}) xRange
    let top = horzPoints [min.x..max.x] min.y
    let bottom = horzPoints [min.x..max.x] max.y
    let left = vertPoints min.x [min.y..max.y]
    let right = vertPoints max.x [min.y..max.y]

    Seq.concat [top; bottom; left; right]
    |> Seq.map (fun p -> nearestPoint p points)
    |> Seq.distinct
    |> Seq.filter (fun p -> p.IsSome)
    |> Seq.map (fun (Some p) -> p)

let part1 points =
    let (topLeft, bottomRight) = boundingBox points
    let sizePerId = Array.zeroCreate (points |> Seq.length)
    let idsOfInfiniteAreas = idsOnBoundaryBox points (topLeft, bottomRight)
    printf "%A" topLeft
    printf "%A" bottomRight
    for x = topLeft.x to bottomRight.x do
        for y = topLeft.y to bottomRight.y do
            let currentLoc = Point.New x y
            match nearestPoint currentLoc points with
            | Some id -> sizePerId.[id] <- sizePerId.[id] + 1
            | _ -> ()

    Array.indexed sizePerId
    |> Array.filter (fun (id, _) -> not(Seq.contains id idsOfInfiniteAreas))
    |> Array.maxBy snd |> snd

let part2 points =
    let (min, max) = boundingBox points
    let mutable counts = 0
    for x = min.x to max.x do
        for y = min.y to max.y do
            let currentPos = Point.New x y
            let totalDistance = points |> Seq.map currentPos.distanceTo |> Seq.sum
            if totalDistance < 10000 then counts <- counts + 1 else ()
    counts

[<EntryPoint>]
let main argv =
    let points = System.IO.File.ReadLines argv.[0] |> Seq.map Point.Parse
    part1 points |> printf "%A\n"
    part2 points |> printf "%A\n"
    0
