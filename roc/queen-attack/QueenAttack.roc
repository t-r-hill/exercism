module [create, rank, file, queen_can_attack]

Square := { row : U8, column : U8 }

rank : Square -> U8
rank = |@Square({ row })|
    row + 1

file : Square -> U8
file = |@Square({ column })|
    column + 'A'

create : Str -> Result Square _
create = |square_str|
    when square_str |> Str.to_utf8 is
        [file_c, rank_c] if file_c >= 'A' and file_c <= 'H' and rank_c >= '1' and rank_c <= '8'
         -> Ok @Square({ row: rank_c - '1', column: file_c - 'A' })
        _ -> Err(InvalidSquare)

queen_can_attack : Square, Square -> Bool
queen_can_attack = |square1, square2|
    same_rank(square1, square2) or same_file(square1, square2) or same_diagonal(square1, square2)

same_rank : Square, Square -> Bool
same_rank = |square1, square2|
    rank(square1) == rank(square2)

same_file : Square, Square -> Bool
same_file = |square1, square2|
    file(square1) == file(square2)

same_diagonal : Square, Square -> Bool
same_diagonal = |square1, square2|
    when (Num.compare(rank(square1), rank(square2)), Num.compare(file(square1), file(square2))) is
        (GT, GT) -> rank(square1) - rank(square2) == file(square1) - file(square2)
        (GT, LT) -> rank(square1) - rank(square2) == file(square2) - file(square1)
        (LT, GT) -> rank(square2) - rank(square1) == file(square1) - file(square2)
        _ -> rank(square2) - rank(square1) == file(square2) - file(square1)
