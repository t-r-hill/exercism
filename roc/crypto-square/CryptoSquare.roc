module [ciphertext]

ciphertext : Str -> Result Str _
ciphertext = |text|
    parsed =
        text
        |> Str.with_ascii_lowercased
        |> Str.to_utf8
        |> List.keep_if(|ch| (ch >= 'a' and ch <= 'z') or (ch >= '0' and ch <= '9'))

    len = parsed |> List.len

    when len is
        0 -> Ok("")
        l ->
            parsed
            |> List.chunks_of(l |> Num.to_f64 |> Num.sqrt |> Num.ceiling)
            |> transpose
            |> List.intersperse([' '])
            |> List.join
            |> Str.from_utf8

transpose : List (List U8) -> List (List U8)
transpose = |chunks|
    when chunks is
        [[], ..] -> []
        _ ->
            firsts = chunks |> List.map(|chunk| chunk |> List.first |> Result.with_default ' ')
            tails = chunks |> List.map(|chunk| chunk |> List.drop_first(1))
            [firsts] |> List.concat(transpose(tails))
