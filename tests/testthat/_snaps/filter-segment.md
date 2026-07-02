# filter_segment snapshots invalid inputs

    Code
      filter_segment(1:3, "a")
    Condition
      Error in `filter_segment()`:
      ! `input` must be a character vector or a list of character vectors.

---

    Code
      filter_segment(list(c("a"), 1:3), "a")
    Condition
      Error in `filter_segment()`:
      ! `input` must be a character vector or a list of character vectors.

---

    Code
      filter_segment(c("a", "b"), 1:2)
    Condition
      Error in `filter_segment()`:
      ! `filter_words` must be a character vector.

---

    Code
      filter_segment(c("a", NA), "a", keep_na = NA)
    Condition
      Error in `filter_segment()`:
      ! `keep_na` must be a single `TRUE` or `FALSE` value.

