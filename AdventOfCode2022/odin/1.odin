package main
import "util"
import "core:fmt"
import "core:strconv"

sum :: proc(weights: []int) -> int {
    s := 0
    for w in weights {
        s = s + w
    }
    return s
}

part1 :: proc() {
    lines, ok := util.readLines("./input1.txt")
    if ok == false {
        fmt.println("Unable to read file")
        return 
    }
    defer delete(lines)


    max := 0
    weights := make([dynamic]int)

    for l in lines {
        if l == "" {
            s := sum(weights[:])
            if s > max {
                max = s
            }
            clear(&weights)
        } else {
            w := strconv.atoi(l)
            append(&weights, w)
        }
    }

    fmt.printfln("part 1: %d", max)
}

part2 :: proc() {
    lines, ok := util.readLines("./input1.txt")
    if ok == false {
        fmt.println("Unable to read file")
        return 
    }
    defer delete(lines)


    max := [3]int {0,0,0}
    weights := make([dynamic]int)

    for l in lines {
        if l == "" {
            s := sum(weights[:])
            for i := 0; i < len(max); i+=1 {
                if s > max[i] {
                    // we save the current max in tmp to and afterwards in s
                    // since we iterate over all 3 places, this will effectively shift
                    // the remaining entries to the right
                    tmp := max[i]
                    max[i] = s
                    s = tmp
                }
            }
            clear(&weights)
        } else {
            w := strconv.atoi(l)
            append(&weights, w)
        }
    }

    fmt.printfln("part 2: %d", sum(max[:]))
}


main :: proc() {
    part1()
    part2()
}
