
[<EntryPoint>]
let main argv =
    match argv.[0] with
    | "1" -> Day1.solution "1/input"
    | "2" -> Day2.solution "2/input"
    | "3" -> Day3.solution "3/input"
    | "4" -> Day4.solution "4/input"
    | "5" -> Day5.solution "5/input"
    | "6" -> Day6.solution "6/input"
    | "7" -> Day7.solution "7/input"
    | _ -> printf "Nothing selected"
    
    0