// this module adds some functionality based on the required implementations
// here like: `LinkedList::pop_back` or `Clone for LinkedList<T>`
// You are free to use anything in it, but it's mainly for the test framework.
mod pre_implemented;

pub struct LinkedList<T> {
    head: Option<*mut Node<T>>,
    tail: Option<*mut Node<T>>,
    len: usize,
}

pub struct Cursor<'a, T> {
    current: Option<*mut Node<T>>,
    list: &'a mut LinkedList<T>,
}

pub struct Iter<'a, T> {
    current: Option<&'a Node<T>>,
}

struct Node<T> {
    value: T,
    next: Option<*mut Node<T>>,
    prev: Option<*mut Node<T>>,
}

impl<T> Drop for LinkedList<T> {
    fn drop(&mut self) {
        while let Some(node) = self.head.take() {
            unsafe {
                let node = Box::from_raw(node);
                self.head = node.next;
            }
        }
    }
}

impl<T> LinkedList<T> {
    pub fn new() -> Self {
        LinkedList {
            head: None,
            tail: None,
            len: 0,
        }
    }

    pub fn is_empty(&self) -> bool {
        self.len == 0
    }

    pub fn len(&self) -> usize {
        self.len
    }

    /// Return a cursor positioned on the front element
    pub fn cursor_front(&mut self) -> Cursor<'_, T> {
        Cursor {
            current: self.head,
            list: self,
        }
    }

    /// Return a cursor positioned on the back element
    pub fn cursor_back(&mut self) -> Cursor<'_, T> {
        Cursor {
            current: self.tail,
            list: self,
        }
    }

    /// Return an iterator that moves from front to back
    pub fn iter(&self) -> Iter<'_, T> {
        unsafe {
            Iter {
                current: self.head.and_then(|node| node.as_ref()),
            }
        }
    }
}

// the cursor is expected to act as if it is at the position of an element
// and it also has to work with and be able to insert into an empty list.
impl<T> Cursor<'_, T> {
    /// Take a mutable reference to the current element
    pub fn peek_mut(&mut self) -> Option<&mut T> {
        unsafe {
            self.current
                .and_then(|node| node.as_mut())
                .map(|node| &mut node.value)
        }
    }

    /// Move one position forward (towards the back) and
    /// return a reference to the new position
    #[allow(clippy::should_implement_trait)]
    pub fn next(&mut self) -> Option<&mut T> {
        unsafe {
            self.current = self
                .current
                .and_then(|node| node.as_mut())
                .and_then(|node| node.next);
            self.current
                .and_then(|node| node.as_mut())
                .map(|node| &mut node.value)
        }
    }

    /// Move one position backward (towards the front) and
    /// return a reference to the new position
    pub fn prev(&mut self) -> Option<&mut T> {
        unsafe {
            self.current = self
                .current
                .and_then(|node| node.as_mut())
                .and_then(|node| node.prev);
            self.current
                .and_then(|node| node.as_mut())
                .map(|node| &mut node.value)
        }
    }

    /// Remove and return the element at the current position and move the cursor
    /// to the neighboring element that's closest to the back. This can be
    /// either the next or previous position.
    pub fn take(&mut self) -> Option<T> {
        unsafe {
            if let Some(current_ptr) = self.current {
                let current = Box::from_raw(current_ptr);
                let prev = current.prev;
                let next = current.next;
                let value = current.value;

                if let Some(next) = next {
                    (*next).prev = prev;
                    self.current = Some(next);
                } else {
                    self.current = prev;
                    self.list.tail = prev;
                }

                if let Some(prev) = prev {
                    (*prev).next = next;
                } else {
                    self.list.head = next;
                }

                self.list.len -= 1;
                Some(value)
            } else {
                None
            }
        }
    }

    pub fn insert_after(&mut self, _element: T) {
        unsafe {
            let new_node = Node {
                value: _element,
                next: self
                    .current
                    .and_then(|node| node.as_mut())
                    .and_then(|node| node.next),
                prev: self.current,
            };
            let new_node_ptr = Box::into_raw(Box::new(new_node));
            if let Some(node) = self.current {
                if let Some(next) = node.as_mut().and_then(|node| node.next) {
                    (*next).prev = Some(new_node_ptr);
                } else {
                    self.list.tail = Some(new_node_ptr);
                }
                (*node).next = Some(new_node_ptr);
            } else {
                self.list.head = Some(new_node_ptr);
                self.list.tail = Some(new_node_ptr);
            }
            self.list.len += 1;
        }
    }

    pub fn insert_before(&mut self, _element: T) {
        unsafe {
            let new_node = Node {
                value: _element,
                prev: self
                    .current
                    .and_then(|node| node.as_mut())
                    .and_then(|node| node.prev),
                next: self.current,
            };
            let new_node_ptr = Box::into_raw(Box::new(new_node));
            if let Some(node) = self.current {
                if let Some(prev) = node.as_mut().and_then(|node| node.prev) {
                    (*prev).next = Some(new_node_ptr);
                } else {
                    self.list.head = Some(new_node_ptr);
                }
                (*node).prev = Some(new_node_ptr);
            } else {
                self.list.head = Some(new_node_ptr);
                self.list.tail = Some(new_node_ptr);
            }
            self.list.len += 1;
        }
    }
}

impl<'a, T> Iterator for Iter<'a, T> {
    type Item = &'a T;

    fn next(&mut self) -> Option<Self::Item> {
        let val = self.current.map(|node| &node.value);
        unsafe {
            self.current = self
                .current
                .and_then(|node| node.next)
                .and_then(|node| node.as_ref());
        }
        val
    }
}
