module [commands]

commands : U64 -> List Str
commands = |number|
    initial =
        List.keep_if(actions, |(_, action_key)| Num.bitwise_and(number, action_key) > 0)
        |> List.map(|(action, _)| action)
    if number > 16 then
        initial |> List.reverse
    else
        initial

actions : List (Str, U64)
actions = [("wink", 1), ("double blink", 2), ("close your eyes", 4), ("jump", 8)]
