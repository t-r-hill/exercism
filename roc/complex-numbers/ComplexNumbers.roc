module [real, imaginary, add, sub, mul, div, conjugate, abs, exp]

Complex : { re : F64, im : F64 }

real : Complex -> F64
real = |z|
    z.re

imaginary : Complex -> F64
imaginary = |z|
    z.im

add : Complex, Complex -> Complex
add = |z1, z2|
    { re: z1.re + z2.re, im: z1.im + z2.im }

sub : Complex, Complex -> Complex
sub = |z1, z2|
    { re: z1.re - z2.re, im: z1.im - z2.im }

mul : Complex, Complex -> Complex
mul = |z1, z2|
    re = z1.re * z2.re - z1.im * z2.im
    im = z1.re * z2.im + z1.im * z2.re
    { re, im }

div : Complex, Complex -> Complex
div = |z1, z2|
    mul(z1, reciprocal(z2))

conjugate : Complex -> Complex
conjugate = |z|
    { re: z.re, im: -z.im }

abs : Complex -> F64
abs = |z|
    abs_sq(z)
    |> Num.sqrt()

exp : Complex -> Complex
exp = |z|
    exp_a = Num.pow(Num.e, z.re)
    { re: exp_a * Num.cos(z.im), im: exp_a * Num.sin(z.im) }

reciprocal : Complex -> Complex
reciprocal = |z|
    re = z.re / abs_sq(z)
    im = (-z.im) / abs_sq(z)
    { re, im }

abs_sq : Complex -> F64
abs_sq = |z|
    z.re * z.re + z.im * z.im
