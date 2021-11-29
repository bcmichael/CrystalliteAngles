This package generates sets of α and β angles with weights for use in averaging over molecular orientations in Nuclear
Magnetic Resonance simulations. Generated sets of angles are cached so that they do not have to be regenerated if the
same parameters are used again.

```julia
get_crystallites(100) # generate 100 angles defaulting to Float64 and repulsion algorithm
get_crystallites(100, Float32) # generate 100 Float32 angles defaulting to repulsion algorithm
get_crystallites(102; :alderman) # generate 102 Float64 angles using the alderman algorithm
```

Only certain numbers of angles are possible for the alderman and sophe algorithms. If an invalid number of angles is
requested the error message will contain the nearest possible numbers.

You can also directly read a file containing crystal angles using the `read_crystallites` function.
