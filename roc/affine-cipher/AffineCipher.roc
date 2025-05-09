module [encode, decode]

encode : Str, { a : U64, b : U64 } -> Result Str _
encode = |phrase, key|
    if is_coprime(key.a) then
        phrase
        |> Str.to_utf8
        |> List.walk([], parse_chars)
        |> List.map(|char| encode_char(char, key.a, key.b))
        |> List.map(un_parse_char)
        |> List.chunks_of(5)
        |> List.map(|chars| Str.from_utf8_lossy(chars))
        |> Str.join_with(" ")
        |> Ok
    else
        Err KeyNotCoPrime

decode : Str, { a : U64, b : U64 } -> Result Str _
decode = |phrase, key|
    mmi = get_mmi(key.a)?
    phrase
    |> Str.to_utf8
    |> List.walk([], parse_chars)
    |> List.map(|char| decode_char(char, mmi, key.b))
    |> List.map(un_parse_char)
    |> Str.from_utf8_lossy
    |> Ok

parse_chars : List [Letter U8, Number U8], U8 -> List [Letter U8, Number U8]
parse_chars = |chars, char|
    if char >= 'A' and char <= 'Z' then
        List.append(chars, Letter(char - 'A'))
    else if char >= 'a' and char <= 'z' then
        List.append(chars, Letter(char - 'a'))
    else if char >= '0' and char <= '9' then
        List.append(chars, Number(char))
    else
        chars

un_parse_char : [Letter U8, Number U8] -> U8
un_parse_char = |parsed|
    when parsed is
        Letter(char) -> char + 'a'
        Number(char) -> char

encode_char : [Letter U8, Number U8], U64, U64 -> [Letter U8, Number U8]
encode_char = |char, a, b|
    when char is
        Letter(parsed) ->
            (a * Num.to_u64(parsed) + b)
            |> Num.rem(26)
            |> Num.to_u8
            |> Letter

        Number(_) -> char

decode_char : [Letter U8, Number U8], U64, U64 -> [Letter U8, Number U8]
decode_char = |char, mmi, b|
    when char is
        Letter(parsed) ->
            (mmi * (Num.to_u64(parsed) + 26 - Num.rem(b, 26)))
            |> Num.rem(26)
            |> Num.to_u8
            |> Letter

        Number(_) -> char

is_coprime : U64 -> Bool
is_coprime = |num|
    if Num.bitwise_and(num, 1) == 0 then
        Bool.false
    else
        Num.is_multiple_of(num, 13) |> Bool.not

get_mmi : U64 -> Result U64 [KeyNotCoPrime]
get_mmi = |num|
    if is_coprime(num) then
        norm = Num.rem(num, 26)
        List.range({ start: At 0, end: Before 26 })
        |> List.walk_until(
            Err(KeyNotCoPrime),
            |_, x|
                if Num.rem(x * norm, 26) == 1 then
                    Break(Ok(x))
                else
                    Continue(Err(KeyNotCoPrime)),
        )
    else
        Err(KeyNotCoPrime)
