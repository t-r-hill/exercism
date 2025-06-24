module [tally]

TableRow : { mp : U8, w : U8, d : U8, l : U8, p : U8 }

tally : Str -> Result Str _
tally = |table|
    table
    |> Str.split_on "\n"
    |> List.walk (Dict.empty {}) |table_dict, line|
        when Str.split_on line ";" is
            [team1, team2, result] -> add_result_to_table table_dict team1 team2 result
            _ -> table_dict
    |> Dict.to_list
    |> List.sort_with |(team1, stats1), (team2, stats2)|
        when Num.compare stats2.p stats1.p is
            GT -> GT
            LT -> LT
            EQ -> compare_alphabetically team1 team2
    |> List.walk ["Team                           | MP |  W |  D |  L |  P"] |table_string, (team, stats)|
        List.append table_string (table_line team stats)
    |> Str.join_with "\n"
    |> Ok

add_result_to_table : Dict Str TableRow, Str, Str, Str -> Dict Str TableRow
add_result_to_table = |table, team1, team2, result|
    when result is
        "win" ->
            table
            |> Dict.update team1 |cur_stats_result|
                when cur_stats_result is
                    Ok cur_stats ->
                        Ok { cur_stats & mp: cur_stats.mp + 1, w: cur_stats.w + 1, p: cur_stats.p + 3 }

                    Err _ ->
                        Ok { mp: 1, w: 1, d: 0, l: 0, p: 3 }
            |> Dict.update team2 |cur_stats_result|
                when cur_stats_result is
                    Ok cur_stats ->
                        Ok { cur_stats & mp: cur_stats.mp + 1, l: cur_stats.l + 1 }

                    Err _ ->
                        Ok { mp: 1, w: 0, d: 0, l: 1, p: 0 }

        "draw" ->
            table
            |> Dict.update team1 |cur_stats_result|
                when cur_stats_result is
                    Ok cur_stats ->
                        Ok { cur_stats & mp: cur_stats.mp + 1, d: cur_stats.d + 1, p: cur_stats.p + 1 }

                    Err _ ->
                        Ok { mp: 1, w: 0, d: 1, l: 0, p: 1 }
            |> Dict.update team2 |cur_stats_result|
                when cur_stats_result is
                    Ok cur_stats ->
                        Ok { cur_stats & mp: cur_stats.mp + 1, d: cur_stats.d + 1, p: cur_stats.p + 1 }

                    Err _ ->
                        Ok { mp: 1, w: 0, d: 1, l: 0, p: 1 }

        "loss" ->
            table
            |> Dict.update team1 |cur_stats_result|
                when cur_stats_result is
                    Ok cur_stats ->
                        Ok { cur_stats & mp: cur_stats.mp + 1, l: cur_stats.l + 1 }

                    Err _ ->
                        Ok { mp: 1, w: 0, d: 0, l: 1, p: 0 }
            |> Dict.update team2 |cur_stats_result|
                when cur_stats_result is
                    Ok cur_stats ->
                        Ok { cur_stats & mp: cur_stats.mp + 1, w: cur_stats.w + 1, p: cur_stats.p + 3 }

                    Err _ ->
                        Ok { mp: 1, w: 1, d: 0, l: 0, p: 3 }

        _ -> table

table_line : Str, TableRow -> Str
table_line = |team, { mp, w, d, l, p }|
    team_padded = Str.concat team (Str.repeat " " (31 - Str.count_utf8_bytes team))
    mp_str = Num.to_str mp |> pad_left 2
    w_str = Num.to_str w |> pad_left 2
    d_str = Num.to_str d |> pad_left 2
    l_str = Num.to_str l |> pad_left 2
    p_str = Num.to_str p |> pad_left 2

    "${team_padded}| ${mp_str} | ${w_str} | ${d_str} | ${l_str} | ${p_str}"

pad_left : Str, U64 -> Str
pad_left = |str, width|
    current_len = Str.count_utf8_bytes str
    if current_len >= width then
        str
    else
        spaces_needed = width - current_len
        Str.concat (Str.repeat " " spaces_needed) str

compare_alphabetically : Str, Str -> [LT, EQ, GT]
compare_alphabetically = |team1, team2|
    team1_chars = Str.to_utf8 team1
    team2_chars = Str.to_utf8 team2
    List.map2 team1_chars team2_chars |a, b| Num.compare a b
    |> List.walk_until EQ |_, elem|
        when elem is
            EQ -> Continue EQ
            LT -> Break LT
            GT -> Break GT
