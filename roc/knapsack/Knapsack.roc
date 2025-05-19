module [maximum_value]

Item : { weight : U64, value : U64 }

maximum_value : { items : List Item, maximum_weight : U64 } -> U64
maximum_value = |{ items, maximum_weight }|
    valid_knapsacks(items, 0, maximum_weight)
    |> List.max
    |> Result.with_default(0)

valid_knapsacks : List Item, U64, U64 -> List U64
valid_knapsacks = |candidates, knapsack_value, max_weight|
    when candidates is
        [first, .. as rest] if first.weight <= max_weight ->
            valid_knapsacks(rest, knapsack_value + first.value, max_weight - first.weight)
            |> List.concat(valid_knapsacks(rest, knapsack_value, max_weight))

        [_, .. as rest] ->
            valid_knapsacks(rest, knapsack_value, max_weight)

        [] -> [knapsack_value]
