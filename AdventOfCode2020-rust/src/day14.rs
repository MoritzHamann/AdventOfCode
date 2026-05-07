use std::collections::BTreeMap;

use crate::input;
use regex::Regex;

struct SaveInstr {
    addr: u64,
    value: u64,
}

struct InputGroup {
    /// For each position with a '1' in the input mask, we store a 1 bit, otherwise 0.
    /// We then use bitwise or (|) to set the bits in the specific positions to 1
    high_mask: u64,

    /// For each position with a '0' in the input mask, we store a 0 bit, otherwise 1.
    /// We then use bitwise and (&) to set the bits in the specific positions to 0
    low_mask: u64,

    original_bitmask: Vec<char>,

    instructions: Vec<SaveInstr>,
}

fn parse_bitmask(s: &String, group: &mut InputGroup) {
    let Some((_, mask)) = s.split_once("=") else {
        panic!("Invalid bitmask input string");
    };

    group.original_bitmask = mask.trim().chars().collect();

    for (idx, c) in mask.trim().chars().rev().enumerate() {
        match c {
            '0' => {
                group.high_mask &= !(1 << idx);
                group.low_mask &= !(1 << idx);
            }
            '1' => {
                group.high_mask |= 1 << idx;
                group.low_mask |= 1 << idx;
            }
            'X' => {
                group.high_mask &= !(1 << idx);
                group.low_mask |= 1 << idx;
            }
            x => panic!("Unknown mask value: {}", x),
        }
    }
}

fn display_bitmask(mask: u64) {
    for i in (0..64).rev() {
        if (mask & (1 << i)) != 0 {
            print!("1");
        } else {
            print!("0");
        }
    }
    println!("");
}

fn parse_save_instruction(s: &String) -> SaveInstr {
    lazy_static! {
        static ref RE: Regex =
            Regex::new(r"mem\[(?P<addr>[0-9]+)\]\s+=\s+(?P<value>[0-9]+)").unwrap();
    }
    let captures = RE.captures(&s).unwrap();
    let addr = captures
        .name("addr")
        .unwrap()
        .as_str()
        .parse::<u64>()
        .unwrap();
    let value = captures
        .name("value")
        .unwrap()
        .as_str()
        .parse::<u64>()
        .unwrap();
    return SaveInstr { addr, value };
}

fn display_instr(i: &SaveInstr) {
    println!("{} => {}", i.addr, i.value)
}

fn display_group(g: &InputGroup) {
    println!("");
    print!("High mask: ");
    display_bitmask(g.high_mask);
    print!("Low mask:  ");
    display_bitmask(g.low_mask);
    for i in g.instructions.iter() {
        display_instr(i);
    }
}

fn apply_mask_to_value(value: u64, group: &InputGroup) -> u64 {
    let mut final_value = value;
    final_value |= group.high_mask;
    final_value &= group.low_mask;
    return final_value;
}

fn set_bit(value: u64, idx: usize) -> u64 {
    value | (1 << idx)
}

fn unset_bit(value: u64, idx: usize) -> u64 {
    value & !(1 << idx)
}

fn apply_mask_to_addr(addr: u64, group: &InputGroup) -> Vec<u64> {
    // using reverse since we want to start with the lowest bit
    let mut affected_addresses = vec![addr];

    // using .rev() before .enumarate, since the order of the bitmask is
    // high ... low, but we want the low end to be index 0
    for (idx, c) in group.original_bitmask.iter().rev().enumerate() {
        match c {
            '0' => (),
            '1' => affected_addresses
                .iter_mut()
                .for_each(|a| *a = set_bit(*a, idx)),
            'X' => {
                let len = affected_addresses.len();
                for i in 0..len {
                    let original = affected_addresses[i];
                    affected_addresses[i] = set_bit(original, idx);
                    affected_addresses.push(unset_bit(original, idx));
                }
            }
            x => panic!("invalid bitmask value = {}", x),
        }
    }
    return affected_addresses;
}

fn group_divider_fn(s: &String) -> bool {
    s.starts_with("mask =")
}

fn parse_input_groups(v: &Vec<String>) -> InputGroup {
    let mut group = InputGroup {
        high_mask: 0,
        low_mask: 0,
        original_bitmask: vec![],
        instructions: vec![],
    };

    for line in v {
        if group_divider_fn(line) {
            parse_bitmask(line, &mut group);
        } else {
            let instr = parse_save_instruction(line);
            group.instructions.push(instr);
        }
    }

    return group;
}

pub fn question1() -> String {
    let groups = input::collect_groups_with_divider::<InputGroup>(
        "input/day14.txt",
        group_divider_fn,
        parse_input_groups,
    );

    let mut memory = BTreeMap::<u64, u64>::new();

    for g in groups {
        for SaveInstr { addr, value } in &g.instructions {
            memory.insert(*addr, apply_mask_to_value(*value, &g));
        }
    }

    let solution = memory.iter().fold(0, |acc, (_, v)| acc + v);
    return format!("Day 14.1: Sum of memory values = {}", solution);
}

pub fn question2() -> String {
    let groups = input::collect_groups_with_divider::<InputGroup>(
        "input/day14.txt",
        group_divider_fn,
        parse_input_groups,
    );

    let mut memory = BTreeMap::<u64, u64>::new();

    for g in groups {
        for SaveInstr { addr, value } in &g.instructions {
            let affected_addresses = apply_mask_to_addr(*addr, &g);
            for a in affected_addresses {
                memory.insert(a, *value);
            }
        }
    }

    let solution = memory.iter().fold(0, |acc, (_, v)| acc + v);
    return format!("Day 14.2: Sum of memory values = {}", solution);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_bitmask_test() {
        let mask = String::from("mask = 00011XX");
        let mut group = InputGroup {
            high_mask: 0,
            low_mask: 0,
            original_bitmask: vec![],
            instructions: vec![],
        };

        parse_bitmask(&mask, &mut group);
        display_bitmask(group.high_mask);
        display_bitmask(group.low_mask);
        println!("{}", group.high_mask);
        println!("{}", group.low_mask);
    }

    #[test]
    fn test_input_parsing() {
        let groups = input::collect_groups_with_divider::<InputGroup>(
            "input/test14.txt",
            group_divider_fn,
            parse_input_groups,
        );

        for g in groups {
            display_group(&g);
        }
    }

    #[test]
    fn test_set_bit() {
        let mut value: u64 = 0;
        value = set_bit(value, 0);
        value = set_bit(value, 1);
        value = set_bit(value, 3);
        value = set_bit(value, 4);
        value = unset_bit(value, 0);
        println!("{}", value);
    }
}
