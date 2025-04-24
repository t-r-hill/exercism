module [slices]

slices : Str, U64 -> List Str
slices = |string, slice_length|
    string_len = Str.count_utf8_bytes(string)
    if slice_length > string_len or slice_length == 0 or string_len == 0 then
        []
    else
        { start: At 0, end: At (Str.count_utf8_bytes(string) - slice_length) }
        |> List.range
        |> List.map(|index| Str.to_utf8(string) |> List.sublist({ start: index, len: slice_length }) |> Str.from_utf8_lossy)
