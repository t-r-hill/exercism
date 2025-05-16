module [flatten]

NestedValue : [Value I64, Null, NestedArray (List NestedValue)]

flatten : NestedValue -> List I64
flatten = |array|
    flatten_helper([], [array])

flatten_helper : List I64, List NestedValue -> List I64
flatten_helper = |result, array|
    when array is
        [] -> result
        [first, .. as rest] ->
            when first is
                Value num -> List.append(result, num) |> flatten_helper(rest)
                Null -> result |> flatten_helper(rest)
                NestedArray nested_array -> result |> flatten_helper(nested_array |> List.concat(rest))
