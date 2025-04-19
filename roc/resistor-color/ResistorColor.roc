module [color_code, colors]

color_code : Str -> Result U64 _
color_code = |color|
    List.find_first_index(colors, |item| item == color)

colors : List Str
colors = [
    "black",
    "brown",
    "red",
    "orange",
    "yellow",
    "green",
    "blue",
    "violet",
    "grey",
    "white",
]
