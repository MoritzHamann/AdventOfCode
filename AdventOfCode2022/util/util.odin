package util

import "core:os"
import "core:strings"

readLines :: proc(filename: string) -> (lines: []string, err: bool) {
    data := os.read_entire_file(filename) or_return
    defer delete(data)
    
    data_string, clone_err := strings.clone_from_bytes(data)
    if clone_err != nil {
        return nil, false
    }
    defer delete(data_string)

    lines = strings.split(data_string, "\n")
    return lines, true
}
