module [create, move]

Direction : [North, East, South, West]
Robot : { x : I64, y : I64, direction : Direction }
Turn : [Left, Right]

create : { x ?? I64, y ?? I64, direction ?? Direction } -> Robot
create = |{ x ?? 0, y ?? 0, direction ?? North }|
    { x, y, direction }

move : Robot, Str -> Robot
move = |robot, instructions|
    instructions
    |> Str.walk_utf8 robot |robot_state, instruction|
        when instruction is
            'A' ->
                when robot_state.direction is
                    North -> { robot_state & y: robot_state.y + 1 }
                    East -> { robot_state & x: robot_state.x + 1 }
                    South -> { robot_state & y: robot_state.y - 1 }
                    West -> { robot_state & x: robot_state.x - 1 }

            'L' -> { robot_state & direction: turn(robot_state.direction, Left) }
            'R' -> { robot_state & direction: turn(robot_state.direction, Right) }
            _ -> robot_state

turn : Direction, Turn -> Direction
turn = |robotDirection, turnDirection|
    when turnDirection is
        Left ->
            when robotDirection is
                North -> West
                East -> North
                South -> East
                West -> South

        Right ->
            when robotDirection is
                North -> East
                East -> South
                South -> West
                West -> North
