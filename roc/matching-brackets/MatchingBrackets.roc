module [is_paired]

is_paired : Str -> Bool
is_paired = |string|
    string
    |> Str.to_utf8
    |> List.walk_until(
        List.with_capacity(10),
        |stack, elem|
            when elem is
                '(' | '[' | '{' -> Continue(List.append(stack, elem))
                ')' if List.last(stack) == Ok('(') -> Continue(List.drop_last(stack, 1))
                ')' -> Break(List.append(stack, elem))
                ']' if List.last(stack) == Ok('[') -> Continue(List.drop_last(stack, 1))
                ']' -> Break(List.append(stack, elem))
                '}' if List.last(stack) == Ok('{') -> Continue(List.drop_last(stack, 1))
                '}' -> Break(List.append(stack, elem))
                _ -> Continue(stack),
    )
    |> List.is_empty
