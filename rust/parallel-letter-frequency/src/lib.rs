use std::collections::HashMap;
use std::thread;

pub fn frequency(input: &[&str], worker_count: usize) -> HashMap<char, usize> {
    if input.len() < worker_count {
        return letters(input);
    }
    match worker_count {
        1 => letters(input),
        _ => letters_parallel(input, worker_count),
    }
}

fn letters_parallel(input: &[&str], worker_count: usize) -> HashMap<char, usize> {
    thread::scope(|s| {
        let input_chunks = input.chunks(input.len() / worker_count);
        let mut workers = Vec::with_capacity(worker_count);
        for chunk in input_chunks {
            let join_handle = s.spawn(move || letters(chunk));
            workers.push(join_handle);
        }
        let mut combined_maps = HashMap::new();
        for worker in workers {
            for (&ch, &count) in worker.join().unwrap().iter() {
                combined_maps.entry(ch).and_modify(|counter| *counter += count).or_insert(count);
            }
        }
        combined_maps
    })
}

fn letters(input: &[&str]) -> HashMap<char, usize> {
    input.iter()
        .flat_map(|&row| row.chars())
        .filter(|c| c.is_alphabetic())
        .filter_map(|c| c.to_lowercase().next())
        .fold(HashMap::new(), |mut hash_map, c | {
            hash_map.entry(c).and_modify(|counter| *counter += 1).or_insert(1);
            hash_map
    })
}
