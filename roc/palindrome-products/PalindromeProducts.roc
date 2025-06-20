module [smallest, largest]

smallest : { min : U64, max : U64 } -> Result { value : U64, factors : Set (U64, U64) } _
smallest = |{ min, max }|
    if min > max then
        Err(InvalidInput)
    else
        value_range = List.range({ start: At min, end: At max })
        List.walk_with_index(
            value_range,
            { value: 0, factors: Set.empty({}) },
            |result, value, ix|
                List.walk_until(
                    List.drop_first(value_range, ix),
                    result,
                    |result_inner, inner_value|
                        product = inner_value * value
                        if result_inner.value == 0 and is_palindrome(product) then
                            Break { value: inner_value * value, factors: Set.single(factors_tuple(inner_value, value)) }
                        else if result_inner.value == 0 then
                            Continue result_inner
                        else
                            when Num.compare(product, result_inner.value) is
                                EQ if is_palindrome(product) -> Break { result_inner & factors: Set.insert(result_inner.factors, factors_tuple(inner_value, value)) }
                                EQ -> Break result_inner
                                LT if is_palindrome(product) -> Break { value: inner_value * value, factors: Set.single(factors_tuple(inner_value, value)) }
                                LT -> Continue result_inner
                                GT -> Break result_inner,
                ),
        )
        |> Ok

largest : { min : U64, max : U64 } -> Result { value : U64, factors : Set (U64, U64) } _
largest = |{ min, max }|
    if min > max then
        Err(InvalidInput)
    else
        value_range = List.range({ start: At max, end: At min })
        List.walk_with_index(
            value_range,
            { value: 0, factors: Set.empty({}) },
            |result, value, ix|
                List.walk_until(
                    List.drop_first(value_range, ix),
                    result,
                    |result_inner, inner_value|
                        product = inner_value * value
                        if result_inner.value == 0 and is_palindrome(product) then
                            Break { value: inner_value * value, factors: Set.single(factors_tuple(inner_value, value)) }
                        else if result_inner.value == 0 then
                            Continue result_inner
                        else
                            when Num.compare(product, result_inner.value) is
                                EQ if is_palindrome(product) -> Break { result_inner & factors: Set.insert(result_inner.factors, factors_tuple(inner_value, value)) }
                                EQ -> Break result_inner
                                GT if is_palindrome(product) -> Break { value: inner_value * value, factors: Set.single(factors_tuple(inner_value, value)) }
                                LT -> Break result_inner
                                GT -> Continue result_inner,
                ),
        )
        |> Ok

is_palindrome : U64 -> Bool
is_palindrome = |num|
    if num < 10 then
        Bool.true
    else
        # Helper function to reverse a number
        reverse_num = |n, acc|
            if n == 0 then
                acc
            else
                reverse_num (n // 10) (acc * 10 + n % 10)

        reversed = reverse_num num 0
        num == reversed

factors_tuple : U64, U64 -> (U64, U64)
factors_tuple = |factor_1, factor_2|
    if factor_2 < factor_1 then
        (factor_2, factor_1)
    else
        (factor_1, factor_2)
