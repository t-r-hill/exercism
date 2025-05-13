module [classify]

classify : U64 -> Result [Abundant, Deficient, Perfect] _
classify = |number|
    if number == 0 then
        Err(NotPositiveInteger)
    else if number == 1 then
        Ok(Deficient)
    else
        when Num.compare(aliquot_sum(number), number) is
            GT -> Ok(Abundant)
            LT -> Ok(Deficient)
            EQ -> Ok(Perfect)

aliquot_sum : U64 -> U64
aliquot_sum = |number|
    List.range({ start: At 1, end: At Num.div_ceil(number, 2) })
    |> List.keep_if(|x| Num.rem(number, x) == 0)
    |> List.sum
