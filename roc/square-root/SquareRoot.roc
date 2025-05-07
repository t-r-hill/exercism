module [square_root]

square_root : U64 -> U64
square_root = |radicand|
    when radicand is
        0 -> 0
        1 -> 1
        n -> find_sqrt(1, n // 2 + 1, n)

find_sqrt : U64, U64, U64 -> U64
find_sqrt = |start, end, target|
    if end - start <= 1 then
        if end * end <= target then
            end
        else
            start
    else
        mid = (start + end) // 2
        candidate = mid * mid
        when candidate |> Num.compare(target) is
            EQ -> mid
            GT -> find_sqrt(start, mid, target)
            LT -> find_sqrt(mid, end, target)
