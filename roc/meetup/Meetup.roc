module [meetup]

import isodate.Date

Week : [First, Second, Third, Fourth, Last, Teenth]
DayOfWeek : [Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]

meetup : { year : I64, month : U8, week : Week, day_of_week : DayOfWeek } -> Result Str _
meetup = |{ year, month, week, day_of_week }|
    day_diff_1 = day_offset_from(day_of_week, year, month, 1)
    day_diff_13 = day_offset_from(day_of_week, year, month, 13)

    when week is
        First -> Date.from_ymd(year, month, 1 + day_diff_1) |> Date.to_iso_str |> Ok
        Second -> Date.from_ymd(year, month, 8 + day_diff_1) |> Date.to_iso_str |> Ok
        Third -> Date.from_ymd(year, month, 15 + day_diff_1) |> Date.to_iso_str |> Ok
        Fourth -> Date.from_ymd(year, month, 22 + day_diff_1) |> Date.to_iso_str |> Ok
        Last ->
            if
                Date.days_in_month(year, month) < (29 + day_diff_1)
            then
                Date.from_ymd(year, month, 22 + day_diff_1) |> Date.to_iso_str |> Ok
            else
                Date.from_ymd(year, month, 29 + day_diff_1) |> Date.to_iso_str |> Ok

        Teenth -> Date.from_ymd(year, month, 13 + day_diff_13) |> Date.to_iso_str |> Ok

day_offset_from : DayOfWeek, I64, U8, U8 -> U8
day_offset_from = |day_of_week, year, month, day_of_month|
    day_of_week
    |> day_of_week_index
    |> Num.add(7)
    |> Num.sub(Date.weekday(year, month, day_of_month))
    |> Num.rem(7)

day_of_week_index : DayOfWeek -> U8
day_of_week_index = |day|
    when day is
        Sunday -> 0
        Monday -> 1
        Tuesday -> 2
        Wednesday -> 3
        Thursday -> 4
        Friday -> 5
        Saturday -> 6
