module [say]

say : U64 -> Result Str [OutOfBounds]
say = |number|
    when number is
        0 -> Ok "zero"
        num if num < 0 -> Err OutOfBounds
        num if num > 999_999_999_999 -> Err OutOfBounds
        num -> say_num(num) |> Str.join_with(" ") |> Ok

say_num : U64 -> List Str
say_num = |number|
    when number is
        num if num < 10 -> say_unit(num)
        num if num < 20 -> say_teen(num)
        num if num < 100 -> say_ten(num // 10) |> List.concat(say_unit(num % 10)) |> Str.join_with("-") |> List.single
        num if num < 1000 -> say_unit(num // 100) |> List.concat(["hundred"]) |> List.concat(say_num(num % 100))
        num if num < 1_000_000 -> say_num(num // 1000) |> List.concat(["thousand"]) |> List.concat(say_num(num % 1000))
        num if num < 1_000_000_000 -> say_num(num // 1_000_000) |> List.concat(["million"]) |> List.concat(say_num(num % 1_000_000))
        num if num < 1_000_000_000_000 -> say_num(num // 1_000_000_000) |> List.concat(["billion"]) |> List.concat(say_num(num % 1_000_000_000))
        _ -> []

say_unit : U64 -> List Str
say_unit = |number|
    when number is
        0 -> []
        1 -> ["one"]
        2 -> ["two"]
        3 -> ["three"]
        4 -> ["four"]
        5 -> ["five"]
        6 -> ["six"]
        7 -> ["seven"]
        8 -> ["eight"]
        9 -> ["nine"]
        _ -> []

say_teen : U64 -> List Str
say_teen = |number|
    when number is
        10 -> ["ten"]
        11 -> ["eleven"]
        12 -> ["twelve"]
        13 -> ["thirteen"]
        14 -> ["fourteen"]
        15 -> ["fifteen"]
        16 -> ["sixteen"]
        17 -> ["seventeen"]
        18 -> ["eighteen"]
        19 -> ["nineteen"]
        _ -> []

say_ten : U64 -> List Str
say_ten = |number|
    when number is
        2 -> ["twenty"]
        3 -> ["thirty"]
        4 -> ["forty"]
        5 -> ["fifty"]
        6 -> ["sixty"]
        7 -> ["seventy"]
        8 -> ["eighty"]
        9 -> ["ninety"]
        _ -> []
