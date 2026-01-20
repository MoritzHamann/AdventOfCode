module Day1
    module Seq = let rec cycle xs = seq { yield! xs; yield! cycle xs }

    let toNum (s:string) = int(s)

    let part1 fileName = 
        let lines = System.IO.File.ReadLines fileName
        //let freq = Seq.map toNum lines |> Seq.scan (+) 0 |> Seq.last
        let freq = Seq.map toNum lines |> Seq.sum
        printf "%i\n" freq

    let addToSet s e =
        let _, _, set = s
        match Set.contains e set with
        | true -> (1, e, set)
        | false -> (0, e, (Set.add e set))

    let part2 fileName =
        let lines = System.IO.File.ReadLines fileName
        let frequencies = Seq.map toNum lines
        let duplicate =
            Seq.cycle frequencies
            |> Seq.scan (+) 0
            |> Seq.scan addToSet (0, 0, Set.ofList [])
            |> Seq.find (fun pair ->
                let f, _, _ = pair
                f = 1)

        let _, el, _ = duplicate
        printf "%A\n" el

    let solution filename =
        part1 filename
        part2 filename
