module [count_words]

count_words : Str -> Dict Str U64
count_words = |sentence|
    all_chars =
        sentence
        |> Str.with_ascii_lowercased
        |> Str.to_utf8
        |> List.append(' ')

    List.walk(
        all_chars,
        (Dict.empty({}), []),
        |(words, buffer), char|
            if is_separator(char) and to_word_no_quotes(buffer) != "" then
                (Dict.update(words, to_word_no_quotes(buffer), increment), [])
            else if is_separator(char) then
                (words, buffer)
            else
                (words, List.append(buffer, char)),
    ).0

is_separator : U8 -> Bool
is_separator = |char|
    ((char >= 'a' and char <= 'z') or (char >= '0' and char <= '9') or char == '\'')
    |> Bool.not

increment : Result U64 [Missing] -> Result U64 [Missing]
increment = |current_count|
    when current_count is
        Ok count -> Ok (count + 1)
        Err Missing -> Ok 1

to_word_no_quotes : List U8 -> Str
to_word_no_quotes = |chars|
    when chars is
        [first, .. as word, last] if first == '\'' and last == '\'' -> Str.from_utf8_lossy(word)
        [first, .. as word] if first == '\'' -> Str.from_utf8_lossy(word)
        [.. as word, last] if last == '\'' -> Str.from_utf8_lossy(word)
        word -> Str.from_utf8_lossy(word)
