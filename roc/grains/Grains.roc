module [grains_on_square, total_grains]

grains_on_square : U8 -> Result U64 _
grains_on_square = |square|
    if square > 64 or square < 1 then
        Err("square must be between 1 and 64")
    else
        Ok(Num.shift_left_by(1, square - 1))

total_grains : U64
total_grains = Num.max_u64
