module [largest_product]

largest_product : Str, U64 -> Result U64 _
largest_product = |digits, span|
    digit_list = Str.to_utf8(digits) |> List.map_try(|digit| if digit >= '0' and digit <= '9' then Ok(Num.to_u64(digit - '0')) else Err(InvalidDigit))?
    if List.len(digit_list) < span then
        Err(InvalidLength)
    else if span == 0 then
        Ok(1)
    else if span == 1 then
        List.max(digit_list)
    else
        List.range({ start: At(0), end: At(List.len(digit_list) - span) })
        |> List.map(|ix| List.sublist(digit_list, { start: ix, len: span }) |> List.walk(1, |total, digit| total * digit))
        |> List.max
