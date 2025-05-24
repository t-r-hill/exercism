module [find_fewest_coins]

find_fewest_coins : List U64, U64 -> Result (List U64) _
find_fewest_coins = |coins, target|
    if target == 0 then
        Ok([])
    else
        find_fewest_helper(List.sort_desc(coins), target, [], Num.max_u64)
        |> Result.map_ok(|list| List.sort_asc(list))

find_fewest_helper : List U64, U64, List U64, U64 -> Result (List U64) _
find_fewest_helper = |coins, target, cur_coins, cur_fewest|
    dbg (coins, target, cur_coins, cur_fewest)
    if target == 0 and List.len(cur_coins) < cur_fewest then
        Ok cur_coins
    else if List.len(cur_coins) > cur_fewest then
        Err TooBig
    else
        when coins is
            [first, .. as rest] ->
                if target >= first then
                    in_place = find_fewest_helper(coins, target - first, List.append(cur_coins, first), cur_fewest)
                    skipped =
                        when in_place is
                            Ok coins_list -> find_fewest_helper(rest, target, cur_coins, List.len(coins_list))
                            Err _ -> find_fewest_helper(rest, target, cur_coins, cur_fewest)
                    if Result.is_ok(skipped) then
                        skipped
                    else
                        in_place
                else
                    find_fewest_helper(rest, target, cur_coins, cur_fewest)

            [] -> Err NotFound
