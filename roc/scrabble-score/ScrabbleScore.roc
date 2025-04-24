module [score]

score : Str -> U64
score = |word|
    Str.with_ascii_lowercased(word)
    |> Str.to_utf8
    |> List.map (|char| List.get(letter_scores, Num.to_u64(char - 'a')) ?? 0)
    |> List.sum

letter_scores : List U64
letter_scores = [1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10]
