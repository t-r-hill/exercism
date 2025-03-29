pub fn chain(input: &[(u8, u8)]) -> Option<Vec<(u8, u8)>> {
    if input.is_empty() {
        return Some(Vec::new());
    }
    let mut chain = vec![input[0]];
    let mut used = vec![false; input.len()];
    used[0] = true;
    if find_chain(input, &mut chain, &mut used) {
        Some(chain)
    } else {
        None
    }
}

fn swap(domino: (u8, u8)) -> (u8, u8) {
    (domino.1, domino.0)
}

fn find_chain(input: &[(u8, u8)], chain: &mut Vec<(u8, u8)>, used: &mut [bool]) -> bool {
    if chain.len() == input.len() {
        return chain.first().unwrap().0 == chain.last().unwrap().1;
    }
    for (i, &domino) in input.iter().enumerate() {
        if used[i] {
            continue;
        }
        let value_to_match = chain.last().unwrap().1;
        if domino.0 == value_to_match {
            chain.push(domino);
            used[i] = true;
            if find_chain(input, chain, used) {
                return true;
            }
            chain.pop();
            used[i] = false;
        } else if domino.1 == value_to_match {
            chain.push(swap(domino));
            used[i] = true;
            if find_chain(input, chain, used) {
                return true;
            }
            chain.pop();
            used[i] = false;
        }
    }
    false
}
