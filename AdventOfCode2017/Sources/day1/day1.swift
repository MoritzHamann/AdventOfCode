import Foundation

func question1() -> String {
    var input = ""
    do {
        input = try String(contentsOfFile: "Sources/day1.txt")
        // drop new line
        input = String(input.dropLast(1))
        
        var sum = 0
        var last = -1
        
        for value in input {
            let num = Int(String(value))!
            if last == num {
                sum += num
            }
            last = num
        }
        if input.first == input.last {
            sum += Int(String(input.last!))!
        }
        return String(sum)
    } catch  {
        print("Error", error)
        return ""
    }
}

func question2() -> String {
    var input = ""
    do {
        input = try String(contentsOfFile: "Sources/day1.txt")
        // drop new line
        input = String(input.dropLast(1))
        let half_length = input.count / 2
        var sum = 0

        for (index, element) in input.enumerated() {
            let neighbour_idx = (index + half_length) % input.count
            let inputIndex = input.index(input.startIndex, offsetBy: neighbour_idx)
            if input[inputIndex] == element {
                let num = Int(String(element))!
                sum += num
            }
        }
        return String(sum)
    } catch  {
        print("Error", error)
        return ""
    }
}
