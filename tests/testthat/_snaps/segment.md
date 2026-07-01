# segment warns and ignores deprecated mod

    `mod` is deprecated in `jiebaRS` and no longer has any effect. Use a worker with the desired type instead.

# segment requires optional arguments to be named

    Code
      segment(input, engine1, "flatten")
    Condition
      Error in `segment()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "flatten"
      i Did you forget to name an argument?

---

    Code
      segment_batch(input, engine1, "flatten")
    Condition
      Error in `segment_batch()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "flatten"
      i Did you forget to name an argument?

# segment handles empty input for each format

    Code
      segment(character(0), engine1)
    Condition
      Error in `segment()`:
      ! `code` must be a non-empty character vector without missing values.

