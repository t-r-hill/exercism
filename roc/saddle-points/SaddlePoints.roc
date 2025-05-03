module [saddle_points]

Forest : List (List U8)
Position : { row : U64, column : U64 }

saddle_points : Forest -> Set Position
saddle_points = |tree_heights|
    tree_heights
    |> List.map_with_index(
        |row, row_index|
            row
            |> List.walk_with_index(
                [],
                |max, height, column_index|
                    if height > Result.with_default(List.get(max, 0), { height: 0, column_index: 0, row_index: 0 }).height then
                        [{ height, column_index, row_index }]
                    else if height == Result.with_default(List.get(max, 0), { height: 0, column_index: 0, row_index: 0 }).height then
                        List.append(max, { height, column_index, row_index })
                    else
                        max,
            ),
    )
    |> List.join
    |> List.join_map(
        |max_in_row|
            List.range({ start: At 0, end: Before (List.len(tree_heights)) })
            |> List.walk_until(
                [],
                |_, row_index|
                    height =
                        List.get(tree_heights, row_index)
                        |> Result.try(|row| List.get(row, max_in_row.column_index))
                        |> Result.with_default(0)
                    if height >= max_in_row.height then
                        Continue([{ row: max_in_row.row_index + 1, column: max_in_row.column_index + 1 }])
                    else
                        Break([]),
            ),
    )
    |> Set.from_list
