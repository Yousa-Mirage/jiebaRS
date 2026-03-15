# count_ngrams snapshots invalid inputs

    Code
      count_ngrams(1:3)
    Condition
      Error in `.validate_ngrams_input()`:
      ! `x` must be a character vector or a list of character vectors.

---

    Code
      count_ngrams(c("a", "b"), n = c(2, 0))
    Condition
      Error in `.validate_ngrams_n()`:
      ! `n` must contain positive integers only.

---

    Code
      count_ngrams(c("a", "b"), sort = NA)
    Condition
      Error in `count_ngrams()`:
      ! `sort` must be a single `TRUE` or `FALSE` value.

# get_tuple is a deprecated compatibility wrapper

    `get_tuple()` is deprecated; use `count_ngrams()` instead. The legacy jiebaR API mixes 2:n grams into `size`, does not reliably support list inputs, and cannot represent tuple boundaries because it concatenates tokens without a separator.

---

    `get_tuple()` is deprecated; use `count_ngrams()` instead. The legacy jiebaR API mixes 2:n grams into `size`, does not reliably support list inputs, and cannot represent tuple boundaries because it concatenates tokens without a separator.

