use std::fs::File;
use std::io::{BufRead, BufReader};

pub fn lines_as<T>(filename: &str) -> Vec<T>
where
    T: std::str::FromStr,
    T::Err: std::fmt::Debug,
{
    let file = File::open(filename).unwrap();
    let reader = BufReader::new(file);
    let mut input = Vec::new();

    for line in reader.lines() {
        let value = line.unwrap().parse::<T>().unwrap();
        input.push(value);
    }
    return input;
}

pub fn collect_groups_as<T>(filename: &str) -> Vec<Vec<T>>
where
    T: std::str::FromStr,
    T::Err: std::fmt::Debug,
{
    let mut groups = Vec::new();
    let file = File::open(filename).unwrap();
    let reader = BufReader::new(file);

    let mut current_group = Vec::new();
    for line in reader.lines() {
        let l = line.unwrap();

        if l == String::from("") {
            groups.push(current_group);
            current_group = Vec::new();
        } else {
            current_group.push(l.parse::<T>().unwrap());
        }
    }
    groups.push(current_group);

    return groups;
}

pub fn collect_groups_with_divider<T>(
    filename: &str,
    divider_fn: impl Fn(&String) -> bool,
    processing_fn: impl Fn(&Vec<String>) -> T,
) -> Vec<T> {

    let file = File::open(filename).unwrap();
    let reader = BufReader::new(file);

    let mut groups = Vec::<T>::new();
    let mut current_group = Vec::<String>::new();

    for line in reader.lines() {
        let l = line.unwrap();
        if divider_fn(&l) && current_group.len() > 0 {
            let processed_group = processing_fn(&current_group);
            groups.push(processed_group);
            current_group.clear();
        }
        current_group.push(l);
    }
    groups.push(processing_fn(&current_group));

    return groups;
}

