module [row, column]

column : Str, U64 -> Result (List I64) _
column = |matrix_str, index|
    Str.split_on(matrix_str, "\n")
    |> List.map_try(|r| Str.split_on(r, " ") |> List.get(index - 1) |> Result.try(|num| Str.to_i64(num)))

row : Str, U64 -> Result (List I64) _
row = |matrix_str, index|
    Str.split_on(matrix_str, "\n")
    |> List.get(index - 1)?
    |> Str.split_on(" ")
    |> List.map_try(|num| Str.to_i64(num))
