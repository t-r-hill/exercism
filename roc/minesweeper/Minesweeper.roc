module [annotate]

annotate : Str -> Str
annotate = |minefield|
    minefield_grid =
        minefield
        |> Str.split_on("\n")
        |> List.map(
            |row|
                row
                |> Str.to_utf8
                |> List.map(|square| if square == '*' then 1 else 0),
        )

    grid_row_length = minefield_grid |> List.get(0) |> Result.map_ok(|row| List.len(row)) |> Result.with_default(0)

    minefield_grid
    |> List.map_with_index(|_, row_index| mine_neighbours(minefield_grid, row_index, grid_row_length))
    |> List.intersperse(['\n'])
    |> List.join
    |> List.map2(minefield_grid |> List.intersperse([0]) |> List.join, |total, orig| if orig == 1 then '*' else if total == '0' then ' ' else total)
    |> Str.from_utf8_lossy

mine_neighbours : List (List U64), U64, U64 -> List U8
mine_neighbours = |grid, row_index, row_length|
    default_row = List.repeat(0, row_length)

    above =
        Num.sub_checked(row_index, 1)
        |> Result.try(|above_index| List.get(grid, above_index))
        |> Result.with_default(default_row)

    below =
        Num.add_checked(row_index, 1)
        |> Result.try(|below_index| List.get(grid, below_index))
        |> Result.with_default(default_row)

    right =
        grid
        |> List.get(row_index)
        |> Result.map_ok(|row| row |> List.drop_first(1) |> List.append(0))
        |> Result.with_default(default_row)

    left =
        grid
        |> List.get(row_index)
        |> Result.map_ok(|row| row |> List.drop_last(1) |> List.prepend(0))
        |> Result.with_default(default_row)

    above_left =
        Num.sub_checked(row_index, 1)
        |> Result.try(|above_index| List.get(grid, above_index))
        |> Result.map_ok(|row| row |> List.drop_last(1) |> List.prepend(0))
        |> Result.with_default(default_row)

    above_right =
        Num.sub_checked(row_index, 1)
        |> Result.try(|above_index| List.get(grid, above_index))
        |> Result.map_ok(|row| row |> List.drop_first(1) |> List.append(0))
        |> Result.with_default(default_row)

    below_left =
        Num.add_checked(row_index, 1)
        |> Result.try(|below_index| List.get(grid, below_index))
        |> Result.map_ok(|row| row |> List.drop_last(1) |> List.prepend(0))
        |> Result.with_default(default_row)

    below_right =
        Num.add_checked(row_index, 1)
        |> Result.try(|below_index| List.get(grid, below_index))
        |> Result.map_ok(|row| row |> List.drop_first(1) |> List.append(0))
        |> Result.with_default(default_row)

    [above_left, above, above_right, left, right, below_left, below, below_right]
    |> List.walk(
        default_row,
        |totals, neighbours|
            List.map2(totals, neighbours, |t, n| t + n),
    )
    |> List.map(|total| Num.to_u8(total) + '0')
