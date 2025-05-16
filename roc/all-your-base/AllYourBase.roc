module [rebase]

rebase : { input_base : U64, output_base : U64, digits : List U64 } -> Result (List U64) _
rebase = |{ input_base, output_base, digits }|
    if input_base <= 1 then
        Err(InvalidInputBase)
    else if output_base <= 1 then
        Err(InvalidOutputBase)
    else if input_base == output_base then
        Ok(digits)
    else
        rebase_to_10(input_base, digits) |> Result.map_ok(|number| rebase_from_10(output_base, number))

rebase_to_10 : U64, List U64 -> Result U64 _
rebase_to_10 = |input_base, digits|
    digits
    |> List.reverse
    |> List.walk_try(
        (0, 0),
        |(result, ix), digit|
            if digit < input_base then
                Ok (digit * Num.pow_int(input_base, ix) + result, ix + 1)
            else
                Err(InvalidDigit),
    )
    |> Result.map_ok(.0)

rebase_from_10 : U64, U64 -> List U64
rebase_from_10 = |output_base, number|
    if number == 0 then
        [0]
    else
        rebase_helper(output_base, number, [])

rebase_helper : U64, U64, List U64 -> List U64
rebase_helper = |output_base, number, digits|
    if number == 0 then
        digits
    else
        new_digit = number |> Num.rem(output_base)
        rebase_helper(output_base, number // output_base, List.prepend(digits, new_digit))
