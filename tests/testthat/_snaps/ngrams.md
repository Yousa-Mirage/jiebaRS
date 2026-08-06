# count_ngrams requires optional arguments to be named

    Code
      count_ngrams(c("我", "爱", "R", "语言"), 2)
    Condition
      Error in `count_ngrams()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = 2
      i Did you forget to name an argument?

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

