pub trait Luhn {
    fn valid_luhn(&self) -> bool;
}

/// Here is the example of how to implement custom Luhn trait
/// for the &str type. Naturally, you can implement this trait
/// by hand for every other type presented in the test suite,
/// but your solution will fail if a new type is presented.
/// Perhaps there exists a better solution for this problem?
impl<T: ToString> Luhn for T {
    fn valid_luhn(&self) -> bool {
        let mut i = 1;
        let mut sum = 0;
        for char in self.to_string().chars().rev() {
            if char == ' ' {
                continue;
            }
            let Some(digit) = char::to_digit(char, 10) else {
                return false;
            };
            if i % 2 == 0 {
                sum += if digit > 4 {
                    (digit * 2) - 9
                } else {
                    digit * 2
                }
            } else {
                sum += digit;
            }
            i += 1;
        }
        sum % 10 == 0 && i > 2
    }
}
