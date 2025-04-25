module [is_armstrong_number]

is_armstrong_number : U64 -> Bool
is_armstrong_number = |number|
    digits = number_digits(number, List.single(0))
    digits
    |> List.map(|digit| Num.pow_int(digit, Num.max(List.len(digits) - 1, 1)))
    |> List.sum
    |> Bool.is_eq(number)

number_digits : U64, List U64 -> List U64
number_digits = |number, list|
    if number == 0 then
        list
    else
        number_digits(number // 10, List.append(list, number % 10))
