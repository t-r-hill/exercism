module [convert]

convert : U64 -> Str
convert = |number|
    result =
        (
            if number % 3 == 0 then
                "Pling"
            else
                ""
        )
        |> Str.concat(if number % 5 == 0 then "Plang" else "")
        |> Str.concat(if number % 7 == 0 then "Plong" else "")

    if result == "" then Num.to_str(number) else result
