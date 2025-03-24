#[derive(Debug)]
pub struct CustomSet<T> {
    list: Vec<T>
}

impl<T: PartialEq + Clone> CustomSet<T> {
    pub fn new(_input: &[T]) -> Self {
        let mut list = vec![];
        for item in _input.iter() {
            if !list.contains(item) {
                list.push(item.clone());
            }
        }
        CustomSet { list }
    }

    pub fn contains(&self, _element: &T) -> bool {
        self.list.contains(_element)
    }

    pub fn add(&mut self, _element: T) {
        if !self.list.contains(&_element) {
            self.list.push(_element)
        }
    }

    pub fn is_subset(&self, _other: &Self) -> bool {
        self.list.iter().all(|item| _other.contains(item))
    }

    pub fn is_empty(&self) -> bool {
        self.list.is_empty()
    }

    pub fn is_disjoint(&self, _other: &Self) -> bool {
        self.list.iter().all(|item| !_other.contains(item))
    }

    #[must_use]
    pub fn intersection(&self, _other: &Self) -> Self {
        self.list.iter().filter(|&item| _other.contains(item)).collect()
    }

    #[must_use]
    pub fn difference(&self, _other: &Self) -> Self {
        self.list.iter().filter(|&item| !_other.contains(item)).collect()
    }

    #[must_use]
    pub fn union(&self, _other: &Self) -> Self {
        self.list.iter().filter(|&item| !_other.contains(item)).chain(&_other.list).collect()
    }
}

impl<'a, T: Clone> FromIterator<&'a T> for CustomSet<T> {
    fn from_iter<I: IntoIterator<Item = &'a T>>(iter: I) -> Self {
        CustomSet { list: iter.into_iter().cloned().collect() }
    }
}

impl<T: PartialEq + Clone> PartialEq for CustomSet<T> {
    fn eq(&self, other: &Self) -> bool {
        if self.list.len() != other.list.len() {
            return false;
        }
        self.difference(other).is_empty()
    }
}
