use std::cmp::Ordering;
use std::iter::{repeat, repeat_n, zip};
use std::ops::{Add, Mul, Sub};

#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct Decimal {
    sign: DecimalSign,
    digits: Vec<i8>,
    decimal_places: usize,
}

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Default)]
enum DecimalSign {
    #[default]
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
            Some(digit) if digit.is_ascii_digit() => {
                Self::parse_decimal(input, DecimalSign::Positive)
            }
            _ => None,
        }
    }

    fn parse_decimal(input: &str, sign: DecimalSign) -> Option<Decimal> {
        if input.chars().all(|d| d == '0' || d == '.') {
            return Some(Decimal::default());
        }

        let trimmed = input.trim_start_matches('0');

        if let Some(dp_pos) = trimmed.find('.') {
            let trimmed = trimmed.trim_end_matches('0');
            let decimal_places = trimmed.len() - dp_pos - 1;
            let digits = trimmed
                .replace('.', "")
                .chars()
                .map(|c| c.to_digit(10).map(|d| d as i8))
                .collect::<Option<Vec<i8>>>()?;
            Some(Decimal {
                sign,
                digits,
                decimal_places,
            })
        } else {
            let decimal_places = 0;
            let digits = trimmed
                .chars()
                .map(|c| c.to_digit(10).map(|d| d as i8))
                .collect::<Option<Vec<i8>>>()?;
            Some(Decimal {
                sign,
                digits,
                decimal_places,
            })
        }
    }

    fn normalise(&mut self) {
        if self.digits.iter().all(|&d| d == 0) {
            self.digits = vec![];
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

        if leading_zeros > 0 && leading_zeros <= self.digits.len() - self.decimal_places {
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
                        lhs_fract.cmp(rhs_fract)
                    }
                    other => other,
                }
            }
            other => other,
        }
    }

    fn combine(lhs: Decimal, rhs: Decimal, op: impl Fn(i8, i8) -> i8) -> Decimal {
        let result_places = lhs.decimal_places.max(rhs.decimal_places);
        let result_len =
            lhs.digits.len() - lhs.decimal_places + rhs.digits.len() - rhs.decimal_places + 1;

        let lhs_digits_rev = repeat_n(0i8, result_places - lhs.decimal_places)
            .chain(lhs.digits.into_iter().rev())
            .chain(repeat(0i8))
            .take(result_len + result_places)
            .collect::<Vec<_>>();

        let rhs_digits_rev = repeat_n(0i8, result_places - rhs.decimal_places)
            .chain(rhs.digits.into_iter().rev())
            .chain(repeat(0i8))
            .take(result_len + result_places)
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

        if carry > 0 {
            result_digits.push(carry);
        }

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
            Self::combine(self, rhs, |x, y| x + y)
        } else {
            match Self::abs_cmp(&self, &rhs) {
                Ordering::Greater => Self::combine(self, rhs, |x, y| x - y),
                Ordering::Less => Self::combine(rhs, self, |x, y| x - y),
                Ordering::Equal => Decimal::default(),
            }
        }
    }
}

impl Sub for Decimal {
    type Output = Self;

    fn sub(self, rhs: Self) -> Self::Output {
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
        let result_sign = if self.sign == rhs.sign {
            DecimalSign::Positive
        } else {
            DecimalSign::Negative
        };

        if self == Decimal::default() || rhs == Decimal::default() {
            return Decimal::default();
        }

        let result_places = self.decimal_places + rhs.decimal_places;

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
            return Some(self.sign.cmp(&other.sign));
        }

        let order = Self::abs_cmp(self, other);
        Some(match self.sign {
            DecimalSign::Positive => order,
            DecimalSign::Negative => order.reverse(),
        })
    }
}
