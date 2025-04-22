module [value]

Color : [
    Black,
    Brown,
    Red,
    Orange,
    Yellow,
    Green,
    Blue,
    Violet,
    Grey,
    White,
]

value : Color, Color -> U8
value = |first, second|
    first
        |> color_value
        |> Num.mul 10
        |> Num.add (second
            |> color_value)

color_value : Color -> U8
color_value = |color|
    when color is
        Black -> 0
        Brown -> 1
        Red -> 2
        Orange -> 3
        Yellow -> 4
        Green -> 5
        Blue -> 6
        Violet -> 7
        Grey -> 8
        White -> 9
