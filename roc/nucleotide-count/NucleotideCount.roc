module [nucleotide_counts]

nucleotide_counts : Str -> Result { a : U64, c : U64, g : U64, t : U64 } _
nucleotide_counts = |input|
    input
    |> Str.to_utf8
    |> List.walk_try(
        { a: 0, c: 0, g: 0, t: 0 },
        |counts, nuc|
            when nuc is
                'A' -> Ok({ counts & a: counts.a + 1})
                'C' -> Ok({ counts & c: counts.c + 1})
                'G' -> Ok({ counts & g: counts.g + 1})
                'T' -> Ok({ counts & t: counts.t + 1})
                _ -> Err "Invalid nucleotide",
    )
