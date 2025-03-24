pub fn rotate(input: &str, key: u8) -> String {
    input.chars()
        .map(|c| match c {
            c if c.is_ascii_lowercase() => rotate_letter(c, key, b'a'),
            c if c.is_ascii_uppercase() => rotate_letter(c, key, b'A'),
            _ => c
        })
        .collect()
}

fn rotate_letter(c: char, key: u8, base: u8) -> char {
    let offset = (c as u8) - base;
    let rotated = (offset + key) % 26;
    (rotated + base) as char
}
