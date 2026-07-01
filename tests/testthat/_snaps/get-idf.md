# get_idf snapshots invalid inputs

    Code
      get_idf("not a list")
    Condition
      Error in `get_idf()`:
      ! `x` must be a list of character vectors.

---

    Code
      get_idf(list())
    Condition
      Error in `get_idf()`:
      ! `x` must contain at least one document.

---

    Code
      get_idf(list(c("a"), 5))
    Condition
      Error in `get_idf()`:
      ! Every element of `x` must be a character vector.

---

    Code
      get_idf(idf_docs, path = 5)
    Condition
      Error in `get_idf()`:
      ! `path` must be `NULL` or a single file path string.

