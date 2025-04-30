module [triplets_with_sum]

Triplet : (U64, U64, U64)

triplets_with_sum : U64 -> Set Triplet
triplets_with_sum = |sum|
    List.range({ start: At(1), end: Before(sum // 3) })
    |> List.keep_oks(
        |a|
            # substitute b^2 = c^2 - a^2 into c = sum - a - b and simplify
            b = (Num.pow_int(sum, 2) - 2 * a * sum) // 2 * (sum - a)
            c = sum - a - b
            if a * a + b * b == c * c and a < b and b < c then
                Ok((a, b, c))
            else
                Err(InvalidCombo),
    )
    |> Set.from_list
