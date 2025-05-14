module [prime_factors]

prime_factors : U64 -> List U64
prime_factors = |value|
    prime_factors_helper([], value, 2)

prime_factors_helper : List U64, U64, U64 -> List U64
prime_factors_helper = |primes, numerator, divisor|
    if numerator == 1 then
        primes
    else if Num.rem(numerator, divisor) == 0 then
        prime_factors_helper(List.append(primes, divisor), numerator // divisor, divisor)
    else if divisor == 2 then
        prime_factors_helper(primes, numerator, 3)
    else
        prime_factors_helper(primes, numerator, divisor + 2)
