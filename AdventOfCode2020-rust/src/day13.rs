use crate::input;

#[derive(Debug)]
enum Bus {
    Active(u64),
    Inactive,
}

fn _earliest_time_bruteforce(start_time: u64, buses: &Vec<Bus>) -> (u64, u64) {
    assert!(buses.iter().all(|bus| matches!(bus, Bus::Active(_))));

    let mut current_start = start_time;
    loop {
        for bus in buses.iter() {
            let Bus::Active(id) = bus else {
                continue;
            };
            if current_start % id == 0 {
                return (current_start, *id);
            }
        }
        current_start += 1;
    }
}

fn earliest_time(start_time: u64, buses: &Vec<Bus>) -> (u64, u64) {
    let mut next_time = 0;
    let mut next_bus = 0;
    for bus in buses.iter() {
        let Bus::Active(id) = bus else {
            continue;
        };

        let wait_time = id - (start_time % id);
        let arrivial_time = start_time + wait_time;
        if next_time == 0 || next_time > arrivial_time {
            next_time = arrivial_time;
            next_bus = *id;
        }
    }
    return (next_time, next_bus);
}

/// The steps we can advance the bruteforce solution.
///
/// The main idea is that once we found the correct time for the
/// first k busses, we can advance by busId_1 * ... * busId_k steps.
fn next_iteration_step(start_time: u64, buses: &Vec<Bus>) -> u64 {
    let mut step = 1;
    for (offset, b) in buses.iter().enumerate() {
        let Bus::Active(id) = b else {
            continue;
        };
        
        let offset = offset as u64;
        if (start_time + offset) % id != 0 {
            return step;
        }
        step = step * id;
    }
    return 0;
}


fn solution_1(start_time: u64, buses: &Vec<Bus>) -> u64 {
    let (next_start_time, bus_id) = earliest_time(start_time, buses);
    return (next_start_time - start_time) * bus_id;
}

// HINT: Chinese remainder theorem.
//       We'll gonna do a sieve based brutefore algorithm. Based on the theorm,
//       we only have to search 0 ... Product(bus IDs) (since the bus ids are coprime,
//       at least they should be).
//
//       1. We take the bus with the highest ID and start at time t == <offset in vector>
//       2. We check if the bus with the second highest ID has the correct remainder
//          (based on the offset in the vector)
//       3. If so we continue for each subsequent smaller ID, until we either
//          3.1. all buses ar correct and we found the solution
//          3.2. one bus does not match and we add the ID of the highest bus and start at 2. again
//
//       The solution is then the timestamp + product(bus IDs) * integer, with integer >= 0
//       so that the total >= original start_time.
fn solution_2(start_time: u64, buses: &Vec<Bus>) -> u64 {
    // building a vector of tuples which have (bus offset, bus ID)
    let mut bus_offsets: Vec<(usize, u64)> = buses
        .iter()
        .enumerate()
        .filter(|(_, b)| matches!(b, Bus::Active(_)))
        .map(|(idx, b)| {
            if let Bus::Active(id) = b {
                (idx, *id)
            } else {
                panic!("Inactive bus encountered")
            }
        })
        .collect();
    bus_offsets.sort_by(|(_, id1), (_, id2)| id2.cmp(&id1));

    // maximum number we have to iterate to in order to find a solution
    let maximum_time = bus_offsets.iter().fold(1u64, |acc, (_, id)| acc * id);

    // just some debug information about the iterations
    // let largest_bus_id = bus_offsets[0].1;
    // println!(
    //     "Number of maximum iterations: {} / {} = {}",
    //     maximum_time,
    //     largest_bus_id,
    //     maximum_time / largest_bus_id
    // );

    // sieve iteration over all possible numbers from 0 .. product(bus ids)
    let mut earliest_start = 0;
    let mut it = 0;
    while earliest_start <= maximum_time {       
        let step = next_iteration_step(earliest_start, buses);
        if step == 0 {
            break;
        }
        earliest_start += step;
        it += 1
    }

    // how long did we actually iterate?
    // println!("Number of iterations: {}", it);

    // the number we're looking for is now: t = earliest_start + maximum_number * k
    // if the provided start_time is < maximum number we need to scale by an integer k
    // TODO: not so sure about the following, but I don't think it matters in the provided example
    if start_time > earliest_start {
        return start_time / maximum_time * maximum_time + earliest_start;
    }

    return earliest_start;
}

fn parse_input() -> (u64, Vec<Bus>) {
    let lines = input::lines_as::<String>("input/day13.txt");
    let start_time = lines[0].parse::<u64>().unwrap();
    let buses: Vec<Bus> = lines[1]
        .split(",")
        .map(|bus| match bus.parse::<u64>() {
            Ok(id) => Bus::Active(id),
            Err(_) => Bus::Inactive,
        })
        .collect();
    return (start_time, buses);
}

pub fn question1() -> String {
    let (start_time, buses) = parse_input();
    let solution = solution_1(start_time, &buses);
    return format!("Day 13.1: Wait time * bus ID = {}", solution);
}

pub fn question2() -> String {
    let (start_time, buses) = parse_input();
    let earliest_time = solution_2(start_time, &buses);
    return format!(
        "Day 13.2: Earliest start time for sequential departure: {}",
        earliest_time
    );
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_data() -> Vec<Bus> {
        use Bus::*;

        return vec![
            Active(7),
            Active(13),
            Inactive,
            Inactive,
            Active(59),
            Inactive,
            Active(31),
            Active(19),
        ];
    }

    #[test]
    fn question_1_test() {
        let start_time = 939;
        let buses = test_data();

        assert_eq!(solution_1(start_time, &buses), 295);
    }

    #[test]
    fn question_2_test() {
        let start_time = 939;
        let buses = test_data();
        let valid_start_time = 1068781;
        assert_eq!(solution_2(start_time, &buses), valid_start_time);
    }

    #[test]
    fn next_iteration_step_test() {
        let valid_start_time = 1068781;
        let invalid_start_time = 1068788;
        let buses = test_data();

        assert_eq!(
            next_iteration_step(valid_start_time, &buses),
            0,
            "valid start"
        );
       
        assert_eq!(
            next_iteration_step(invalid_start_time, &buses),
            7, // first active bus id
            "invalid start"
        );
    }
}
