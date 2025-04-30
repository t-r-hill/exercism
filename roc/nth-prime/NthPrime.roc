module [prime]

prime : U64 -> Result U64 _
prime = |number|
    when number is
        0 -> Err(ZeroIsInvalid)
        1 -> Ok(2)
        2 -> Ok(3)
        3 -> Ok(5)
        4 -> Ok(7)
        5 -> Ok(11)
        6 -> Ok(13)
        7 -> Ok(17)
        8 -> Ok(19)
        9 -> Ok(23)
        10 -> Ok(29)
        _ -> calculate_prime(number)

calculate_prime : U64 -> Result U64 _
calculate_prime = |number|
    calculate_prime_recurse(number, 29, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29], 10)

calculate_prime_recurse : U64, U64, List U64, U64 -> Result U64 _
calculate_prime_recurse = |number, current, primes, num_primes|
    if num_primes >= number then
        List.last(primes)
    else
        (new_primes, new_num_primes) =
            if List.any(primes, |prime_num| current % prime_num == 0) then
                (primes, num_primes)
            else
                (List.append(primes, current), num_primes + 1)

        calculate_prime_recurse(number, current + 2, new_primes, new_num_primes)
