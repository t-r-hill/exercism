module [primes]

primes : U64 -> List U64
primes = |limit|
    if limit < 2 then
        []
    else
        List.range({ start: At 2, end: At limit })
        |> sieve(0)

sieve : List U64, U64 -> List U64
sieve = |numbers, index_to_filter|
    when List.get(numbers, index_to_filter) is
        Ok prime -> List.drop_if(numbers, |number| number % prime == 0 and number > prime) |> sieve(index_to_filter + 1)
        Err _ -> numbers
