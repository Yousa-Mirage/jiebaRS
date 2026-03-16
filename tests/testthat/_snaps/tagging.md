# tagging rejects incompatible multi-string combinations

    Code
      tagging(input, tagger, format = "vector", batch = "data.frame")
    Condition
      Error in `tagging()`:
      ! `batch = 'data.frame'` requires `format = 'data.frame'`.

---

    Code
      tagging(input, tagger, format = "legacy", batch = "data.frame")
    Condition
      Error in `tagging()`:
      ! `batch = 'data.frame'` requires `format = 'data.frame'`.

---

    Code
      tagging(input, tagger, format = "data.frame", batch = "flatten")
    Condition
      Error in `tagging()`:
      ! `batch = 'flatten'` is not supported with `format = 'data.frame'`.

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
      ! `batch` must be one of "list", "data.frame", or "flatten", not "bad".

