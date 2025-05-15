module [encode, decode]

encode : List U32 -> List U8
encode = |integers|
    integers
    |> List.join_map(|u32_integer| encode_u32_helper([], u32_integer))

decode : List U8 -> Result (List U32) _
decode = |bytes|
    when bytes is
        [] -> Err(EmptyInput)
        [.., last] if last > 127 -> Err(InvalidInput)
        _ ->
            bytes
            |> List.walk_try(
                ([], 0),
                |(result, sum), byte|
                    if byte > 127 then
                        new_sum = sum |> increment_sum(byte - 128)
                        Ok (result, new_sum)
                    else
                        new_sum = sum |> increment_sum(byte)
                        Ok (List.append(result, new_sum), 0),
            )
            |> Result.map_ok(|(result, _)| result)

encode_u32_helper : List U8, U32 -> List U8
encode_u32_helper = |result, integer|
    if !List.is_empty(result) and integer == 0 then
        result
    else
        byte = least_sig_7_bytes_as_u8(integer) + if List.is_empty(result) then 0 else 128
        result
        |> List.prepend(byte)
        |> encode_u32_helper(Num.shift_right_zf_by(integer, 7))

least_sig_7_bytes_as_u8 : U32 -> U8
least_sig_7_bytes_as_u8 = |u32_integer|
    u32_integer
    |> Num.bitwise_and(127)
    |> Num.to_u8

increment_sum : U32, U8 -> U32
increment_sum = |sum, byte|
    sum
    |> Num.shift_left_by(7)
    |> Num.add(byte |> Num.to_u32)
