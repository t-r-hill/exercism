use std::cmp::Ordering;
use std::iter::{repeat, repeat_n, zip};
use std::ops::{Add, Mul, Sub};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Decimal {
    // Sign of the number
    sign: DecimalSign,
    // All digits in a single vector
    digits: Vec<i8>,
    // Position of the decimal point from the right end
    // (number of fractional digits)
    decimal_places: usize,
}

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
enum DecimalSign {
    Positive = 1,
    Negative = 0,
}

impl DecimalSign {
    fn invert(&self) -> DecimalSign {
        match self {
            DecimalSign::Positive => DecimalSign::Negative,
            DecimalSign::Negative => DecimalSign::Positive,
        }
    }
}

impl Decimal {
    pub fn try_from(input: &str) -> Option<Decimal> {
        match input.chars().next() {
            Some('+') => Self::parse_decimal(&input[1..], DecimalSign::Positive),
            Some('-') => Self::parse_decimal(&input[1..], DecimalSign::Negative),
            Some(digit) if digit.is_digit(10) => Self::parse_decimal(input, DecimalSign::Positive),
            _ => None,
        }
    }

    fn parse_decimal(input: &str, mut sign: DecimalSign) -> Option<Decimal> {
        let trimmed = input.trim_matches('0');
        let decimal_places = trimmed.find('.').map_or(0, |i| trimmed.len() - i - 1);
        let mut digits = trimmed
            .replace('.', "")
            .chars()
            .map(|c| c.to_digit(10).map(|d| d as i8))
            .collect::<Option<Vec<i8>>>()?;

        if digits.is_empty() {
            digits = vec![0];
            sign = DecimalSign::Positive;
        }

        Some(Decimal {
            sign,
            digits,
            decimal_places,
        })
    }

    fn normalise(&mut self) {
        if self.digits.iter().all(|&d| d == 0) {
            self.digits = vec![0];
            self.decimal_places = 0;
            self.sign = DecimalSign::Positive;
        }

        while self.decimal_places > 0 && self.digits.last() == Some(&0) {
            self.digits.pop();
            self.decimal_places -= 1;
        }

        let leading_zeros = self
            .digits
            .iter()
            .take(self.digits.len().saturating_sub(self.decimal_places))
            .take_while(|&&d| d == 0)
            .count();

        if leading_zeros > 0 && leading_zeros < self.digits.len() - self.decimal_places {
            self.digits.drain(0..leading_zeros);
        }
    }

    fn abs_cmp(lhs: &Decimal, rhs: &Decimal) -> Ordering {
        let lhs_int_len = lhs.digits.len() - lhs.decimal_places;
        let rhs_int_len = rhs.digits.len() - rhs.decimal_places;

        match lhs_int_len.cmp(&rhs_int_len) {
            Ordering::Equal => {
                let lhs_int = &lhs.digits[0..lhs_int_len];
                let rhs_int = &rhs.digits[0..rhs_int_len];

                match lhs_int.cmp(rhs_int) {
                    Ordering::Equal => {
                        let lhs_fract = &lhs.digits[lhs_int_len..];

                        let rhs_fract = &rhs.digits[rhs_int_len..];

                        lhs_fract.cmp(&rhs_fract)
                    }
                    other => other,
                }
            }
            other => other,
        }
    }

    fn op_same_sign(lhs: Decimal, rhs: Decimal, op: impl Fn(i8, i8) -> i8) -> Decimal {
        let result_places = lhs.decimal_places.max(rhs.decimal_places);
        let result_len = lhs.digits.len().max(rhs.digits.len());

        let lhs_digits_rev = repeat_n(0i8, result_places - lhs.decimal_places)
            .chain(lhs.digits.into_iter().rev())
            .chain(repeat(0i8))
            .take(result_len)
            .collect::<Vec<_>>();

        let rhs_digits_rev = repeat_n(0i8, result_places - rhs.decimal_places)
            .chain(rhs.digits.into_iter().rev())
            .chain(repeat(0i8))
            .take(result_len)
            .collect::<Vec<_>>();

        let mut carry = 0i8;

        let mut result_digits = zip(lhs_digits_rev, rhs_digits_rev)
            .scan(&mut carry, |carry, (a, b)| {
                let sum = op(a, b) + **carry;
                **carry = if sum >= 10 {
                    1
                } else if sum < 0 {
                    -1
                } else {
                    0
                };
                Some(sum.rem_euclid(10))
            })
            .collect::<Vec<_>>();

        // Add final carry if needed
        if carry > 0 {
            result_digits.push(carry);
        }

        // Reverse the result to get correct order
        result_digits.reverse();

        let mut result = Decimal {
            sign: lhs.sign,
            digits: result_digits,
            decimal_places: result_places,
        };

        result.normalise();
        result
    }
}

impl Add for Decimal {
    type Output = Self;

    fn add(self, rhs: Self) -> Self::Output {
        if self.sign == rhs.sign {
            // Same sign, simple addition
            Self::op_same_sign(self, rhs, |x, y| x + y)
        } else {
            // Different signs, we need to subtract absolute values
            match Self::abs_cmp(&self, &rhs) {
                Ordering::Greater => Self::op_same_sign(self, rhs),
                Ordering::Less => {
                    let res_sign = rhs.sign.clone();
                    let mut result = Self::sub_abs(rhs, self);
                    result.sign = res_sign;
                    result
                }
                Ordering::Equal => Decimal {
                    sign: DecimalSign::Positive,
                    digits: vec![0],
                    decimal_places: 0,
                },
            }
        }
    }
}

impl Sub for Decimal {
    type Output = Self;

    fn sub(self, rhs: Self) -> Self::Output {
        // Convert subtraction to addition with negated sign
        self + Decimal {
            sign: rhs.sign.invert(),
            digits: rhs.digits,
            decimal_places: rhs.decimal_places,
        }
    }
}

impl Mul for Decimal {
    type Output = Self;

    fn mul(self, rhs: Self) -> Self::Output {
        // Multiplication is sign sensitive
        let result_sign = if self.sign == rhs.sign {
            DecimalSign::Positive
        } else {
            DecimalSign::Negative
        };

        // Special case: either operand is zero
        if self.digits.len() == 1 && self.digits[0] == 0
            || rhs.digits.len() == 1 && rhs.digits[0] == 0
        {
            return Decimal {
                sign: DecimalSign::Positive,
                digits: vec![0],
                decimal_places: 0,
            };
        }

        // Calculate resulting decimal places
        let result_places = self.decimal_places + rhs.decimal_places;

        // Perform multiplication digit by digit
        let mut result = vec![0; self.digits.len() + rhs.digits.len()];

        for (i, &a) in self.digits.iter().rev().enumerate() {
            let mut carry = 0;

            for (j, &b) in rhs.digits.iter().rev().enumerate() {
                let pos = i + j;
                let product = result[pos] + a * b + carry;

                result[pos] = product % 10;
                carry = product / 10;
            }

            let mut pos = i + rhs.digits.len();
            while carry > 0 {
                let sum = result[pos] + carry;
                result[pos] = sum % 10;
                carry = sum / 10;
                pos += 1;
            }
        }

        // Reverse the result and remove leading zeros
        result.reverse();

        let mut decimal = Decimal {
            sign: result_sign,
            digits: result,
            decimal_places: result_places,
        };

        decimal.normalise();
        decimal
    }
}

impl PartialOrd for Decimal {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        if self.sign != other.sign {
            // Different signs
            return Some(self.sign.cmp(&other.sign));
        }

        // Same sign
        let order = Self::abs_cmp(self, other);
        Some(match self.sign {
            DecimalSign::Positive => order,
            DecimalSign::Negative => order.reverse(),
        })
    }
}

// #[derive(Debug, Clone, PartialEq, Eq)]
// pub struct Decimal {
//     sign: DecimalSign,
//     integer: Vec<u8>,
//     fraction: Vec<u8>,
// }

// #[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
// enum DecimalSign {
//     Positive = 1,
//     Negative = 0,
// }

// impl DecimalSign {
//     fn invert(&self) -> DecimalSign {
//         match self {
//             DecimalSign::Positive => DecimalSign::Negative,
//             DecimalSign::Negative => DecimalSign::Positive,
//         }
//     }
// }

// impl Decimal {
//     pub fn try_from(input: &str) -> Option<Decimal> {
//         match input.chars().next() {
//             Some('+') => Self::get_decimal(&input[1..], DecimalSign::Positive),
//             Some('-') => Self::get_decimal(&input[1..], DecimalSign::Negative),
//             Some(digit) if digit.is_digit(10) => Self::get_decimal(&input, DecimalSign::Positive),
//             _ => None,
//         }
//     }

//     fn parse(input: &str) -> Option<Vec<u8>> {
//         input
//             .chars()
//             .map(|c| c.to_digit(10).map(|d| d as u8))
//             .collect::<Option<Vec<u8>>>()
//             .map(|digits| if digits.is_empty() { vec![0u8] } else { digits })
//     }

//     fn get_decimal(input: &str, mut sign: DecimalSign) -> Option<Decimal> {
//         let (int_part, fract_part) = match input.split_once('.') {
//             Some((int_part, fract_part)) => (int_part, fract_part),
//             None => (input, ""),
//         };

//         let integer = Self::parse(int_part.trim_start_matches('0'))?;
//         let fraction = Self::parse(fract_part.trim_end_matches('0'))?;

//         if fraction[..] == [0u8] && integer[..] == [0u8] {
//             sign = DecimalSign::Positive;
//         }

//         Some(Decimal {
//             integer,
//             fraction,
//             sign,
//         })
//     }

//     fn abs_cmp(lhs: &Decimal, rhs: &Decimal) -> Ordering {
//         if lhs.integer.len() != rhs.integer.len() {
//             return lhs.integer.len().cmp(&rhs.integer.len());
//         }
//         if lhs.integer != rhs.integer {
//             return lhs.integer.cmp(&rhs.integer);
//         }
//         lhs.fraction.cmp(&rhs.fraction)
//     }

//     fn pad_fraction(digits: Vec<u8>, length: usize) -> Vec<u8> {
//         digits.into_iter().chain(repeat(0u8)).take(length).collect()
//     }

//     fn pad_integer(digits: Vec<u8>, length: usize) -> Vec<u8> {
//         repeat(0u8)
//             .take(length - digits.len())
//             .chain(digits.into_iter())
//             .collect::<Vec<_>>()
//     }

//     fn add_digits(
//         lhs: Vec<u8>,
//         rhs: Vec<u8>,
//         mut carry: i8,
//         op: impl Fn(i8, i8) -> i8,
//     ) -> (Vec<u8>, i8) {
//         let mut sum = zip(lhs.iter(), rhs.iter())
//             .rev()
//             .map(|(&lhs_d, &rhs_d)| (lhs_d as i8, rhs_d as i8))
//             .scan(&mut carry, |carry, (a, b)| {
//                 let sum = op(a, b) + **carry;
//                 **carry = if sum >= 10 {
//                     1
//                 } else if sum < 0 {
//                     -1
//                 } else {
//                     0
//                 };
//                 Some(sum.rem_euclid(10))
//             })
//             .map(|x| x as u8)
//             .collect::<Vec<_>>();
//         sum.reverse();

//         (sum, carry)
//     }

//     fn tidy_fraction(fraction: Vec<u8>) -> Vec<u8> {
//         let mut tidy: Vec<u8> = fraction.into_iter().rev().skip_while(|&x| x == 0).collect();
//         tidy.reverse();
//         if tidy.is_empty() { vec![0] } else { tidy }
//     }

//     fn tidy_integer(integer: Vec<u8>) -> Vec<u8> {
//         let tidy: Vec<u8> = integer.into_iter().skip_while(|&x| x == 0).collect();
//         if tidy.is_empty() { vec![0] } else { tidy }
//     }

//     fn add_fract(lhs: Vec<u8>, rhs: Vec<u8>) -> (Vec<u8>, i8) {
//         let fract_len = lhs.len().max(rhs.len());

//         let lhs_fract = Self::pad_fraction(lhs, fract_len);
//         let rhs_fract = Self::pad_fraction(rhs, fract_len);

//         let (fraction, carry) = Self::add_digits(lhs_fract, rhs_fract, 0i8, |a, b| a + b);
//         (Self::tidy_fraction(fraction), carry)
//     }

//     fn add_integer(lhs: Vec<u8>, rhs: Vec<u8>, carry: i8) -> Vec<u8> {
//         let int_len = lhs.len().max(rhs.len());

//         let lhs_int = Self::pad_integer(lhs, int_len);
//         let rhs_int = Self::pad_integer(rhs, int_len);

//         let (mut integer, carry) = Self::add_digits(lhs_int, rhs_int, carry, |a, b| a + b);

//         if carry > 0 {
//             integer.push(carry as u8);
//         }
//         Self::tidy_integer(integer)
//     }

//     fn sub_fract(lhs: Vec<u8>, rhs: Vec<u8>) -> (Vec<u8>, i8) {
//         let fract_len = lhs.len().max(rhs.len());

//         let lhs_fract = Self::pad_fraction(lhs, fract_len);
//         let rhs_fract = Self::pad_fraction(rhs, fract_len);

//         let (fraction, carry) = Self::add_digits(lhs_fract, rhs_fract, 0i8, |a, b| a - b);
//         (Self::tidy_fraction(fraction), carry)
//     }

//     fn sub_integer(lhs: Vec<u8>, rhs: Vec<u8>, carry: i8) -> Vec<u8> {
//         let int_len = lhs.len().max(rhs.len());

//         let lhs_int = Self::pad_integer(lhs, int_len);
//         let rhs_int = Self::pad_integer(rhs, int_len);

//         let (integer, _) = Self::add_digits(lhs_int, rhs_int, carry, |a, b| a - b);
//         Self::tidy_integer(integer)
//     }
// }

// impl Add for Decimal {
//     type Output = Self;

//     fn add(self, rhs: Self) -> Self::Output {
//         match (self, rhs) {
//             (
//                 Decimal {
//                     sign: DecimalSign::Positive,
//                     integer: self_integer,
//                     fraction: self_fraction,
//                 },
//                 Decimal {
//                     sign: DecimalSign::Positive,
//                     integer: rhs_integer,
//                     fraction: rhs_fraction,
//                 },
//             ) => {
//                 let (fraction, carry) = Self::add_fract(self_fraction, rhs_fraction);
//                 let integer = Self::add_integer(self_integer, rhs_integer, carry);

//                 Decimal {
//                     integer,
//                     fraction,
//                     sign: DecimalSign::Positive,
//                 }
//             }
//             (
//                 Decimal {
//                     sign: DecimalSign::Negative,
//                     integer: self_integer,
//                     fraction: self_fraction,
//                 },
//                 Decimal {
//                     sign: DecimalSign::Negative,
//                     integer: rhs_integer,
//                     fraction: rhs_fraction,
//                 },
//             ) => {
//                 let (fraction, carry) = Self::add_fract(self_fraction, rhs_fraction);
//                 let integer = Self::add_integer(self_integer, rhs_integer, carry);

//                 Decimal {
//                     integer,
//                     fraction,
//                     sign: DecimalSign::Negative,
//                 }
//             }
//             (self_decimal, rhs_decimal)
//                 if Self::abs_cmp(&self_decimal, &rhs_decimal) == Ordering::Greater =>
//             {
//                 let (fraction, carry) =
//                     Self::sub_fract(self_decimal.fraction, rhs_decimal.fraction);
//                 let integer = Self::sub_integer(self_decimal.integer, rhs_decimal.integer, carry);

//                 Decimal {
//                     integer,
//                     fraction,
//                     sign: self_decimal.sign,
//                 }
//             }
//             (self_decimal, rhs_decimal)
//                 if Self::abs_cmp(&self_decimal, &rhs_decimal) == Ordering::Less =>
//             {
//                 let (fraction, carry) =
//                     Self::sub_fract(rhs_decimal.fraction, self_decimal.fraction);
//                 let integer = Self::sub_integer(rhs_decimal.integer, self_decimal.integer, carry);

//                 Decimal {
//                     integer,
//                     fraction,
//                     sign: rhs_decimal.sign,
//                 }
//             }
//             _ => Decimal {
//                 integer: vec![0],
//                 fraction: vec![0],
//                 sign: DecimalSign::Positive,
//             },
//         }
//     }
// }

// impl Sub for Decimal {
//     type Output = Self;

//     fn sub(self, rhs: Self) -> Self::Output {
//         Self::add(
//             self,
//             Decimal {
//                 integer: rhs.integer,
//                 fraction: rhs.fraction,
//                 sign: rhs.sign.invert(),
//             },
//         )
//     }
// }

// impl Mul for Decimal {
//     type Output = Self;

//     fn mul(self, rhs: Self) -> Self::Output {
//         let rhs_dp = if rhs.fraction == vec![0] {
//             0
//         } else {
//             rhs.fraction.len()
//         };

//         let lhs_dp = if self.fraction == vec![0] {
//             0
//         } else {
//             self.fraction.len()
//         };

//         let total_dp = lhs_dp + rhs_dp;

//         let rhs_num: Vec<u8> = rhs
//             .integer
//             .into_iter()
//             .chain(rhs.fraction.into_iter())
//             .collect();

//         let lhs_num: Vec<u8> = self
//             .integer
//             .into_iter()
//             .chain(self.fraction.into_iter())
//             .collect();

//         let without_dp = rhs_num
//             .iter()
//             .rev()
//             .enumerate()
//             .map(|(i, rhs_digit)| {
//                 let mut carry = 0u8;
//                 let mut res = lhs_num
//                     .iter()
//                     .rev()
//                     .scan(&mut carry, |carry, &lhs_digit| {
//                         let product = lhs_digit * rhs_digit + **carry;
//                         **carry = product / 10;
//                         Some(product % 10)
//                     })
//                     .collect::<Vec<u8>>();
//                 if carry > 0 {
//                     res.push(carry);
//                 }
//                 res.reverse();
//                 res.extend(repeat_n(0u8, i));
//                 res
//             })
//             .fold(vec![0], |acc, digits| Self::add_integer(acc, digits, 0i8));

//         Decimal {
//             integer: without_dp[..(without_dp.len() - total_dp - 1)].to_vec(),
//             fraction: Self::tidy_fraction(without_dp[(without_dp.len() - total_dp - 1)..].to_vec()),
//             sign: match self.sign == rhs.sign {
//                 true => DecimalSign::Positive,
//                 false => DecimalSign::Negative,
//             },
//         }
//     }
// }

// impl PartialOrd for Decimal {
//     fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
//         if self.sign != other.sign {
//             return Some(self.sign.cmp(&other.sign));
//         }

//         match self.sign {
//             DecimalSign::Positive => Some(Self::abs_cmp(self, other)),
//             DecimalSign::Negative => Some(Self::abs_cmp(self, other).reverse()),
//         }
//     }
// }
