module [to_protein]

AminoAcid : [Cysteine, Leucine, Methionine, Phenylalanine, Serine, Tryptophan, Tyrosine]
Protein : List AminoAcid

to_protein : Str -> Result Protein _
to_protein = |rna|
    rna
    |> Str.to_utf8
    |> List.chunks_of(3)
    |> List.walk_until(
        List.with_capacity(1) |> Ok,
        |protein_result, codon|
            when codon is
                ['A', 'U', 'G'] -> add_codon(protein_result, Methionine) |> Continue
                ['U', 'U', 'U'] | ['U', 'U', 'C'] -> add_codon(protein_result, Phenylalanine) |> Continue
                ['U', 'A', 'U'] | ['U', 'A', 'C'] -> add_codon(protein_result, Tyrosine) |> Continue
                ['U', 'G', 'G'] -> add_codon(protein_result, Tryptophan) |> Continue
                ['U', 'G', 'U'] | ['U', 'G', 'C'] -> add_codon(protein_result, Cysteine) |> Continue
                ['U', 'U', 'A'] | ['U', 'U', 'G'] -> add_codon(protein_result, Leucine) |> Continue
                ['U', 'C', 'U'] | ['U', 'C', 'C'] | ['U', 'C', 'A'] | ['U', 'C', 'G'] -> add_codon(protein_result, Serine) |> Continue
                ['U', 'A', 'A'] | ['U', 'A', 'G'] | ['U', 'G', 'A'] -> Break (protein_result)
                _ -> Break(Err(InvalidCodon)),
    )

add_codon : Result Protein _, AminoAcid -> Result Protein _
add_codon = |protein_result, amino_acid|
    protein_result
    |> Result.map_ok(|protein| List.append(protein, amino_acid))
