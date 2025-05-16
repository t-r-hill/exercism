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
        {
            new_buffer: {
                data: new_data,
                start: Num.rem(start + 1, List.len(data)),
                length: length - 1,
            },
            value,
        }
        |> Ok

write : CircularBuffer, I64 -> Result CircularBuffer [BufferFull]
write = |{ data, start, length }, value|
    if length == List.len(data) then
        Err(BufferFull)
    else
        {
            data: List.set(data, Num.rem(start + length, List.len(data)), value),
            start,
            length: length + 1,
        }
        |> Ok

overwrite : CircularBuffer, I64 -> CircularBuffer
overwrite = |{ data, start, length }, value|
    List.len(data)
    |> |data_len|
        if length < data_len then
            {
                data: List.set(data, Num.rem(start + length, data_len), value),
                start,
                length: length + 1,
            }
        else
            {
                data: List.set(data, Num.rem(start + length, data_len), value),
                start: Num.rem(start + 1, List.len(data)),
                length: length,
            }

clear : CircularBuffer -> CircularBuffer
clear = |{ data }|
    create({ capacity: List.len(data) })
