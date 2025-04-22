module [truncate]

import unicode.Grapheme

truncate : Str -> Result Str _
truncate = |input|
    Grapheme.split(input)
        |> Result.map_ok(|graphemes|
            graphemes
                |> List.take_first(5)
                |> Str.join_with("")
        )
