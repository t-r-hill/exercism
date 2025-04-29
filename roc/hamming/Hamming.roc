module [distance]

distance : Str, Str -> Result (Num *) _
distance = |strand1, strand2|
    list_utf8_1 = Str.to_utf8(strand1)
    list_utf8_2 = Str.to_utf8(strand2)
    if List.len(list_utf8_1) != List.len(list_utf8_2) then
        Err("Strands must be of equal length")
    else
        List.map2(list_utf8_1, list_utf8_2, |a, b| if a == b then 0 else 1)
        |> List.sum
        |> Ok
