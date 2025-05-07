module [spiral_matrix]

spiral_matrix : U64 -> List (List U64)
spiral_matrix = |size|
    0
    |> List.repeat(size)
    |> List.repeat(size)
    |> spiral_matrix_helper(1, 0, 0, Right)

Direction : [Up, Down, Left, Right]

spiral_matrix_helper : List (List U64), U64, U64, U64, Direction -> List (List U64)
spiral_matrix_helper = |matrix, value, row_index, col_index, direction|
    if List.len(matrix) * List.len(matrix) < value then
        matrix
    else
        (next_row_index, next_col_index, next_direction) = determine_next_update(matrix, row_index, col_index, direction)
        matrix
        |> update_matrix(value, row_index, col_index)
        |> spiral_matrix_helper(value + 1, next_row_index, next_col_index, next_direction)

update_matrix : List (List U64), U64, U64, U64 -> List (List U64)
update_matrix = |matrix, value, row_index, col_index|
    List.update(matrix, row_index, |row| List.set(row, col_index, value))

determine_next_update : List (List U64), U64, U64, Direction -> (U64, U64, Direction)
determine_next_update = |matrix, row_index, col_index, direction|
    when direction is
        Right ->
            when List.get(matrix, row_index) |> Result.try(|row| row |> List.get(col_index + 1)) is
                Ok cell_value if cell_value == 0 -> (row_index, col_index + 1, Right)
                Ok _ | Err _ -> (row_index + 1, col_index, Down)

        Down ->
            when List.get(matrix, row_index + 1) |> Result.try(|row| row |> List.get(col_index)) is
                Ok cell_value if cell_value == 0 -> (row_index + 1, col_index, Down)
                Ok _ | Err _ -> (row_index, col_index - 1, Left)

        Left ->
            if col_index == 0 then
                (row_index - 1, col_index, Up)
            else
                when List.get(matrix, row_index) |> Result.try(|row| row |> List.get(col_index - 1)) is
                    Ok cell_value if cell_value == 0 -> (row_index, col_index - 1, Left)
                    Ok _ | Err _ -> (row_index - 1, col_index, Up)

        Up ->
            when List.get(matrix, row_index - 1) |> Result.try(|row| row |> List.get(col_index)) is
                Ok cell_value if cell_value == 0 -> (row_index - 1, col_index, Up)
                Ok _ | Err _ -> (row_index, col_index + 1, Right)
