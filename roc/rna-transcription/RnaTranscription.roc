module [to_rna]

to_rna : Str -> Str
to_rna = |dna|
    Str.to_utf8 dna
        |> List.map |base|
            complement base |> Result.with_default 'X'
        |> Str.from_utf8_lossy

complement : U8 -> Result U8 [NoMatch(U8)]
complement = |base|
    when base is
        'A' -> Ok 'U'
        'C' -> Ok 'G'
        'G' -> Ok 'C'
        'T' -> Ok 'A'
        x -> Err NoMatch(x)
