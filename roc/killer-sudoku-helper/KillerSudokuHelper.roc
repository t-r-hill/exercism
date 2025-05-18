module [combinations]

Combination : List U8

combinations : { sum : U8, size : U8, exclude ?? List U8 } -> List Combination
combinations = |{ sum, size, exclude ?? [] }|
    [1, 2, 3, 4, 5, 6, 7, 8, 9]
    |> List.drop_if(|num| List.contains(exclude, num))
    |> find_combinations([], sum, size)
    |> List.drop_if(|combination| List.is_empty(combination))

find_combinations : List U8, List U8, U8, U8 -> List Combination
find_combinations = |candidates, combination, target_sum, target_size|
    if target_size == 0 and target_sum == 0 then
        [combination]
    else if target_size == 0 or target_sum == 0 then
        [[]]
    else
        min_possible = List.take_first(candidates, target_size |> Num.to_u64) |> List.sum
        max_possible = List.take_last(candidates, target_size |> Num.to_u64) |> List.sum

        if target_sum < min_possible or target_sum > max_possible then
            [[]]
        else
            when candidates is
                [first, .. as rest] ->
                    find_combinations(rest, List.append(combination, first), target_sum - first, target_size - 1)
                    |> List.concat(find_combinations(rest, combination, target_sum, target_size))

                _ -> crash("should not be possible")
