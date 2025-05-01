module [rectangles]

rectangles : Str -> U64
rectangles = |diagram|
    grid =
        diagram
        |> Str.split_on("\n")
        |> List.map(|row| row |> Str.to_utf8)

    grid
    |> List.map_with_index(
        |row, y_index|
            List.map_with_index(
                row,
                |cell, x_index|
                    if cell == '+' then
                        find_rectangles(grid, { x: x_index, y: y_index }, { x: x_index + 1, y: y_index }, Right)
                    else
                        0,
            )
            |> List.sum,
    )
    |> List.sum

Direction : [Up, Down, Left, Right]

find_rectangles : List (List U8), { x : U64, y : U64 }, { x : U64, y : U64 }, Direction -> U64
find_rectangles = |grid, origin, index, direction|
    when direction is
        Right ->
            when List.get(grid, index.y) |> Result.try(|row| List.get(row, index.x)) is
                Ok('-') -> find_rectangles(grid, origin, { x: index.x + 1, y: index.y }, Right)
                Ok('+') -> find_rectangles(grid, origin, { x: index.x, y: index.y + 1 }, Down) + find_rectangles(grid, origin, { x: index.x + 1, y: index.y }, Right)
                Ok(_) -> 0
                Err(_) -> 0

        Down ->
            when List.get(grid, index.y) |> Result.try(|row| List.get(row, index.x)) is
                Ok('|') -> find_rectangles(grid, origin, { x: index.x, y: index.y + 1 }, Down)
                Ok('+') -> find_rectangles(grid, origin, { x: index.x - 1, y: index.y }, Left) + find_rectangles(grid, origin, { x: index.x, y: index.y + 1 }, Down)
                Ok(_) -> 0
                Err(_) -> 0

        Left ->
            when List.get(grid, index.y) |> Result.try(|row| List.get(row, index.x)) is
                Ok('-') | Ok('+') if origin.x < index.x -> find_rectangles(grid, origin, { x: index.x - 1, y: index.y }, Left)
                Ok('+') if origin.x == index.x -> find_rectangles(grid, origin, { x: index.x, y: index.y - 1 }, Up)
                Ok(_) -> 0
                Err(_) -> 0

        Up ->
            when List.get(grid, index.y) |> Result.try(|row| List.get(row, index.x)) is
                Ok('|') | Ok('+') if origin.y < index.y -> find_rectangles(grid, origin, { x: index.x, y: index.y - 1 }, Up)
                Ok('+') if origin.y == index.y -> 1
                Ok(_) -> 0
                Err(_) -> 0
