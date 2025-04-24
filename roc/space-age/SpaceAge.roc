module [age]

Planet : [
    Mercury,
    Venus,
    Earth,
    Mars,
    Jupiter,
    Saturn,
    Uranus,
    Neptune,
]

earth_year_in_seconds = 31557600

age : Planet, Dec -> Dec
age = |planet, seconds|
    seconds
    / earth_year_in_seconds
    /
    when planet is
        Mercury -> 0.2408467
        Venus -> 0.61519726
        Earth -> 1.0
        Mars -> 1.8808158
        Jupiter -> 11.862615
        Saturn -> 29.447498
        Uranus -> 84.016846
        Neptune -> 164.79132
