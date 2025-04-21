module [is_isogram]

is_isogram : Str -> Bool
is_isogram = |phrase|
    phrase
    |> Str.walk_utf8(
        List.repeat(0, 26),
        |vec, char|
            char_u64 = Num.to_u64(char)
            if char >= 0x41 and char <= 0x5A then
                dbg List.replace(vec, char_u64 - 0x41, (List.get(vec, char_u64 - 0x41) ?? 0) + 1).list
            else if char >= 0x61 and char <= 0x7A then
                dbg List.replace(vec, char_u64 - 0x61, (List.get(vec, char_u64 - 0x61) ?? 0) + 1).list
            else
                dbg vec,
    )
    |> List.all(|count| count <= 1)
