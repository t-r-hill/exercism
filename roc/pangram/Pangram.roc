module [is_pangram]

is_pangram : Str -> Bool
is_pangram = |sentence|
    Str.to_utf8(sentence)
    |> List.walk(
        List.repeat(NotPresent, 26),
        |letter_list, char|
            List.set(letter_list, parse_to_lower(char), Present),
    )
    |> List.all(|status| status == Present)

parse_to_lower : U8 -> U64
parse_to_lower = |char|
    if char >= 'A' and char <= 'Z' then
        char - 'A' |> Num.to_u64
    else if char >= 'a' and char <= 'z' then
        char - 'a' |> Num.to_u64
    else
        27
