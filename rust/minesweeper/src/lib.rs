pub fn annotate(minefield: &[&str]) -> Vec<String> {
    let mut mines = vec![];
    let mut output = vec![];
    let height = minefield.len() as i8;
    if height == 0 {
        return vec![];
    }
    let width = minefield[0].as_bytes().len() as i8;
    let surrounding_spaces = (-1..=1).flat_map(|i| {
        (-1..=1).filter(move |j| !(i == 0 && *j == 0)).map(move |j| ( i, j ))
    }).collect::<Vec<_>>();
    for i in 0..height {
        let mut inner_vec = vec![];
        for j in 0..width {
            if *minefield[i as usize].as_bytes().get(j as usize).unwrap() == b'*' {
                mines.push((i,j));
                inner_vec.push(-1);
            } else {
                inner_vec.push(0)
            }
        }
        output.push(inner_vec);
    }
    for (mine_i, mine_j) in &mines {
        let updates = surrounding_spaces.iter()
            .map(|(space_i, space_j)| (space_i + mine_i, space_j + mine_j))
            .filter(|( i, j)| *i >= 0 && *i < height && *j >= 0 && *j < width )
            .collect::<Vec<_>>();
        for ( i, j) in updates {
            if output[i as usize][j as usize] >= 0i8 {
                output[i as usize][j as usize] += 1i8;
            }
        }
    }
    output.iter().map(|row| {
        row.iter().map(|val| {
            if *val < 0 {
                '*'
            } else if *val == 0 {
                ' '
            } else {
                char::from_digit(*val as u32, 10).unwrap()
            }
        }).collect()
    }).collect()
}
