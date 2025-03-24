use std::fmt::{Display, Formatter};

#[derive(Debug)]
pub struct Clock {
    hours: i32,
    minutes: i32
}

impl Clock {
    pub fn new(hours: i32, minutes: i32) -> Self {
        let mut minutes_trim = minutes % 60;
        let mut hours_trim = (hours + (minutes / 60)) % 24;
        if minutes_trim < 0 {
            minutes_trim = 60 + minutes_trim;
            hours_trim -= 1;
        }
        if hours_trim < 0 {
            hours_trim = 24 + hours_trim;
        }
        Clock{ hours: hours_trim, minutes: minutes_trim }
    }

    pub fn add_minutes(&self, minutes: i32) -> Self {
        Clock::new(self.hours, self.minutes + minutes)
    }
}

impl Display for Clock {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:02}:{:02}", self.hours, self.minutes)
    }
}

impl PartialEq for Clock {
    fn eq(&self, other: &Self) -> bool {
        self.hours == other.hours && self.minutes == other.minutes
    }
}
