use std::{fmt::Display, ops::Rem};

/// A Matcher is a single rule of fizzbuzz: given a function on T, should
/// a word be substituted in? If yes, which word?
pub struct Matcher<'a, T> {
    matcher: Box<dyn Fn(T) -> bool>,
    subs: &'a str,
}

impl<'a, T> Matcher<'a, T> {
    pub fn new<F>(matcher: F, subs: &'a str) -> Matcher<'a, T>
    where
        F: Fn(T) -> bool + 'static,
    {
        Matcher {
            matcher: Box::new(matcher),
            subs,
        }
    }

    pub fn sub_if_matches(&self, item: T) -> Option<&str> {
        if (self.matcher)(item) {
            Some(self.subs)
        } else {
            None
        }
    }
}

/// A Fizzy is a set of matchers, which may be applied to an iterator.
///
/// Strictly speaking, it's usually more idiomatic to use `iter.map()` than to
/// consume an iterator with an `apply` method. Given a Fizzy instance, it's
/// pretty straightforward to construct a closure which applies it to all
/// elements of the iterator. However, we're using the `apply` pattern
/// here because it's a simpler interface for students to implement.
///
/// Also, it's a good excuse to try out using impl trait.
pub struct Fizzy<'a, T> {
    matchers: Vec<Matcher<'a, T>>,
}

impl<'a, T: Copy + Display> Fizzy<'a, T> {
    pub fn new() -> Self {
        Fizzy {
            matchers: Vec::new(),
        }
    }

    // feel free to change the signature to `mut self` if you like
    #[must_use]
    pub fn add_matcher(self, _matcher: Matcher<'a, T>) -> Self {
        let mut matchers = self.matchers;
        matchers.push(_matcher);
        Self { matchers }
    }

    /// map this fizzy onto every element of an iterator, returning a new iterator
    pub fn apply<I: Iterator<Item = T>>(self, _iter: I) -> impl Iterator<Item = String> {
        // todo!() doesn't actually work, here; () is not an Iterator
        // that said, this is probably not the actual implementation you desire
        _iter.map(move |item| {
            let subs = self
                .matchers
                .iter()
                .filter_map(|matcher| matcher.sub_if_matches(item))
                .collect::<Vec<_>>()
                .join("");

            if subs.is_empty() {
                format!("{}", item)
            } else {
                subs
            }
        })
    }
}

/// convenience function: return a Fizzy which applies the standard fizz-buzz rules
pub fn fizz_buzz<T>() -> Fizzy<'static, T>
where
    T: From<u8> + PartialEq + Rem<Output = T> + Copy + Display,
{
    Fizzy::new()
        .add_matcher(Matcher::new(
            |item: T| item % T::from(3u8) == T::from(0u8),
            "fizz",
        ))
        .add_matcher(Matcher::new(
            |item: T| item % T::from(5u8) == T::from(0u8),
            "buzz",
        ))
}
