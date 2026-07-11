# worker snapshots invalid dict and user inputs

    Code
      worker(dict = 5)
    Condition
      Error in `worker()`:
      ! `dict` must be `NULL` or a path to a main dictionary file.

---

    Code
      worker(dict = "/nonexistent/dict.txt")
    Condition
      Error in `worker()`:
      ! `dict` must point to an existing main dictionary file.

---

    Code
      worker(user = 5)
    Condition
      Error in `worker()`:
      ! `user` must be `NULL` or a non-empty character vector of user dictionary file paths.

---

    Code
      worker(user = "/nonexistent/user.txt")
    Condition
      Error in `worker()`:
      ! Every path in `user` must point to an existing user dictionary file.

# worker snapshots invalid type input

    Code
      worker(type = "nope")
    Condition
      Error in `worker()`:
      ! `type` must be one of "mix", "mp", "hmm", "full", "query", "tag", "keywords", or "textrank", not "nope".

# worker validates custom HMM model paths

    Code
      worker(hmm = "path/to/hmm_model.utf8")
    Condition
      Error in `worker()`:
      ! `hmm` must point to an existing custom HMM model file.

# worker warns once for approximate mp and hmm mappings

    `worker(type = 'mp')` is currently mapped to `jieba-rs` `cut(..., false)` because `jieba-rs` does not expose a dedicated `mp` segmenter. Results may differ from `jiebaR`.
    This warning is displayed once per session.

---

    `worker(type = 'hmm')` is currently mapped to `jieba-rs` `cut(..., true)` because `jieba-rs` does not expose a dedicated `hmm` segmenter. Results may differ from `jiebaR`.
    This warning is displayed once per session.

# worker warns when bylines is specified for compatibility

    `bylines` is deprecated in `jiebaRS` and no longer has any effect. Control batch aggregation explicitly in specific functions.

