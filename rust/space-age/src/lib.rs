// The code below is a stub. Just enough to satisfy the compiler.
// In order to pass the tests you can add-to or change any of this code.

#[derive(Debug)]
pub struct Duration {
    earth_years: f64,
}

impl Duration {
    fn new(seconds: u64) -> Self {
        let earth_years = seconds as f64 / 31557600.0;
        Duration { earth_years }
    }
}

impl From<u64> for Duration {
    fn from(s: u64) -> Self {
        Duration::new(s)
    }
}

pub trait Planet {
    fn years_during(d: &Duration) -> f64 {
        d.earth_years
    }
}

pub struct Mercury;
pub struct Venus;
pub struct Earth;
pub struct Mars;
pub struct Jupiter;
pub struct Saturn;
pub struct Uranus;
pub struct Neptune;

impl Planet for Mercury {
    fn years_during(d: &Duration) -> f64 {
        d.earth_years / 0.2408467
    }
}
impl Planet for Venus {
    fn years_during(d: &Duration) -> f64 {
        d.earth_years / 0.61519726
    }
}
impl Planet for Earth {
    fn years_during(d: &Duration) -> f64 {
        d.earth_years
    }
}
impl Planet for Mars {
    fn years_during(d: &Duration) -> f64 {
        d.earth_years / 1.8808158
    }
}
impl Planet for Jupiter {
    fn years_during(d: &Duration) -> f64 {
        d.earth_years / 11.862615
    }
}
impl Planet for Saturn {
    fn years_during(d: &Duration) -> f64 {
        d.earth_years / 29.447498
    }
}
impl Planet for Uranus {
    fn years_during(d: &Duration) -> f64 {
        d.earth_years / 84.016846
    }
}
impl Planet for Neptune {
    fn years_during(d: &Duration) -> f64 {
        d.earth_years / 164.79132
    }
}
