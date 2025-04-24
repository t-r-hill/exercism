module [sublist]

sublist : List U8, List U8 -> [Equal, Sublist, Superlist, Unequal]
sublist = |list1, list2|
    when Num.compare(List.len(list1), List.len(list2)) is
        EQ ->
            if Bool.is_eq(list1, list2) then
                Equal
            else
                Unequal

        LT ->
            if is_sublist(list1, list2) then
                Sublist
            else
                Unequal

        GT ->
            if is_sublist(list2, list1) then
                Superlist
            else
                Unequal

is_sublist : List U8, List U8 -> Bool
is_sublist = |list1, list2|
    len_list1 = List.len(list1)
    diff = List.len(list2) - len_list1 + 1
    List.range({ start: At 0, end: Length diff })
    |> List.walk_until(
        Bool.false,
        |_, elem|
            if Bool.is_eq(List.sublist(list2, { start: elem, len: len_list1 }), list1) then
                Break Bool.true
            else
                Continue Bool.false,
    )
