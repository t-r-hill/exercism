module [pascals_triangle]

pascals_triangle : U64 -> List (List U64)
pascals_triangle = |count|
    List.range({ start: At 1, end: Before count })
    |> List.walk(
        [1] |> List.repeat(count),
        |result, index|
            prev = List.get(result, index - 1) ?? List.single(1)
            List.set(result, index, next_row(prev, index)),
    )

next_row : List U64, U64 -> List U64
next_row = |prev, index|
    List.range({ start: At 0, end: At index })
    |> List.map(
        |i|
            if i == 0 or i == index then
                1
            else
                List.sublist(prev, { start: i - 1, len: 2 }) |> List.sum,
    )
