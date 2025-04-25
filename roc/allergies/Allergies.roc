module [allergic_to, set]

Allergen : [Eggs, Peanuts, Shellfish, Strawberries, Tomatoes, Chocolate, Pollen, Cats]

allergic_to : Allergen, U64 -> Bool
allergic_to = |allergen, score|
    Num.to_u8(score)
    |> Num.bitwise_and(allergen_value(allergens, allergen))
    |> Num.compare(0)
    == GT

set : U64 -> Set Allergen
set = |score|
    List.keep_if(allergens, |allergen| Num.bitwise_and(allergen_value(allergens, allergen), Num.to_u8(score)) > 0)
    |> Set.from_list

allergens : List Allergen
allergens = [Eggs, Peanuts, Shellfish, Strawberries, Tomatoes, Chocolate, Pollen, Cats]

allergen_value : List Allergen, Allergen -> U8
allergen_value = |allergen_list, allergen|
    Num.shift_left_by(1, Num.to_u8(List.find_first_index(allergen_list, |item| item == allergen) ?? 0))
