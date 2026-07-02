# keyword worker snapshots invalid IDF input

    Code
      worker(type = "keywords", idf = 5)
    Condition
      Error in `worker()`:
      ! `idf` must be `NULL` or a path to an IDF dictionary file.

---

    Code
      worker(type = "keywords", idf = "/nonexistent/idf.txt")
    Condition
      Error in `worker()`:
      ! `idf` must point to an existing IDF dictionary file.

# keywords requires optional arguments to be named

    Code
      keywords(keyword_text, keys_worker, "legacy")
    Condition
      Error in `keywords()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "legacy"
      i Did you forget to name an argument?

# keywords snapshots invalid format input

    Code
      keywords(keyword_text, keys_worker, format = "bad-format")
    Condition
      Error in `keywords()`:
      ! `format` must be one of "vector", "data.frame", or "legacy", not "bad-format".

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

