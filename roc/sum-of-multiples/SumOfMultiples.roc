module [sum_of_multiples]

sum_of_multiples : List U64, U64 -> U64
sum_of_multiples = |factors, limit|
    factors
    |> Set.from_list
    |> Set.join_map(|factor| multiples(factor, limit))
    |> Set.walk(0, |sum, multiple| sum + multiple)

multiples : U64, U64 -> Set U64
multiples = |number, limit|
    when number is
        0 -> Set.single(0)
        x ->
            List.range({ start: At x, end: Before limit, step: x })
            |> Set.from_list
