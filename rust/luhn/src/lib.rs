/// Check a Luhn checksum.
pub fn is_valid(code: &str) -> bool {
    
    
    let mut i = 1;
    let mut sum = 0;
    for char in code.chars().rev() {
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
