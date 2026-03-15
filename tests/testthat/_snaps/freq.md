# freq requires a character vector

    Code
      freq(1:5)
    Condition
      Error in `freq()`:
      ! `x` must be a character vector.

# freq validates sort

    Code
      freq(c("a", "b"), sort = NA)
    Condition
      Error in `freq()`:
      ! `sort` must be `TRUE` or `FALSE`.

