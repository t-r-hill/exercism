module [egg_count]

egg_count : U64 -> U64
egg_count = |number|
    egg_count_helper(0, number)

egg_count_helper : U64, U64 -> U64
egg_count_helper = |count, number|
    if number == 0 then
        count
    else
        number
        |> Num.bitwise_and(1)
        |> Num.add(count)
        |> egg_count_helper(number |> Num.shift_right_zf_by(1))
