let contains s x =
    s |> Seq.countBy (fun i -> i) |> Seq.filter (fun i ->(snd i) = x) |> Seq.length |> min 1

let areSame (e1, e2) = e1 = e2
let areDiff (e1, e2) = e1 <> e2

let differInOneChar (s1, s2) =
    let numDiffs = Seq.zip s1 s2 |> Seq.filter areDiff |> Seq.length
    numDiffs = 1

let similarities (s1, s2) =
    Seq.zip s1 s2 |> Seq.filter areSame |> Seq.map (fun i -> fst i)

let part1 lines =
    let (doubles, tribles) = lines |> Seq.map (fun i -> (contains i 2, contains i 3))
                                   |> Seq.fold (fun (d,t) (ds, ts) -> (d+ds, t+ts)) (0,0)
    doubles * tribles

// may not be correct with sorting, but for our input it works
let part2 lines =
    lines |> Seq.sort |> Seq.pairwise |> Seq.find differInOneChar
          |> similarities |> Seq.map string |> String.concat ""

[<EntryPoint>]
let main argv =
    assert not (Array.isEmpty argv)
    let fileName = argv.[0]
    let lines = System.IO.File.ReadLines fileName
    printf "%i\n" (part1 lines)
    printf "%s\n" (part2 lines)
    0