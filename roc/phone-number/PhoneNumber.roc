module [clean]

clean : Str -> Result Str _
clean = |phone_number|
    parsed =
        Str.to_utf8(phone_number)
        |> List.keep_if(|c| c >= '0' and c <= '9')

    when parsed is
        ['1', a, _, _, b, .. as rest] if a > '1' and b > '1' and List.len(rest) == 6 -> Str.from_utf8(List.drop_first(parsed, 1))
        [a, _, _, b, .. as rest] if a > '1' and b > '1' and List.len(rest) == 6 -> Str.from_utf8(parsed)
        _ -> Err(InvalidFormat)
