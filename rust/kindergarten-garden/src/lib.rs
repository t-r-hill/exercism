use std::collections::HashMap;

const PLANTS_ABBRVS: [(char, &str); 4] = [
    ('G', "grass"),
    ('R', "radishes"),
    ('V', "violets"),
    ('C', "clover")];

const STUDENTS: [&str; 12] = ["Alice", "Bob", "Charlie", "David", "Eve", "Fred", "Ginny", "Harriet", "Ileana", "Joseph", "Kincaid", "Larry"];

pub fn plants(diagram: &str, student: &str) -> Vec<&'static str> {
    let plants_dict = HashMap::from(PLANTS_ABBRVS);
    
    let mut students = STUDENTS;
    students.sort();
    
    let position = students.iter().position(|&s| s == student).unwrap() * 2;
    
    diagram.split_ascii_whitespace()
        .map(|plants| plants.get(position..=(position + 1)).unwrap())
        .flat_map(|plants| plants.chars())
        .map(|plant| *plants_dict.get(&plant).unwrap())
        .collect()
    
}
