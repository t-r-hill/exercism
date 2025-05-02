module [reverse]

import unicode.Grapheme

reverse : Str -> Str
reverse = |string|
    string
    |> Grapheme.split
    |> Result.with_default([])
    |> List.reverse
    |> Str.join_with("")
