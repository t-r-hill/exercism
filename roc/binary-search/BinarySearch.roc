module [find]

find : List U64, U64 -> Result U64 _
find = |array, value|
    find_recurse(array, value, 0, List.len(array) - 1)

find_recurse : List U64, U64, U64, U64 -> Result U64 _
find_recurse = |list, value, low, high|
    if List.len(list) == 0 then
        Err(NotFound)
    else
        mid = (low + high) // 2
        if List.get(list, mid)? == value then
            Ok(mid)
        else if List.get(list, mid)? < value then
            find_recurse(list, value, mid + 1, high)
        else
            find_recurse(list, value, low, mid - 1)
