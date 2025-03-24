pub type Value = i32;
pub type Result = std::result::Result<(), Error>;

pub struct Forth {
    stack: Vec<Value>,
    custom_ops: Vec<(String, Vec<String>)>,
}

#[derive(Debug, PartialEq, Eq)]
pub enum Error {
    DivisionByZero,
    StackUnderflow,
    UnknownWord,
    InvalidWord,
}

impl Forth {
    pub fn new() -> Forth {
        Forth {
            stack: Vec::new(),
            custom_ops: Vec::new(),
        }
    }

    fn perform_arithmetic(stack: &mut Vec<Value>, op: &str) {
        let item_1 = stack.pop().unwrap();
        let item_2 = stack.pop().unwrap();
        let result = match op {
            "+" => item_1 + item_2,
            "-" => item_2 - item_1,
            "*" => item_1 * item_2,
            "/" => item_2 / item_1,
            _ => 0,
        };
        stack.push(result);
    }

    fn perform_manipulation(stack: &mut Vec<Value>, op: &str) {
        let len = stack.len();
        match op {
            "dup" => stack.push(*stack.last().unwrap()),
            "drop" => {
                stack.pop();
            }
            "swap" => stack[len - 2..].rotate_left(1),
            "over" => stack.push(*stack.get(len - 2).unwrap()),
            _ => (),
        }
    }

    fn perform_op(mut stack: Vec<Value>, token: &String) -> std::result::Result<Vec<Value>, Error> {
        match token.as_str() {
            "+" | "-" | "*" | "/" => {
                if stack.len() < 2 {
                    return Err(Error::StackUnderflow);
                }
                if token == "/" && *stack.last().unwrap() == 0 {
                    return Err(Error::DivisionByZero);
                }
                Self::perform_arithmetic(&mut stack, token);
                Ok(stack)
            }
            "dup" | "drop" => {
                if stack.is_empty() {
                    return Err(Error::StackUnderflow);
                }
                Self::perform_manipulation(&mut stack, token);
                Ok(stack)
            }
            "swap" | "over" => {
                if stack.len() < 2 {
                    return Err(Error::StackUnderflow);
                }
                Self::perform_manipulation(&mut stack, token);
                Ok(stack)
            }
            _ => Err(Error::UnknownWord),
        }
    }

    fn translate_custom_op(&self, token: &str) -> Vec<String> {
        let mut custom_ops_iter = self.custom_ops.iter().rev();
        let mut acc = vec![];
        Self::translate_recursive(&mut acc, custom_ops_iter.by_ref(), token);
        acc
    }

    fn translate_recursive<'a, I: Iterator<Item=&'a (String, Vec<String>)>>(acc: &mut Vec<String>, iter: &mut I, token: &str) {
        for (key, value) in iter.by_ref() {
            if token == key {
                for sub_token in value {
                    Self::translate_recursive(acc, iter, sub_token)
                }
                return;
            }
        }
        acc.push(token.to_string());
    }

    fn parse_custom_op(&mut self, input: &str) -> Result {
        let mut tokens = input[1..input.len() - 1]
            .split_whitespace()
            .map(|s| s.to_lowercase());
        let key = tokens.next().unwrap();
        if key.parse::<Value>().is_ok() {
            return Err(Error::InvalidWord);
        }
        let value = tokens.collect();
        self.custom_ops.push((key, value));
        Ok(())
    }

    pub fn eval(&mut self, input: &str) -> Result {
        if input.starts_with(":") && input.ends_with(";") {
            return self.parse_custom_op(input);
        }

        let eval = input
            .to_lowercase()
            .split_whitespace()
            .flat_map(|token| {
                self.translate_custom_op(token)
            })
            .try_fold(vec![], |mut stack, token| {
                if let Ok(num) = token.parse::<Value>() {
                    stack.push(num);
                    return Ok(stack);
                }
                Self::perform_op(stack, &token)
            });

        match eval {
            Ok(stack) => {
                self.stack = stack;
                Ok(())
            }
            Err(error) => Err(error),
        }
    }

    pub fn stack(&self) -> &[Value] {
        self.stack.as_slice()
    }

}
