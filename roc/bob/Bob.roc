module [response]

response : Str -> Str
response = |hey_bob|
    trimmed = Str.trim_end(hey_bob)
    if trimmed == "" then
        "Fine. Be that way!"
    else
        upper = is_upper(trimmed)
        question = Str.ends_with(trimmed, "?")
        if upper and question then
            "Calm down, I know what I'm doing!"
        else if upper then
            "Whoa, chill out!"
        else if question then
            "Sure."
        else
            "Whatever."

is_lower_char : U8 -> Bool
is_lower_char = |char|
    char >= 'a' and char <= 'z'

is_upper_char : U8 -> Bool
is_upper_char = |char|
    char >= 'A' and char <= 'Z'

is_upper : Str -> Bool
is_upper = |str|
    List.walk_until(
        Str.to_utf8(str),
        Bool.false,
        |state, char|
            if is_lower_char(char) then
                Break Bool.false
            else if is_upper_char(char) then
                Continue Bool.true
            else
                Continue state,
    )
