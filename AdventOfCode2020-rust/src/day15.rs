use std::{collections::HashMap, hash::Hash};

#[derive(Debug)]
struct GameState {
    /// the last number we guessed, not yet committed to self.seen
    last: i32,

    /// the current iteration
    idx: i32,

    /// map from number -> idx (when it was seen)
    seen: HashMap<i32, i32>,

    // history (only used for debugging)
    // history: Vec<i32>,
}


impl GameState {
    fn new() -> Self {
        GameState {
            last: 0,
            idx: 0,
            seen: HashMap::new(),
            // history: Vec::new(),
        }
    }

    fn next(&mut self) -> i32 {
        if self.idx == 0 {
            panic!("Can not get the next number without prior ones");
        }

        let mut next = 0;
        if self.seen.contains_key(&self.last) {
            next = self.idx - self.seen[&self.last];
        }
        
        // commit self.last into self.seen
        self.seen.insert(self.last, self.idx);
        self.last = next;
        // self.history.push(next);
        self.idx += 1;

        return next;
    }

    fn seed_number(&mut self, number: i32) {
        // first commit the last number into self.seen
        if self.idx == 0 {
            self.last = number;
        } else {
            self.seen.insert(self.last, self.idx);
            self.last = number;
        }
        // self.history.push(number);
        self.idx += 1;
    }

    fn seed_vector(&mut self, v: &Vec<i32>) {
        for i in v {
            self.seed_number(*i);
        }
    }

    fn get_number(&mut self, idx: i32) -> i32 {
        if idx < self.idx {
            panic!("already at round {}", self.idx);
        }
        
        while self.idx < idx {
            self.next();
        }

        return self.last;
    }
}


fn input_data() -> Vec<i32> {
    vec![20, 0, 1, 11, 6, 3]
}

pub fn question1() -> String {
    let data = input_data();
    let test_data = vec![0, 3, 6];
    let mut state = GameState::new();
    
    state.seed_vector(&data);
    format!("The 2020th number is {}", state.get_number(2020))
}

// TODO: this takes a few seconds, but my intution says this should be faster
//       ignoring the self.history did not yield much improvement, maybe we can pre allocate the
//       hash table better?
//       Good candidate to explor profiling in Rust.
pub fn question2() -> String {
    let data = input_data();
    let test_data = vec![0, 3, 6];
    let mut state = GameState::new();
    
    state.seed_vector(&data);
    format!("The 30000000th number is {}", state.get_number(30000000))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_question_1() {
        let test_data: Vec<(Vec<i32>, i32)> = vec![
            (vec![1, 3, 2], 1),
            (vec![2, 1, 3], 10),
            (vec![1, 2, 3], 27),
            (vec![2, 3, 1], 78),
            (vec![3, 2, 1], 438),
            (vec![3, 1, 2], 1836),
        ];

        for (data, num) in test_data {
            let mut state = GameState::new();
            state.seed_vector(&data);
                
            println!("{:?}", data);
            assert_eq!(state.get_number(2020), num);
        }
    }
}
