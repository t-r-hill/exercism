module [encode, decode]

encode : Str -> Result Str _
encode = |phrase|
    Str.to_utf8(phrase)
    |> List.keep_oks(convert_letter)
    |> List.chunks_of(5)
    |> List.map_try(|chunk| Str.from_utf8(chunk))
    |> Result.map_ok(|chunks| Str.join_with(chunks, " "))

decode : Str -> Result Str _
decode = |phrase|
    Str.to_utf8(phrase)
    |> List.keep_oks(convert_letter)
    |> Str.from_utf8

convert_letter : U8 -> Result U8 _
convert_letter = |char|
    if char >= 'a' and char <= 'z' then
        Ok('z' - char + 'a')
    else if char >= 'A' and char <= 'Z' then
        Ok('Z' - char + 'a')
    else if char >= '0' and char <= '9' then
        Ok(char)
    else
        Err("Invalid character")
