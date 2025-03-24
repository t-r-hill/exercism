use std::fmt::Debug;

#[derive(Debug, PartialEq, Eq)]
pub enum Comparison {
    Equal,
    Sublist,
    Superlist,
    Unequal,
}

pub fn sublist<T: PartialEq + Debug>(_first_list: &[T], _second_list: &[T]) -> Comparison {
    if _first_list.len() == _second_list.len() {
        match are_equal(_first_list, _second_list) {
            true => Comparison::Equal,
            false => Comparison::Unequal
        }
    } else if _first_list.len() > _second_list.len() {
        match is_sublist(_second_list, _first_list) {
            true => Comparison::Superlist,
            false => Comparison::Unequal
        }
    } else {
        match is_sublist(_first_list, _second_list) {
            true => Comparison::Sublist,
            false => Comparison::Unequal
        }
    }
}

fn is_sublist<T: PartialEq + Debug>(_first_list: &[T], _second_list: &[T]) -> bool {
    if _first_list.len() == 0 {
        return true;
    }
    (0.._second_list.len()).any(|i| are_equal(_first_list, &_second_list[i..]))
}

fn are_equal<T: PartialEq>(first_list: &[T], second_list: &[T]) -> bool {
    !(0..first_list.len()).any(|i| first_list[i] != second_list[i])
}

