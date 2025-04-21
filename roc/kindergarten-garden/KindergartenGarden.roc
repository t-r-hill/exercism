module [plants]

Student : [Alice, Bob, Charlie, David, Eve, Fred, Ginny, Harriet, Ileana, Joseph, Kincaid, Larry]
Plant : [Grass, Clover, Radishes, Violets]

students = [Alice, Bob, Charlie, David, Eve, Fred, Ginny, Harriet, Ileana, Joseph, Kincaid, Larry]

plants : Str, Student -> Result (List Plant) _
plants = |diagram, student|
    index =
        List.find_first_index(students, |elem| elem == student)
        |> Result.map_ok(|ix| ix * 2)?
    Str.split_on(diagram, "\n")
    |> List.join_map(
        |row|
            dbg row
            Str.to_utf8(row)
            |> List.sublist({ start: index, len: 2 }),
    )
    |> List.map_try(determine_plant)

determine_plant : U8 -> Result Plant _
determine_plant = |char|
    dbg char
    when char is
        'G' -> Ok(Grass)
        'C' -> Ok(Clover)
        'R' -> Ok(Radishes)
        'V' -> Ok(Violets)
        _ -> Err(NoPlant)
