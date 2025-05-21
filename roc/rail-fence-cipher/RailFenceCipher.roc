module [encode, decode]

encode : Str, U64 -> Result Str _
encode = |message, rails|
    message
    |> Str.to_utf8
    |> List.walk_with_index(List.repeat([], rails), assign_char_to_rail)
    |> List.join
    |> Str.from_utf8

decode : Str, U64 -> Result Str _
decode = |encrypted, rails|
    chars = encrypted |> Str.to_utf8
    small_chunk_size = List.len(chars) |> Num.div_trunc((rails - 1) * 2)
    large_chunk_size = List.len(chars) |> Num.div_ceil((rails - 1) * 2)
    num_large_chunks = List.len(chars) |> Num.rem((rails - 1) * 2)

    chunked =
        chars
        |> List.take_first(large_chunk_size * num_large_chunks)
        |> List.chunks_of(large_chunk_size)
        |> List.concat(
            chars
            |> List.drop_first(large_chunk_size * num_large_chunks)
            |> List.chunks_of(small_chunk_size),
        )

    rows =
        when chunked is
            [first, .. as rest, last] ->
                [first]
                |> List.concat(
                    rest
                    |> List.chunks_of(2)
                    |> List.map(|chunks| List.join(chunks)),
                )
                |> List.append(last)

            _ -> chunked

    denorm =
        rows
        |> List.walk_backwards(
            (rows, rails - 1),
            |(result, ix), row|
                if ix == 0 then
                    (result, ix)
                else if ix == rails - 1 then
                    (result, ix - 1)
                else
                    { odds, evens } = odd_even_indexes(row)
                    (result |> List.set(ix, odds) |> List.append(evens), ix - 1),
        )
        |> .0

    List.range({ start: At 0, end: Length List.len(Result.with_default(List.get(rows, 0), [])) })
    |> List.walk(
        [],
        |result, ix|
            denorm
            |> List.walk(
                result,
                |result_nest, row|
                    result_nest
                    |> List.append(row |> List.get(ix)),
            ),
    )
    |> List.keep_oks(|char| char)
    |> Str.from_utf8

assign_char_to_rail : List List U8, U8, U64 -> List List U8
assign_char_to_rail = |rails, ch, ix|
    mod = (List.len(rails) - 1) * 2
    rem = Num.rem(ix, mod)
    rail_to_update = if rem > mod // 2 then mod - rem else rem
    List.update(rails, rail_to_update, |rail| List.append(rail, ch))

odd_even_indexes : List U8 -> { odds : List U8, evens : List U8 }
odd_even_indexes = |list|
    half_len = List.len(list) // 2
    list
    |> List.walk_with_index(
        { odds: List.with_capacity(half_len), evens: List.with_capacity(half_len) },
        |result, elem, ix|
            if ix % 2 == 0 then
                { result & odds: result.odds |> List.append(elem) }
            else
                { result & evens: result.evens |> List.append(elem) },
    )
