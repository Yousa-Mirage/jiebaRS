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
      ! `code` must be a non-missing character scalar.

---

    Code
      tagging("测试", tagger, format = "bad")
    Condition
      Error in `tagging()`:
      ! `format` must be one of "vector", "data.frame", or "legacy", not "bad".

