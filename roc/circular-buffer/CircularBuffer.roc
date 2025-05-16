module [create, read, write, overwrite, clear]

CircularBuffer : { data : List I64, start : U64, length : U64 }

create : { capacity : U64 } -> CircularBuffer
create = |{ capacity }|
    { data: List.repeat(0, capacity), start: 0, length: 0 }

read : CircularBuffer -> Result { new_buffer : CircularBuffer, value : I64 } [BufferEmpty]
read = |{ data, start, length }|

    if length == 0 then
        Err(BufferEmpty)
    else
        { list: new_data, value } = List.replace(data, start, 0)
        Ok({ new_buffer: { data: new_data, start: Num.rem(start + 1, List.len(data)), length: length - 1 }, value })

write : CircularBuffer, I64 -> Result CircularBuffer [BufferFull]
write = |{ data, start, length }, value|
    if length == List.len(data) then
        Err(BufferFull)
    else
        Ok({ data: List.set(data, Num.rem(start + length, List.len(data)), value), start, length: length + 1 })

overwrite : CircularBuffer, I64 -> CircularBuffer
overwrite = |{ data, start, length }, value|
    if length < List.len(data) then
        { data: List.set(data, Num.rem(start + length, List.len(data)), value), start, length: length + 1 }
    else
        { data: List.set(data, Num.rem(start + length, List.len(data)), value), start: Num.rem(start + 1, List.len(data)), length: length }

clear : CircularBuffer -> CircularBuffer
clear = |{ data }|
    create({ capacity: List.len(data) })
