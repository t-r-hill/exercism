module [transform]

transform : Dict U64 (List U8) -> Dict U8 U64
transform = |legacy|
    Dict.join_map(
        legacy,
        |key, value|
            List.walk(
                value,
                Dict.empty({}),
                |dict, elem|
                    Dict.insert(dict, elem + 32, key),
            ),
    )
