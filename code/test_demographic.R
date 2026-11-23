# Tests for the functions in Demographic.R
# Run from the repository root: source("code/test_demographic.R")

source("code/Demographic.R")

## ---- sum_vect: deterministic, so test exact values ----
stopifnot(identical(sum_vect(c(1, 3), c(1, 0, 5, 2)), c(2, 3, 5, 2)))  # x shorter
stopifnot(identical(sum_vect(c(1, 0, 5, 2), c(1, 3)), c(2, 3, 5, 2)))  # y shorter
stopifnot(identical(sum_vect(c(1, 2, 3), c(4, 5, 6)), c(5, 7, 9)))     # same length

## ---- multinomial: stochastic, so test properties ----
set.seed(1)
out <- multinomial(10, c(0.1, 0.5, 0, 0))

# the output has length 4
stopifnot(length(out) == 4)

# no value is negative
stopifnot(all(out >= 0))

# the total is at most 10 (some individuals may die)
stopifnot(sum(out) <= 10)

# positions with probability 0 (the 3rd and 4th) are exactly 0
stopifnot(out[3] == 0 && out[4] == 0)

# reproducibility — same seed gives identical output
set.seed(1)
a <- multinomial(10, c(0.1, 0.5, 0, 0))
set.seed(1)
b <- multinomial(10, c(0.1, 0.5, 0, 0))
stopifnot(identical(a, b))


print("All tests passed")