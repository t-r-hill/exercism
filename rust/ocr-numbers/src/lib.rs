// The code below is a stub. Just enough to satisfy the compiler.
// In order to pass the tests you can add-to or change any of this code.

#[derive(Debug, PartialEq, Eq)]
pub enum Error {
    InvalidRowCount(usize),
    InvalidColumnCount(usize),
}

pub fn convert(input: &str) -> Result<String, Error> {
    let columns = input
        .lines()
        .next()
        .map(|line| line.chars().count())
        .unwrap();

    if columns % 3 != 0 {
        return Err(Error::InvalidColumnCount(columns));
    }

    let lines = input.lines().count();

    if lines % 4 != 0 {
        return Err(Error::InvalidRowCount(lines));
    }

    let mut digits_vec = Vec::new();
    for (il, line) in input.lines().enumerate() {
        if il % 4 == 0 {
            digits_vec.push(Vec::new());
        }
        for (ic, ch) in line.chars().enumerate() {
            if ic % 3 == 0 && il % 4 == 0 {
                digits_vec[il / 4].push(Vec::new());
            }
            digits_vec[il / 4][ic / 3].push(ch);
        }
    }

    digits_vec
        .iter()
        .enumerate()
        .map(|(i, digits)| {
            let parsed = digits
                .iter()
                .map(|digit| match digit.as_slice() {
                    [' ', '_', ' ', '|', ' ', '|', '|', '_', '|', ' ', ' ', ' '] => "0",
                    [' ', ' ', ' ', ' ', ' ', '|', ' ', ' ', '|', ' ', ' ', ' '] => "1",
                    [' ', '_', ' ', ' ', '_', '|', '|', '_', ' ', ' ', ' ', ' '] => "2",
                    [' ', '_', ' ', ' ', '_', '|', ' ', '_', '|', ' ', ' ', ' '] => "3",
                    [' ', ' ', ' ', '|', '_', '|', ' ', ' ', '|', ' ', ' ', ' '] => "4",
                    [' ', '_', ' ', '|', '_', ' ', ' ', '_', '|', ' ', ' ', ' '] => "5",
                    [' ', '_', ' ', '|', '_', ' ', '|', '_', '|', ' ', ' ', ' '] => "6",
                    [' ', '_', ' ', ' ', ' ', '|', ' ', ' ', '|', ' ', ' ', ' '] => "7",
                    [' ', '_', ' ', '|', '_', '|', '|', '_', '|', ' ', ' ', ' '] => "8",
                    [' ', '_', ' ', '|', '_', '|', ' ', '_', '|', ' ', ' ', ' '] => "9",
                    _ => "?",
                })
                .collect::<String>();
            if i == 0 {
                Ok(parsed)
            } else {
                Ok(format!(",{}", parsed))
            }
        })
        .collect()
}
