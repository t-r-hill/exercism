module [keep, discard]

keep : List a, (a -> Bool) -> List a
keep = |list, predicate|
    helper(list, 0, |a| predicate(a) |> Bool.not)

discard : List a, (a -> Bool) -> List a
discard = |list, predicate|
    helper(list, 0, predicate)

helper : List a, U64, (a -> Bool) -> List a
helper = |list, index, predicate|
    when List.get(list, index) |> Result.map_ok(predicate) is
        Ok(bool) if bool -> List.drop_at(list, index) |> helper(index, predicate)
        Ok(_) -> helper(list, index + 1, predicate)
        Err _ -> list
