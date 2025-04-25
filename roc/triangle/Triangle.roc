module [is_equilateral, is_isosceles, is_scalene]

is_equilateral : (F64, F64, F64) -> Bool
is_equilateral = |(x, y, z)|
    when (x, y, z) is
        (0, 0, 0) -> Bool.false
        (a, b, c) -> Num.compare(a, b) == EQ and Num.compare(b, c) == EQ

is_isosceles : (F64, F64, F64) -> Bool
is_isosceles = |(a, b, c)|
    (Num.compare(a, b) == EQ and Num.compare(c, a + b) == LT)
    or (Num.compare(b, c) == EQ and Num.compare(a, b + c) == LT)
    or (Num.compare(a, c) == EQ and Num.compare(b, a + c) == LT)

is_scalene : (F64, F64, F64) -> Bool
is_scalene = |(a, b, c)|
    when Num.compare(a, b) is
        EQ -> Bool.false
        GT ->
            when Num.compare(b, c) is
                EQ -> Bool.false
                GT -> Num.compare(a, b + c) == LT
                LT ->
                    when Num.compare(a, c) is
                        EQ -> Bool.false
                        GT -> Num.compare(a, b + c) == LT
                        LT -> Num.compare(c, a + b) == LT

        LT ->
            when Num.compare(b, c) is
                EQ -> Bool.false
                GT ->
                    when Num.compare(a, c) is
                        EQ -> Bool.false
                        GT -> Num.compare(a, b + c) == LT
                        LT -> Num.compare(c, a + b) == LT

                LT -> Num.compare(c, a + b) == LT
