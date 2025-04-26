module [find]

find : List U64, U64 -> Result U64 _
find = |array, value|
    find_recurse(array, value, 0, array |> List.len |> Num.sub_saturated 1)

find_recurse : List U64, U64, U64, U64 -> Result U64 _
find_recurse = |list, value, low, high|
    if low == high and List.get(list, low)? != value then
        Err(NotFound)
    else
        mid = (low + high) // 2
        if List.get(list, mid)? == value then
            Ok(mid)
        else if List.get(list, mid)? < value then
            find_recurse(list, value, mid + 1, high)
        else
            find_recurse(list, value, low, Num.sub_saturated(mid, 1))
