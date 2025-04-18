module [latest, personal_best, personal_top_three]

Score : U64

latest : List Score -> Result Score _
latest = |scores|
    when scores is
        [] -> Err "No scores recorded"
        [.., tail] -> Ok tail

personal_best : List Score -> Result Score _
personal_best = |scores|
    List.max(scores)

personal_top_three : List Score -> List Score
personal_top_three = |scores|
    List.walk(
        scores,
        [],
        |top3, elem|
            when top3 is
                [] | [_] | [_, _] -> List.sort_desc(List.append(top3, elem))
                [a, b, c] if elem > c -> List.sort_desc([a, b, elem])
                _ -> top3,
    )
