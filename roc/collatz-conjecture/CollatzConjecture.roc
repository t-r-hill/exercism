module [steps]

steps : U64 -> Result U64 _
steps = |number|
    if number <= 0 then
        Err("Input must be a positive integer")
    else
        Ok(steps_rec(number, 0).1)

steps_rec : U64, U64 -> (U64, U64)
steps_rec = |number, count|
    if number == 1 then
        (number, count)
    else if number % 2 == 0 then
        steps_rec(number // 2, count + 1)
    else
        steps_rec(3 * number + 1, count + 1)
