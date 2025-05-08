module [transpose]

transpose : Str -> Str
transpose = |string|
    string
    |> Str.split_on("\n")
    |> List.walk_with_index(
        [[]],
        |transp_r, row, row_index|
            row
            |> Str.to_utf8
            |> List.walk_with_index(
                transp_r,
                |transp_c, elem, col_index|
                    when transp_c |> List.get(col_index) is
                        Ok transp_row ->
                            transp_c
                            |> List.set(
                                col_index,
                                transp_row
                                |> List.concat(List.repeat(' ', row_index - List.len(transp_row)))
                                |> List.append(elem),
                            )

                        Err _ -> transp_c |> List.append(List.repeat(' ', row_index) |> List.append(elem)),
            ),
    )
    |> List.map(|chars| Str.from_utf8_lossy(chars))
    |> Str.join_with("\n")
