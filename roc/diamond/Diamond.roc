module [diamond]

Direction : [Up, Down]

diamond : U8 -> Str
diamond = |letter|
    diamond_recurse('A', letter, Up, []) |> Str.from_utf8_lossy

diamond_recurse : U8, U8, Direction, List U8 -> List U8
diamond_recurse = |cur, limit, direction, acc|
    pad = List.repeat(' ', Num.to_u64(limit - cur))
    if (acc != [] or limit == 'A') and cur == 'A' then
        line = pad |> List.append(cur) |> List.concat(pad)
        List.concat(acc, line)
    else if cur == 'A' then
        line = pad |> List.append(cur) |> List.concat(pad) |> List.append('\n')
        diamond_recurse(cur + 1, limit, Up, List.concat(acc, line))
    else if cur == limit then
        gap = List.repeat(' ', 2 * Num.to_u64(cur - 'A') - 1)
        line = pad |> List.append(cur) |> List.concat(gap) |> List.append(cur) |> List.concat(pad) |> List.append('\n')
        diamond_recurse(cur - 1, limit, Down, List.concat(acc, line))
    else
        gap = List.repeat(' ', 2 * Num.to_u64(cur - 'A') - 1)
        line = pad |> List.append(cur) |> List.concat(gap) |> List.append(cur) |> List.concat(pad) |> List.append('\n')
        when direction is
            Up -> diamond_recurse(cur + 1, limit, Up, List.concat(acc, line))
            Down -> diamond_recurse(cur - 1, limit, Down, List.concat(acc, line))
