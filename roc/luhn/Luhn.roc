module [valid]

valid : Str -> Bool
valid = |digits|
    digits
    |> Str.to_utf8
    |> List.drop_if(|char| char == ' ')
    |> List.map_try(|char| parse_digit(char))
    |> Result.map_ok(
        |nums|
            nums
            |> List.walk_backwards(
                (0, 0),
                |(sum, ix), digit|
                    if ix % 2 == 1 then
                        (sum + double_trunc(digit), ix + 1)
                    else
                        (sum + digit, ix + 1),
            )
            |> is_valid_sum_and_length,
    )
    |> Result.with_default(Bool.false)

parse_digit : U8 -> Result U64 [InvalidCharacter]
parse_digit = |digit|
    if digit >= '0' and digit <= '9' then
        (digit - '0')
        |> Num.to_u64
        |> Ok
    else
        Err InvalidCharacter

double_trunc : U64 -> U64
double_trunc = |num|
    if num < 5 then
        num * 2
    else
        num * 2 - 9

is_valid_sum_and_length : (U64, U64) -> Bool
is_valid_sum_and_length = |(sum, length)|
    sum % 10 == 0 and length > 1
