module [find_anagrams]

import unicode.Grapheme

find_anagrams : Str, List Str -> List Str
find_anagrams = |subject, candidates|
    subject_norm = subject |> as_lists_u8 |> List.sort_with(compare_list_u8)
    candidates
    |> List.map(|candidate| (candidate, candidate |> as_lists_u8 |> List.sort_with(compare_list_u8)))
    |> List.drop_if(|(candidate, candidate_norm)| Str.with_ascii_lowercased(candidate) == Str.with_ascii_lowercased(subject) or candidate_norm != subject_norm)
    |> List.map(|pair| pair.0)


as_lists_u8 : Str -> List List(U8)
as_lists_u8 = |str|
    str
    |> Grapheme.split
    |> Result.with_default([])
    |> List.map(|grapheme| grapheme |> Str.to_utf8)
    |> List.map(|grapheme_as_list|
        when grapheme_as_list is
            [u8_byte] if u8_byte >= 'A' and u8_byte <= 'Z' -> [u8_byte - 'A' + 'a']
            _ -> grapheme_as_list
    )

compare_list_u8 : List U8, List U8 -> [LT, GT, EQ]
compare_list_u8 = |list1, list2|
    if list1 == list2 then
        EQ
    else
        when Num.compare(List.len(list1), List.len(list2)) is
            GT -> GT
            LT -> LT
            EQ ->
                List.map2(list1, list2, |a, b| (a, b))
                |> List.walk_until(
                    EQ,
                    |_, (elem1, elem2)|
                        when Num.compare(elem1, elem2) is
                            LT -> Break LT
                            GT -> Break GT
                            EQ -> Continue EQ
                )
