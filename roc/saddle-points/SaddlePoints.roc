module [saddle_points]

Forest : List (List U8)
Position : { row : U64, column : U64 }

saddle_points : Forest -> Set Position
saddle_points = |tree_heights|
    tree_heights
    |> List.map_with_index(
        |r, row_index|
            r
            |> List.walk_with_index(
                [],
                |max, height, column_index|
                    when max is
                        [] -> [{ max_height: height, position: { row: row_index, column: column_index } }]
                        [{ max_height }, ..] if height > max_height -> [{ max_height: height, position: { row: row_index, column: column_index } }]
                        [{ max_height }, ..] if height == max_height -> List.append(max, { max_height: height, position: { row: row_index, column: column_index } })
                        _ -> max,
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
                        |> Result.try(|row| List.get(row, max_in_row.position.column))
                        |> Result.with_default(0)
                    if height >= max_in_row.max_height then
                        Continue([max_in_row.position |> to_one_indexed])
                    else
                        Break([]),
            ),
    )
    |> Set.from_list

to_one_indexed : Position -> Position
to_one_indexed = |position|
    { row: position.row + 1, column: position.column + 1 }
