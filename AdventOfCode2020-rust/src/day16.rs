use core::error;

use crate::input;
use regex::Regex;

#[derive(PartialEq, Debug)]
struct Range {
    low: u32,
    high: u32,
}

#[derive(PartialEq, Debug)]
struct Rule {
    label: String,

    ranges: (Range, Range),
}

impl Rule {
    fn from_line(line: &String) -> Self {
        let regex = Regex::new(r"(?P<label>.*?): (?P<lower1>[0-9]+)-(?P<upper1>[0-9]+) or (?P<lower2>[0-9]+)-(?P<upper2>[0-9]+)").unwrap();

        let captures = regex.captures(line).unwrap();
        let parse = |name: &str| -> u32 { captures[name].parse::<u32>().unwrap() };

        Rule {
            label: captures["label"].to_string(),
            ranges: (
                Range {
                    low: parse("lower1"),
                    high: parse("upper1"),
                },
                Range {
                    low: parse("lower2"),
                    high: parse("upper2"),
                },
            ),
        }
    }

    fn from_lines(lines: &Vec<String>) -> Vec<Self> {
        let mut rules = Vec::<Self>::new();

        for line in lines {
            rules.push(Self::from_line(line));
        }

        rules
    }

    fn is_valid_value(&self, value: u32) -> bool {
        (value >= self.ranges.0.low && value <= self.ranges.0.high)
            || (value >= self.ranges.1.low && value <= self.ranges.1.high)
    }
}

struct Problem {
    rules: Vec<Rule>,
    ticket: Vec<u32>,
    nearby: Vec<Vec<u32>>,
}

impl Problem {
    fn from_file(filename: &str) -> Self {
        let divider_fn = |s: &String| -> bool { s.trim() == "" };
        let processing_fn = |v: &Vec<String>| v.clone();
        let ticket_fn = |l: &String| -> Vec<u32> {
            l.trim()
                .split(",")
                .map(|c| c.parse::<u32>().unwrap())
                .collect()
        };

        let groups = input::collect_groups_with_divider(filename, divider_fn, processing_fn);
        assert!(groups.len() == 3, "Invalid input");
        assert!(groups[1].len() == 3, "Invalid ticket group");

        Problem {
            rules: Rule::from_lines(&groups[0]),
            ticket: ticket_fn(&groups[1][2]),
            nearby: groups[2][2..].iter().map(ticket_fn).collect(),
        }
    }
}

pub fn question1() -> String {
    let problem = Problem::from_file("input/day16.txt");
    let mut error_rate = 0u32;

    for ticket in &problem.nearby {
        let ticket_error_rate: u32 = ticket
            .iter()
            .filter(|&&num| problem.rules.iter().all(|rule| !rule.is_valid_value(num)))
            .sum();
        error_rate += ticket_error_rate;
    }

    format!("Day 16.1: Error rate = {}", error_rate)
}

pub fn question2() -> String {
    unimplemented!()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_data() -> &'static str {
        "class: 1-3 or 5-7
        row: 6-11 or 33-44
        seat: 13-40 or 45-50

        your ticket:
        7,1,14

        nearby tickets:
        7,3,47
        40,4,50
        55,2,20
        38,6,12"
    }

    #[test]
    fn test_rule_parsing() {
        let line = String::from("class: 1-3 or 5-7");
        let rule = Rule::from_line(&line);
        assert_eq!(
            rule,
            Rule {
                label: String::from("class"),
                ranges: (Range { low: 1, high: 3 }, Range { low: 5, high: 7 })
            }
        );
    }

    #[test]
    fn test_valid_value() {
        let line = String::from("class: 1-3 or 5-7");
        let rule = Rule::from_line(&line);
        assert!(rule.is_valid_value(3));
        assert!(!rule.is_valid_value(4));
    }

    #[test]
    fn test_input_parsing() {
        let problem = Problem::from_file("input/test16.txt");

        // just simple check if the lengths are correct
        assert_eq!(problem.rules.len(), 3);
        assert_eq!(problem.ticket.len(), 3);
        assert_eq!(problem.nearby.len(), 4);
    }
}
