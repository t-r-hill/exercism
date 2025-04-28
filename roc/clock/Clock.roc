module [create, to_str, add, subtract]

Clock : { hour : U8, minute : U8 }

create : { hours ?? I64, minutes ?? I64 }* -> Clock
create = |{ hours ?? 0, minutes ?? 0 }|
    hour =
        minutes
        |> mins_to_hours
        |> Num.add(hours % 24)
        |> pos_rem(24)
    minute = pos_rem(minutes, 60)
    { hour, minute }

to_str : Clock -> Str
to_str = |{ hour, minute }|
    "${pad(hour)}:${pad(minute)}"

add : Clock, { hours ?? I64, minutes ?? I64 }* -> Clock
add = |clock, { hours ?? 0, minutes ?? 0 }|
    hours_p =
        minutes
        |> Num.div_trunc(60)
        |> Num.add(hours % 24)
        |> Num.rem(24)
    minutes_p = minutes % 60
    combine(clock, { hours: hours_p, minutes: minutes_p })

subtract : Clock, { hours ?? I64, minutes ?? I64 }* -> Clock
subtract = |clock, { hours ?? 0, minutes ?? 0 }|
    hours_p =
        minutes
        |> Num.div_trunc(60)
        |> Num.add(hours % 24)
        |> Num.rem(24)
    minutes_p = minutes % 60
    combine(clock, { hours: -hours_p, minutes: -minutes_p })

pad : U8 -> Str
pad = |num|
    if num < 10 then
        "0${Num.to_str(num)}"
    else
        Num.to_str num

pos_rem : I64, I64 -> U8
pos_rem = |num, divisor|
    rem = num |> Num.rem(divisor)
    if rem < 0 then
        Num.to_u8(divisor + rem)
    else
        Num.to_u8(rem)

mins_to_hours : I64 -> I64
mins_to_hours = |mins|
    div_60 = mins // 60
    if Num.rem(mins, 60) < 0 then
        div_60 - 1
    else
        div_60

combine : Clock, { hours : I64, minutes : I64 }* -> Clock
combine = |{ hour: clock_hour, minute: clock_minute }, { hours, minutes }|
    hour_total = (Num.to_i64(clock_hour) + hours)
    minute_total = (Num.to_i64(clock_minute) + minutes)
    create { hours: hour_total, minutes: minute_total }
