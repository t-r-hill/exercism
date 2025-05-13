module [convert]

convert : Str -> Result Str _
convert = |grid|
    grid
    |> Str.split_on("\n")
    |> List.chunks_of(4)
    |> List.map_try(
        |rows|
            row_0 = get_chars_from_row(rows, 0)?
            row_1 = get_chars_from_row(rows, 1)?
            row_2 = get_chars_from_row(rows, 2)?
            row_3 = get_chars_from_row(rows, 3)?
            Ok(List.map4(row_0, row_1, row_2, row_3, |a, b, c, d| (a, b, c, d))),
    )
    |> Result.try |rows|
        rows
        |> List.map_try |columns|
            columns
            |> List.chunks_of(3)
            |> List.map_try(parse_num)
            |> Result.map_ok |num|
                num
                |> Str.from_utf8_lossy
        |> Result.map_ok |nums|
            nums
            |> Str.join_with(",")

parse_num : List (U8, U8, U8, U8) -> Result U8 _
parse_num = |grid|
    when grid is
        [(' ', '|', '|', ' '), ('_', ' ', '_', ' '), (' ', '|', '|', ' ')] -> Ok('0')
        [(' ', ' ', ' ', ' '), (' ', ' ', ' ', ' '), (' ', '|', '|', ' ')] -> Ok('1')
        [(' ', ' ', '|', ' '), ('_', '_', '_', ' '), (' ', '|', ' ', ' ')] -> Ok('2')
        [(' ', ' ', ' ', ' '), ('_', '_', '_', ' '), (' ', '|', '|', ' ')] -> Ok('3')
        [(' ', '|', ' ', ' '), (' ', '_', ' ', ' '), (' ', '|', '|', ' ')] -> Ok('4')
        [(' ', '|', ' ', ' '), ('_', '_', '_', ' '), (' ', ' ', '|', ' ')] -> Ok('5')
        [(' ', '|', '|', ' '), ('_', '_', '_', ' '), (' ', ' ', '|', ' ')] -> Ok('6')
        [(' ', ' ', ' ', ' '), ('_', ' ', ' ', ' '), (' ', '|', '|', ' ')] -> Ok('7')
        [(' ', '|', '|', ' '), ('_', '_', '_', ' '), (' ', '|', '|', ' ')] -> Ok('8')
        [(' ', '|', ' ', ' '), ('_', '_', '_', ' '), (' ', '|', '|', ' ')] -> Ok('9')
        [(_, _, _, _), (_, _, _, _), (_, _, _, _)] -> Ok('?')
        _ -> Err(InvalidInput)

get_chars_from_row : List Str, U64 -> Result (List U8) _
get_chars_from_row = |rows, row_num|
    List.get(rows, row_num)
    |> Result.map_ok Str.to_utf8
