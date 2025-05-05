module [from_list, to_list, push, pop, reverse, len]

SimpleLinkedList : [Cons({ value: U64, next: SimpleLinkedList }), Nil]


from_list : List U64 -> SimpleLinkedList
from_list = |list|
    if List.is_empty(list) then
        Nil
    else
        list
        |> List.walk(
            Nil,
            |acc, value|
                Cons({ value, next: acc }),
        )

to_list : SimpleLinkedList -> List U64
to_list = |linked_list|
    when linked_list is
        Nil -> []
        Cons({ value, next }) -> to_list(next) |> List.append(value)

push : SimpleLinkedList, U64 -> SimpleLinkedList
push = |linked_list, item|
    Cons({ value: item, next: linked_list })

pop : SimpleLinkedList -> Result { value : U64, linked_list : SimpleLinkedList } _
pop = |linked_list|
    when linked_list is
        Nil -> Err("Empty list")
        Cons({ value, next }) -> Ok({ value, linked_list: next })

reverse : SimpleLinkedList -> SimpleLinkedList
reverse = |linked_list|
    reverse_helper(linked_list, Nil)

reverse_helper : SimpleLinkedList, SimpleLinkedList -> SimpleLinkedList
reverse_helper = |linked_list, reversed|
    when linked_list is
        Nil -> reversed
        Cons({ value, next }) -> reverse_helper(next, Cons({ value, next: reversed }))

len : SimpleLinkedList -> U64
len = |linked_list|
    when linked_list is
        Nil -> 0
        Cons({ next }) -> len(next) + 1
