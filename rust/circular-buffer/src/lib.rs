pub struct CircularBuffer<T> {
    // We fake using T here, so the compiler does not complain that
    // "parameter `T` is never used". Delete when no longer needed.
    internal_buffer: Vec<Option<T>>,
    head: usize,
    tail: usize,
    capacity: usize,
}

#[derive(Debug, PartialEq, Eq)]
pub enum Error {
    EmptyBuffer,
    FullBuffer,
}

impl<T> CircularBuffer<T> {
    pub fn new(capacity: usize) -> Self {
        let mut internal_buffer = Vec::with_capacity(capacity);
        (0..capacity).for_each(|_| internal_buffer.push(None));
        CircularBuffer {
            internal_buffer,
            head: 0,
            tail: 0,
            capacity,
        }
    }

    pub fn write(&mut self, _element: T) -> Result<(), Error> {
        match self.internal_buffer.get(self.head) {
            Some(Some(_)) => Err(Error::FullBuffer),
            Some(None) => {
                self.internal_buffer[self.head] = Some(_element);
                self.head = (self.head + 1) % self.capacity;
                Ok(())
            }
            None => Err(Error::FullBuffer),
        }
    }

    pub fn read(&mut self) -> Result<T, Error> {
        match self.internal_buffer.get_mut(self.tail) {
            Some(element) => match element.take() {
                Some(value) => {
                    self.tail = (self.tail + 1) % self.capacity;
                    Ok(value)
                }
                None => Err(Error::EmptyBuffer),
            },
            None => Err(Error::EmptyBuffer),
        }
    }

    pub fn clear(&mut self) {
        self.internal_buffer
            .iter_mut()
            .for_each(|element| *element = None);
        self.head = 0;
        self.tail = 0;
    }

    pub fn overwrite(&mut self, _element: T) {
        match self.internal_buffer.get(self.head) {
            Some(Some(_)) => {
                self.internal_buffer[self.head] = Some(_element);
                self.head = (self.head + 1) % self.capacity;
                self.tail = (self.tail + 1) % self.capacity;
            }
            Some(None) => {
                self.internal_buffer[self.head] = Some(_element);
                self.head = (self.head + 1) % self.capacity;
            }
            None => (),
        }
    }
}
