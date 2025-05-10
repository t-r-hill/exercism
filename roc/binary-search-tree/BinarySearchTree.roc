module [from_list, to_list]

BinaryTree : [Nil, Node { value : U64, left : BinaryTree, right : BinaryTree }]

from_list : List U64 -> BinaryTree
from_list = |data|
    data
    |> List.walk Nil add_to_tree

to_list : BinaryTree -> List U64
to_list = |tree|
    to_list_helper([], tree)

add_to_tree : BinaryTree, U64 -> BinaryTree
add_to_tree = |tree, value|
    when tree is
        Nil -> Node { value, left: Nil, right: Nil }
        Node { value: node_value, left, right } if value <= node_value -> Node { value: node_value, left: add_to_tree(left, value), right }
        Node { value: node_value, left, right } -> Node { value: node_value, left, right: add_to_tree(right, value) }

to_list_helper : List U64, BinaryTree -> List U64
to_list_helper = |acc, tree|
    when tree is
        Nil -> acc
        Node { value, left, right } ->
            to_list_helper(acc, left)
            |> List.append(value)
            |> to_list_helper(right)
