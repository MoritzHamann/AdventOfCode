module Day1

let mass (weight:int) = weight / 3 - 2
let rec totalMass (weight:int) = 
    let fuelMass = mass weight
    if fuelMass <= 0 then
        0
    else
        fuelMass + totalMass fuelMass


let Solve1() = 
    let input = 
        System.IO.File.ReadAllLines("./day1/input")
        |> Array.sumBy (int >> mass)
    printf "%A\n" input

let Solve2() = 
    let input = 
        System.IO.File.ReadAllLines("./day1/input")
        |> Array.sumBy (int >> totalMass)
    printf "%A\n" input