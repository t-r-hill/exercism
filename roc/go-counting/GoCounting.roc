module [territory, territories]

Intersection : { x : U64, y : U64 }

Move : { x : I64, y : I64 }

Stone : [White, Black, None]

Territory : {
    owner : Stone,
    territory : Set Intersection,
}

TerritoryWithOwners : {
    owners : Set Stone,
    territory : Set Intersection,
}

Territories : {
    black : Set Intersection,
    white : Set Intersection,
    none : Set Intersection,
}

territory : Str, Intersection -> Result Territory _
territory = |board_str, { x, y }|
    board_grid = board_as_grid(board_str)

    initial_stone =
        get_stone_at_intersection(board_grid, { x, y })
        |> Result.map_err(|_| Err InvalidIntersection)?

    when initial_stone is
        Black | White -> { owner: None, territory: Set.empty({}) } |> Ok
        None ->
            with_owners = determine_territory(board_grid, { x, y }, Set.empty({}), { owners: Set.empty({}), territory: Set.empty({}) }).0
            when Set.to_list(with_owners.owners) is
                [Black] -> { owner: Black, territory: with_owners.territory } |> Ok
                [White] -> { owner: White, territory: with_owners.territory } |> Ok
                _ -> { owner: None, territory: with_owners.territory } |> Ok

territories : Str -> Result Territories _
territories = |board_str|
    board_grid = board_as_grid(board_str)
    first_row = List.get(board_grid, 0) |> Result.map_err(|_| EmptyBoard)?

    List.range({ start: At 0, end: Before List.len(board_grid) })
    |> List.join_map(
        |y|
            List.range({ start: At 0, end: Before List.len(first_row) })
            |> List.map(|x| { x, y }),
    )
    |> List.walk(
        ({ black: Set.empty({}), white: Set.empty({}), none: Set.empty({}) }, Set.empty({})),
        |(territories_state, visited_state), current_intersection|
            if Set.contains(visited_state, current_intersection) then
                (territories_state, visited_state)
            else
                current_stone = get_stone_at_intersection(board_grid, current_intersection)
                when current_stone is
                    Ok(None) ->
                        ({ owners, territory: calc_territory }, visited) = determine_territory(board_grid, current_intersection, visited_state, { owners: Set.empty({}), territory: Set.empty({}) })
                        new_territories =
                            when Set.to_list(owners) is
                                [Black] -> { territories_state & black: Set.union(territories_state.black, calc_territory) }
                                [White] -> { territories_state & white: Set.union(territories_state.white, calc_territory) }
                                _ -> { territories_state & none: Set.union(territories_state.none, calc_territory) }
                        (new_territories, visited)

                    _ -> (territories_state, visited_state),
    )
    |> .0
    |> Ok

determine_territory : List List Stone, Intersection, Set Intersection, TerritoryWithOwners -> (TerritoryWithOwners, Set Intersection)
determine_territory = |board_grid, { x, y }, visited, current_territory|
    if Set.contains(visited, { x, y }) then
        (current_territory, visited)
    else
        new_visited = Set.insert(visited, { x, y })
        current_stone = get_stone_at_intersection(board_grid, { x, y })
        when current_stone is
            Ok(None) ->
                new_territory = { current_territory & territory: Set.insert(current_territory.territory, { x, y }) }
                next_moves =
                    [{ x: 0, y: 1 }, { x: 1, y: 0 }, { x: 0, y: -1 }, { x: -1, y: 0 }]
                    |> List.walk(
                        (new_territory, new_visited),
                        |(territory_state, visited_state), move|
                            when move_intersection({ x, y }, move) is
                                Ok(next_intersection) -> determine_territory(board_grid, next_intersection, visited_state, territory_state)
                                Err InvalidMove -> (territory_state, visited_state),
                    )
                next_moves

            Ok(stone_colour) -> ({ current_territory & owners: Set.insert(current_territory.owners, stone_colour) }, visited)
            Err _ -> (current_territory, new_visited)

move_intersection : Intersection, Move -> Result Intersection [InvalidMove]
move_intersection = |intersection, move|
    new_x = intersection.x |> Num.to_i64 |> Num.add(move.x)
    new_y = intersection.y |> Num.to_i64 |> Num.add(move.y)

    if new_x < 0 or new_y < 0 then
        Err InvalidMove
    else
        Ok { x: new_x |> Num.to_u64, y: new_y |> Num.to_u64 }

board_as_grid : Str -> List List Intersection
board_as_grid = |board_str|
    board_str
    |> Str.split_on("\n")
    |> List.map(
        |row|
            row
            |> Str.to_utf8
            |> List.map(|char| if char == 'W' then White else if char == 'B' then Black else None),
    )

get_stone_at_intersection : List List Stone, Intersection -> Result Stone [OutOfBounds]
get_stone_at_intersection = |board_grid, { x, y }|
    board_grid
    |> List.get(y)
    |> Result.try(|row| row |> List.get(x))
