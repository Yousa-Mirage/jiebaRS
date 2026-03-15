# keywords snapshots invalid format input

    Code
      keywords(keyword_text, keys_worker, format = "bad-format")
    Condition
      Error in `keywords()`:
      ! `format` must be one of "numeric", "data.frame", or "legacy", not "bad-format".

---

    Code
      keywords(5, keys_worker)
    Condition
      Error in `keywords()`:
      ! `code` must be a single non-NA character string.

---

    Code
      keywords(keyword_text, worker(type = "mix"))
    Condition
      Error in `keywords()`:
      ! `jiebar` must be a `jieba_keywords` object created with `worker(type = "keywords")`.

