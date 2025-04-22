module [recite]

recite : List Str -> Str
recite = |strings|
    when List.len(strings) is
        0 -> ""
        len -> List.sublist(strings, { start: 0, len: len - 1 })
                |> List.map2(
                    List.sublist(strings, { start: 1, len: len - 1 }),
                    |word1, word2|
                        "For want of a ${word1} the ${word2} was lost."
                )
                    |> List.append("And all for the want of a ${Result.with_default(List.first(strings), "")}.")
                    |> Str.join_with("\n")
