open Aoc2024

let () =
    let result1 = Day1.question1 "input/day1.txt" in
    Printf.printf "Day 1.1: %s\n" result1;

    let result2 = Day1.question2 "input/day1.txt" in
    Printf.printf "Day 1.2: %s\n" result2;

    let result1 = Day2.question1 () in
    Printf.printf "Day 2.1: %s\n" result1;

    let result2 = Day2.question2 () in
    Printf.printf "Day 2.2: %s\n" result2;

    let result1 = Day3.question1 () in
    Printf.printf "Day 3.1: %s\n" result1;

    let result2 = Day3.question2 () in
    Printf.printf "Day 3.2: %s\n" result2;

    let result = Day4.question1 "input/day4.txt" in
    Printf.printf "Day 4.1: %s\n" result;

    let result = Day4.question2 "input/day4.txt" in
    Printf.printf "Day 4.2: %s\n" result;

    let result = Day5.question1 "input/day5.txt" in
    Printf.printf "Day 5.1: %s\n" result;

    let result = Day5.question2 "input/day5.txt" in
    Printf.printf "Day 5.1: %s\n" result;
