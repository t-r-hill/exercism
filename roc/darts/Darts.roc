module [score]

score : F64, F64 -> U64
score = |x, y|
    mag = Num.sqrt(x * x + y * y)
    if mag <= 1 then
        10
    else if mag <= 5 then
        5
    else if mag <= 10 then
        1
    else
        0
