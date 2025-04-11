pub fn is_armstrong_number(num: u32) -> bool {
    if num < 10 {
        return true;
    }

    let digits = num.ilog10() + 1;

    (0..digits)
        .map(|digit_ix| num / pow_10(digit_ix))
        .map(|num| num % 10)
        .map(|num| num.pow(digits))
        .sum::<u32>()
        == num
}

fn pow_10(exp: u32) -> u32 {
    10_u32.pow(exp)
}
