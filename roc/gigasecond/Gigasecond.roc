module [add]

import isodate.DateTime
import isodate.Duration

add : Str -> Str
add = |moment|
    DateTime.from_iso_str(moment)
    |> Result.map2(
        Duration.from_seconds(1_000_000_000),
        |moment_dt, gigasecond_drt|
            DateTime.add_date_time_and_duration(moment_dt, gigasecond_drt)
            |> DateTime.to_iso_str,
    )
    |> Result.with_default(moment)
