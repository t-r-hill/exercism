pub fn encrypt(input: &str) -> String {
    let normalised: Vec<char> = input
        .chars()
        .filter(|c| c.is_ascii_alphanumeric())
        .map(|c| c.to_ascii_lowercase())
        .collect();

    if normalised.is_empty() {
        return "".to_string();
    }

    let chunk_size = (normalised.len() as f32).sqrt().ceil() as usize;

    let mut row_iters: Vec<_> = normalised
        .chunks(chunk_size)
        .map(|row| row.iter())
        .collect();

    (0..chunk_size)
        .map(|_| {
            row_iters
                .iter_mut()
                .map(|element| *element.next().unwrap_or(&' '))
                .collect::<String>()
        })
        .collect::<Vec<_>>()
        .join(" ")
}
