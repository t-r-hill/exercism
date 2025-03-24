use std::fmt::Write;

pub fn encode(source: &str) -> String {
    if source.is_empty() {
        return "".to_string();
    }

    let mut state: (char, i32) = (source.chars().next().unwrap(), 1);
    let top = &source[..source.len() - 1];
    let tail = &source[1..];

    let mut temp = top.chars()
        .zip(tail.chars())
        .map(|(i, j)| {
            let (letter, count) = &mut state;
            if i == j {
                *count += 1;
                None
            } else {
                let temp = (*letter, *count);
                *letter = j;
                *count = 1;
                Some(temp)
            }
        }).fold(String::new(), |mut out, item| {
        match item {
            Some((letter, 1)) => {
                write!(&mut out, "{}", letter).unwrap();
            },
            Some((letter, count)) => {
                write!(&mut out, "{}{}", count, letter).unwrap();
            },
            None => {}
        }
        out
    });

    match state {
        (letter, 1) => write!(&mut temp, "{}", letter).unwrap(),
        (letter, count) => {
            write!(&mut temp, "{}{}", count, letter).unwrap();
        }
    }

    temp
}

pub fn decode(source: &str) -> String {
    source.chars()
        .scan(0, |state, char| {
            if char.is_ascii_digit() {
                *state = *state * 10 + char.to_digit(10).unwrap();
                Some(None)
            } else {
                let temp = *state;
                *state = 0;
                Some(Some((temp, char)))
            }
        }).fold(String::new(), |mut out, item| {
        match item {
            Some((0, char)) => out.push(char),
            Some((count, char)) => {
                std::iter::repeat(char).take(count as usize).for_each(|item| out.push(item));
            },
            None => ()
        }
        out
    })
}
