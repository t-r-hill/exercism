module [two_fer]

two_fer : [Name Str, Anonymous] -> Str
two_fer = |name|
    when name is
        Anonymous -> "One for you, one for me."
        Name name_str ->
            Str.concat("One for ", name_str)
            |> Str.concat(", one for me.")
