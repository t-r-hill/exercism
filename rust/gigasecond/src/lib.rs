use time::PrimitiveDateTime as DateTime;
use std::ops::Add;

// Returns a DateTime one billion seconds after start.
pub fn after(start: DateTime) -> DateTime {
    start.add(time::Duration::seconds(1000000000))
}