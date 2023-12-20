module Day5
    open System

    let isReducable p1 p2 =
        Char.ToUpper p1 = p2 && Char.ToLower p2 = p1 ||
        Char.ToUpper p2 = p1 && Char.ToLower p1 = p2

    // let isReducableLetter l p1 p2 = 
    //     if p1 = p2 && p1 = l then Char.ToUpper p1 = Char.ToUpper p2 else false

    let collapse s =
        let rec coll remaining collPolymer = 
            match remaining with
            | p1::p2::xs when isReducable p1 p2 -> coll xs collPolymer
            | p1::xs -> coll xs (p1::collPolymer)
            | [] -> List.rev collPolymer
        coll s []

    let reducePolymer polymer = 
        polymer |> Seq.unfold (fun state -> let c = collapse state in Some(c, c))
                |> Seq.pairwise |> Seq.find (fun (p1, p2) -> p1 = p2)
                |> fst

    // stolen from the web
    let reduce polymer =
        List.foldBack (fun e state -> 
            match state with
            | x::xs when isReducable x e -> xs
            | _ -> e::state ) polymer []

    let part1 polymer =
        reduce polymer |> Seq.length

    let part2 polymer =
        ['a'..'z'] |> Seq.map (fun l -> polymer |> Seq.filter (fun c -> Char.ToLower c <> l))
                |> Seq.map (fun p -> reduce (Seq.toList p))
                |> Seq.minBy (fun s -> Seq.length s)
                |> Seq.length



    let solution filename =
        let polymer = Seq.toList (System.IO.File.ReadAllText filename)
        printf "%A\n" (part1 polymer)
        printf "%A\n" (part2 polymer)