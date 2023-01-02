open System
open System.Text.RegularExpressions

let (|ParseRegex|_|) pattern str =
    let m = Regex.Match(str, pattern)
    if m.Success then Some (List.tail [for x in m.Groups -> x.Value])
    else None

type LogType = Change | Sleep | Awake
type LogEntry = {ts: DateTime; id: int; change: LogType} with
    static member Parse last_id line =
        let timestamp =
            match line with
            | ParseRegex "\[(1518\-\d{2}\-\d{2} \d{2}:\d{2})\].*" l ->  System.DateTime.Parse (List.head l)
            | _ -> invalidArg "line" "unable to parse date"
        let update =
            match line with
            | ParseRegex ".*Guard #(\d+) begins shift" [id] -> Change, Some (int id)
            | ParseRegex ".*falls asleep" _                 -> Sleep, last_id
            | ParseRegex ".*wakes up" _                     -> Awake, last_id
            | _                                             -> invalidArg "line" "unable to parse log" 
        match update with
        | c, Some id -> {ts = timestamp; id = id; change = c}
        | _, None    -> invalidArg "last_id" "no id was detected"


let minutesBetween (l1) (l2) =
    assert (l1.ts.Minute < l2.ts.Minute)
    assert (l1.id = l2.id)
    [l1.ts.Minute..l2.ts.Minute-1]

let updateEntryForGuard state (e1, e2) =
    let id = e2.id
    let exMin = try Map.find id state with _ -> []
    // we are only interested in time sleeping, so check for sleep -> awake change
    // and update the entry in the map with the new minutes asleep
    match e1.change, e2.change with
    | Sleep, Awake -> Map.add id (List.append (minutesBetween e1 e2) exMin) state
    | _ -> state

let part1 logs =
    let timetable = logs |> Seq.pairwise |> Seq.fold updateEntryForGuard Map.empty
    let (guardId, minutesSleeping) =
        Map.toSeq timetable |> Seq.maxBy (fun (id, sleepMin) -> Seq.length sleepMin)
    let optimalMin =
        minutesSleeping |> Seq.countBy (fun i -> i) |> Seq.sortBy (fun (min, count) -> count) |> Seq.last
    (fst optimalMin) * guardId

let part2 logs =
    let timetable = logs |> Seq.pairwise |> Seq.fold updateEntryForGuard Map.empty
    let maxTimesById =
        timetable
        |> Map.map (fun _ mins -> mins |> Seq.countBy id |> Seq.maxBy (fun (min, x) ->  x))
    let m = Map.toSeq maxTimesById |> Seq.maxBy (fun (id, (min, x)) -> x)
    (fst m) * (snd >> fst) m

[<EntryPoint>]
let main argv =
    let lines = System.IO.File.ReadLines argv.[0]
    let logs = lines
            |> Seq.sort
            |> Seq.mapFold (fun last_id line ->
                let entry = LogEntry.Parse last_id line
                (entry, Some entry.id)) None
            |> fst
    printf "%A\n" (part1 logs)
    printf "%A\n" (part2 logs)
    
    0
