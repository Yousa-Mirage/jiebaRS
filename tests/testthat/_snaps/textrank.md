# textrank is distinct from TF-IDF keywords

    Code
      textrank(textrank_text, keys_worker)
    Condition
      Error in `textrank()`:
      ! `jiebar` must be a `jieba_textrank` object created with `worker(type = "textrank")`.

---

    Code
      keywords(textrank_text, ranker)
    Condition
      Error in `keywords()`:
      ! `jiebar` must be a `jieba_keywords` object created with `worker(type = "keywords")`.

# textrank requires optional arguments to be named

    Code
      textrank(textrank_text, ranker, "legacy")
    Condition
      Error in `textrank()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "legacy"
      i Did you forget to name an argument?

# textrank snapshots invalid inputs

    Code
      textrank(textrank_text, ranker, format = "bad-format")
    Condition
      Error in `textrank()`:
      ! `format` must be one of "numeric", "data.frame", or "legacy", not "bad-format".

---

    Code
      textrank(5, ranker)
    Condition
      Error in `textrank()`:
      ! `code` must be a single non-NA character string.

