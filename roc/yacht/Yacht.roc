module [score]

Category : [Ones, Twos, Threes, Fours, Fives, Sixes, FullHouse, FourOfAKind, LittleStraight, BigStraight, Choice, Yacht]

score : List U8, Category -> U8
score = |dice, category|
    when category is
        Ones -> dice |> calc_n(1)
        Twos -> dice |> calc_n(2)
        Threes -> dice |> calc_n(3)
        Fours -> dice |> calc_n(4)
        Fives -> dice |> calc_n(5)
        Sixes -> dice |> calc_n(6)
        FullHouse -> dice |> calc_full_house
        FourOfAKind -> dice |> calc_four_of_a_kind
        LittleStraight -> dice |> calc_little_straight
        BigStraight -> dice |> calc_big_straight
        Choice -> dice |> List.sum
        Yacht -> if dice |> List.all(|di| di == List.get(dice, 0) ?? 0) then 50 else 0

calc_n : List U8, U8 -> U8
calc_n = |dice, n|
    dice
    |> List.map(|di| if di == n then n else 0)
    |> List.sum

calc_full_house : List U8 -> U8
calc_full_house = |dice|
    when dice |> List.sort_asc is
        [a, b, c, d, e] if a == b and b == c and c != d and d == e -> a * 3 + d * 2
        [a, b, c, d, e] if a == b and b != c and c == d and d == e -> a * 2 + d * 3
        _ -> 0

calc_four_of_a_kind : List U8 -> U8
calc_four_of_a_kind = |dice|
    when dice |> List.sort_asc is
        [_, b, .. as rest] if List.all(rest, |di| di == b) -> b * 4
        [.. as rest, d, _] if List.all(rest, |di| di == d) -> d * 4
        _ -> 0

calc_little_straight : List U8 -> U8
calc_little_straight = |dice|
    when dice |> List.sort_asc is
        [1, 2, 3, 4, 5] -> 30
        _ -> 0

calc_big_straight : List U8 -> U8
calc_big_straight = |dice|
    when dice |> List.sort_asc is
        [2, 3, 4, 5, 6] -> 30
        _ -> 0
