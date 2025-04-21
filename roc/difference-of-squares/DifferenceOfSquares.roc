module [square_of_sum, sum_of_squares, difference_of_squares]

square_of_sum : U64 -> U64
square_of_sum = |number|
    number
    + 1
    |> Num.mul(number)
    |> Num.div_trunc(2)
    |> Num.pow_int(2)

sum_of_squares : U64 -> U64
sum_of_squares = |number|
    number
    |> Num.mul(number + 1)
    |> Num.mul(2 * number + 1)
    |> Num.div_trunc(6)

difference_of_squares : U64 -> U64
difference_of_squares = |number|
    n = number
    n2 = number * number
    n3 = n2 * n
    n4 = n3 * n
    3
    |> Num.mul(n4)
    |> Num.add(2 * n3)
    |> Num.sub(3 * n2)
    |> Num.sub(2 * n)
    |> Num.div_trunc(12)
