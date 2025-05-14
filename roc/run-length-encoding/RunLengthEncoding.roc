module [encode, decode]

encode : Str -> Result Str _
encode = |string|
    string
    |> Str.to_utf8
    |> List.walk(
        ([], None),
        |(char_counts, prev), char|
            when prev is
                None -> ([(1, char)], Some(char))
                Some(prev_char) if prev_char == char ->
                    (List.update(char_counts, List.len(char_counts) - 1, |(count, prev_ch)| (count + 1, prev_ch)), Some(char))

                Some(_) -> (List.append(char_counts, (1, char)), Some(char)),
    )
    |> .0
    |> List.map(
        |(char_count, char)|
            if char_count == 1 then
                Str.from_utf8_lossy([char])
            else
                Num.to_str(char_count) |> Str.concat(Str.from_utf8_lossy([char])),
    )
    |> Str.join_with("")
    |> Ok

decode : Str -> Result Str _
decode = |string|
    string
    |> Str.to_utf8
    |> List.walk(
        ([], None),
        |(chars, prev), elem|
            when prev is
                None if elem >= '0' and elem <= '9' -> (chars, Some(elem - '0'))
                None -> (List.append(chars, elem), None)
                Some(prev_num) if elem >= '0' and elem <= '9' -> (chars, Some(prev_num * 10u8 + (elem - '0')))
                Some(prev_num) -> (List.concat(chars, List.repeat(elem, Num.to_u64(prev_num))), None),
    )
    |> .0
    |> Str.from_utf8
