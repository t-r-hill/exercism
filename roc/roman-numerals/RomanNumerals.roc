module [roman]

roman : U64 -> Result Str _
roman = |number|
    if number > 3999 then
        Err("Number too large")
    else
        Ok(roman_recurse(number, ""))

roman_recurse = |number, roman_num|
    if number // 1000 > 0 then
        roman_recurse(number % 1000, Str.concat(roman_num, parse_digit(number // 1000, "M", "", "")))
    else if number // 100 > 0 then
        roman_recurse(number % 100, Str.concat(roman_num, parse_digit(number // 100, "C", "D", "M")))
    else if number // 10 > 0 then
        roman_recurse(number % 10, Str.concat(roman_num, parse_digit(number // 10, "X", "L", "C")))
    else
        Str.concat(roman_num, parse_digit(number, "I", "V", "X"))

parse_digit = |digit, unit, five, ten|
    when digit is
        1 -> unit
        2 -> Str.repeat(unit, 2)
        3 -> Str.repeat(unit, 3)
        4 -> Str.concat(unit, five)
        5 -> five
        6 -> Str.concat(five, unit)
        7 -> Str.concat(five, Str.repeat(unit, 2))
        8 -> Str.concat(five, Str.repeat(unit, 3))
        9 -> Str.concat(unit, ten)
        _ -> ""
