module [is_valid]

is_valid : Str -> Bool
is_valid = |isbn|
    chars = Str.to_utf8(isbn) |> List.drop_if(|c| c == '-')
    if List.len(chars) != 10 then
        Bool.false
    else
        chars
        |> List.map_with_index(|c, i| (c, i))
        |> List.map_try(
            |(c, i)|
                if c >= '0' and c <= '9' then
                    Ok(Num.to_u64(c - '0') * (10 - i))
                else if c == 'X' and i == List.len(chars) - 1 then
                    Ok(10)
                else
                    Err("Invalid character"),
        )
        |> Result.map_ok(|nums| List.sum(nums))
        |> Result.map_ok(|sum| Num.rem(sum, 11))
        |> Result.map_ok(|remainder| Bool.is_eq(remainder, 0))
        |> Result.with_default(Bool.false)
