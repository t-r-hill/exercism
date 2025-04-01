pub struct SimpleLinkedList<T> {
    head: Box<Node<T>>,
    len: usize,
}

#[derive(Debug, PartialEq, Eq, Hash)]
enum Node<T> {
    Empty,
    Element(T, Box<Node<T>>),
}

impl<T> SimpleLinkedList<T> {
    pub fn new() -> Self {
        Self {
            head: Box::new(Node::Empty),
            len: 0,
        }
    }

    pub fn is_empty(&self) -> bool {
        matches!(*self.head, Node::Empty)
    }

    pub fn len(&self) -> usize {
        self.len
    }

    pub fn push(&mut self, _element: T) {
        let old_head = std::mem::replace(&mut self.head, Box::new(Node::Empty));
        self.head = Box::new(Node::Element(_element, old_head));
        self.len += 1;
    }

    pub fn pop(&mut self) -> Option<T> {
        let value = std::mem::replace(&mut self.head, Box::new(Node::Empty));
        match *value {
            Node::Empty => None,
            Node::Element(element, next) => {
                self.head = next;
                self.len -= 1;
                Some(element)
            }
        }
    }

    pub fn peek(&self) -> Option<&T> {
        match self.head.as_ref() {
            Node::Empty => None,
            Node::Element(element, _) => Some(element),
        }
    }

    #[must_use]
    pub fn rev(self) -> SimpleLinkedList<T> {
        let mut reversed = SimpleLinkedList::new();
        let mut current = self.head;
        while let Node::Element(element, next) = *current {
            reversed.push(element);
            current = next;
        }
        reversed
    }
}

impl<T> FromIterator<T> for SimpleLinkedList<T> {
    fn from_iter<I: IntoIterator<Item = T>>(_iter: I) -> Self {
        let mut list = Self::new();
        for item in _iter {
            list.push(item);
        }
        list
    }
}

impl<T> From<SimpleLinkedList<T>> for Vec<T> {
    fn from(mut _linked_list: SimpleLinkedList<T>) -> Vec<T> {
        let mut vec = Vec::with_capacity(_linked_list.len());
        while let Some(element) = _linked_list.pop() {
            vec.push(element);
        }
        vec.reverse();
        vec
    }
}
