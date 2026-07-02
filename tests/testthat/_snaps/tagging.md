# tagging requires optional arguments to be named

    Code
      tagging(input, tagger, "legacy")
    Condition
      Error in `tagging()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "legacy"
      i Did you forget to name an argument?

---

    Code
      tagging_batch(input, tagger, "legacy")
    Condition
      Error in `tagging_batch()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "legacy"
      i Did you forget to name an argument?

# tagging rejects an invalid batch value

    Code
      tagging(input, tagger, batch = "data.frame")
    Condition
      Error in `tagging()`:
      ! `batch` must be one of "list" or "flatten", not "data.frame".

# tagging snapshots invalid inputs

    Code
      tagging("测试", segmenter)
    Condition
      Error in `tagging()`:
      ! `jiebar` must be a `jieba_tagger` object created with `worker(type = "tag")`.

---

    Code
      tagging(NA_character_, tagger)
    Condition
      Error in `tagging()`:
      ! `code` must be a non-empty character vector without missing values.

---

    Code
      tagging("测试", tagger, format = "bad")
    Condition
      Error in `tagging()`:
      ! `format` must be one of "vector", "data.frame", or "legacy", not "bad".

---

    Code
      tagging_batch("测试", tagger, batch = "bad")
    Condition
      Error in `tagging_batch()`:
      ! `batch` must be one of "list" or "flatten", not "bad".

