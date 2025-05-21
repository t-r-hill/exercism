module [abbreviate]

abbreviate : Str -> Str
abbreviate = |text|
    text
    |> Str.with_ascii_uppercased
    |> Str.to_utf8
    |> List.keep_if(is_valid_char)
    |> List.walk(
        ([], Separator),
        |(buffer, prev_char), char|
            when prev_char is
                Separator if is_separator(char) -> (buffer, Separator)
                Separator -> (List.append(buffer, char), Letter)
                Letter if is_separator(char) -> (buffer, Separator)
                Letter -> (buffer, Letter),
    )
    |> .0
    |> Str.from_utf8_lossy

is_valid_char : U8 -> Bool
is_valid_char = |char|
    (char >= 'a' and char <= 'z')
    or (char >= 'A' and char <= 'Z')
    or char
    == ' '
    or char
    == '-'

is_separator : U8 -> Bool
is_separator = |char|
    char == ' ' or char == '-'
