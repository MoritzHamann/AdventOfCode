module Day2

type IntComputer = {
    pos: int;
    program: int[];
}

let op1 program = program
let op2 program = program
let applyOp (comp:IntComputer) =
    let pos = comp.pos
    let prog = comp.program
    match prog.[pos] with
    | 1 -> {pos=pos+4; program=op1 prog}
    | 2 -> {pos=pos+4; program=op2 prog}
    | 99 -> {pos=Array.length prog; program=prog}
    | op -> raise(System.ArgumentException(sprintf "wrong operator %A at pos %A" op pos))

let programFinished comp =
    comp.pos >= Array.length comp.program


let Solve1() =
    let input =
        System.IO.File.ReadAllText("./day2/input").Split(",")
        |> Array.map int

    Array.set input 1 12
    Array.set input 2 2

    let mutable computer = {pos=0; program=input}
    while not (programFinished computer) do
        computer <- applyOp computer
    printf "%A\n" computer.program.[0]