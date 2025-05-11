module [
    contains,
    difference,
    from_list,
    insert,
    intersection,
    is_disjoint_with,
    is_empty,
    is_eq,
    is_subset_of,
    to_list,
    union,
]

Element : U64

CustomSet := {
    elements : List Element,
}
    implements [Eq]

contains : CustomSet, Element -> Bool
contains = |set, element|
    when set is
        @CustomSet({ elements }) ->
            List.contains(elements, element)

difference : CustomSet, CustomSet -> CustomSet
difference = |set1, set2|
    when (set1, set2) is
        (@CustomSet({ elements: elements1 }), @CustomSet({ elements: elements2 })) ->
            @CustomSet({ elements: List.drop_if(elements1, |element| List.contains(elements2, element)) })

from_list : List Element -> CustomSet
from_list = |list|
    elements = list |> List.walk [] |acc, elem| if List.contains(acc, elem) then acc else List.append(acc, elem)
    @CustomSet({ elements })

insert : CustomSet, Element -> CustomSet
insert = |set, element|
    when set is
        @CustomSet({ elements }) if List.contains(elements, element) -> set
        @CustomSet({ elements }) -> @CustomSet({ elements: List.append(elements, element) })

intersection : CustomSet, CustomSet -> CustomSet
intersection = |set1, set2|
    when (set1, set2) is
        (@CustomSet({ elements: elements1 }), @CustomSet({ elements: elements2 })) ->
            @CustomSet({ elements: List.keep_if(elements1, |element| List.contains(elements2, element)) })

is_disjoint_with : CustomSet, CustomSet -> Bool
is_disjoint_with = |set1, set2|
    set1
    |> to_list
    |> List.walk_until(
        Bool.true,
        |_, elem|
            if set2 |> to_list |> List.contains elem then
                Break Bool.false
            else
                Continue Bool.true,
    )

is_empty : CustomSet -> Bool
is_empty = |set|
    when set is
        @CustomSet({ elements }) ->
            List.is_empty(elements)

is_eq : CustomSet, CustomSet -> Bool
is_eq = |set1, set2|
    set1
    |> to_list
    |> List.sort_asc
    |> Bool.is_eq(set2 |> to_list |> List.sort_asc)

is_subset_of : CustomSet, CustomSet -> Bool
is_subset_of = |set1, set2|
    set1
    |> to_list
    |> List.walk_until(
        Bool.true,
        |_, elem|
            if set2 |> to_list |> List.contains elem then
                Continue Bool.true
            else
                Break Bool.false,
    )

to_list : CustomSet -> List Element
to_list = |set|
    when set is
        @CustomSet({ elements }) -> elements

union : CustomSet, CustomSet -> CustomSet
union = |set1, set2|
    elements =
        set2
        |> to_list
        |> List.walk(
            set1 |> to_list,
            |result, elem|
                if List.contains(result, elem) then
                    result
                else
                    List.append(result, elem),
        )
    @CustomSet({ elements })
