module [rotate]

rotate : Str, U8 -> Str
rotate = |text, shift_key|
    text
    |> Str.to_utf8
    |> List.map(
        |char|
            if char >= 'a' and char <= 'z' then
                (char - 'a' + shift_key) % 26 + 'a'
            else if char >= 'A' and char <= 'Z' then
                (char - 'A' + shift_key) % 26 + 'A'
            else
                char,
    )
    |> Str.from_utf8_lossy
