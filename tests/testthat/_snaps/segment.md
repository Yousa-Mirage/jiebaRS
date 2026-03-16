# segment warns and ignores deprecated mod

    `mod` is deprecated in `jiebaRS` and no longer has any effect. Use a worker with the desired type instead.

# segment handles empty input for each format

    Code
      segment(character(0), engine1)
    Condition
      Error in `segment()`:
      ! `code` must be a non-empty character vector without missing values.

