module [winner]

Slot : { row : U64, column : U64 }
Move : { row : I64, column : I64 }
Player : { stone : U8, winning_condition : { axis : [Row, Column], value : U64 } }

winner : Str -> Result [PlayerO, PlayerX] _
winner = |board_str|
    slots =
        board_str
        |> Str.split_on("\n")
        |> List.map(
            |row|
                row
                |> Str.to_utf8
                |> List.drop_if(|char| char == ' '),
        )

    if is_winner(slots, PlayerO) then
        Ok(PlayerO)
    else if is_winner(slots, PlayerX) then
        Ok(PlayerX)
    else
        Err NotFinished

is_winner : List List U8, [PlayerO, PlayerX] -> Bool
is_winner = |slots, player|
    when player is
        PlayerO ->
            when slots |> List.get(0) is
                Ok(first_row) ->
                    List.range({ start: At 0, end: Before List.len(first_row) })
                    |> List.walk_until(
                        Bool.false,
                        |_, col_ix| is_winning_path(slots, { row: 0, column: col_ix }, [], { stone: 'O', winning_condition: { axis: Row, value: List.len(slots) - 1 } }),
                    )

                _ -> Bool.false

        PlayerX ->
            when slots |> List.get(0) is
                Ok(first_row) ->
                    List.range({ start: At 0, end: Before List.len(slots) })
                    |> List.walk_until(
                        Bool.false,
                        |_, row_ix| is_winning_path(slots, { row: row_ix, column: 0 }, [], { stone: 'X', winning_condition: { axis: Column, value: List.len(first_row) - 1 } }),
                    )

                _ -> Bool.false

is_winning_path : List List U8, Slot, List Slot, Player -> [Continue Bool, Break Bool]
is_winning_path = |slots, current_slot, visited_slots, player|
    current_slot_value =
        slots
        |> List.get(current_slot.row)
        |> Result.try(|row| row |> List.get(current_slot.column))

    if current_slot_value != Ok(player.stone) then
        Continue Bool.false
    else if List.contains(visited_slots, current_slot) then
        Continue Bool.false
    else if is_winning_position(current_slot, player.winning_condition) then
        Break Bool.true
    else
        next_moves =
            [(0, 1), (1, -1), (1, 0), (-1, 1), (0, -1), (-1, 0)]
            |> List.map(|(a, b)| { row: a, column: b })
            |> List.walk_until(
                Bool.false,
                |_, move|
                    when move_slot(current_slot, move) is
                        Ok(next_slot) -> is_winning_path(slots, next_slot, List.append(visited_slots, current_slot), player)
                        Err InvalidMove -> Continue Bool.false,
            )
        if next_moves then
            Break Bool.true
        else
            Continue Bool.false

is_winning_position : Slot, { axis : [Row, Column], value : U64 } -> Bool
is_winning_position = |slot, { axis, value }|
    when axis is
        Row -> slot.row == value
        Column -> slot.column == value

move_slot : Slot, Move -> Result Slot [InvalidMove]
move_slot = |slot, move|
    new_row = slot.row |> Num.to_i64 |> Num.add(move.row)
    new_column = slot.column |> Num.to_i64 |> Num.add(move.column)

    if new_row < 0 or new_column < 0 then
        Err InvalidMove
    else
        Ok { row: new_row |> Num.to_u64, column: new_column |> Num.to_u64 }
