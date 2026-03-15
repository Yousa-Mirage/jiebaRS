# new_user_word snapshots invalid inputs

    Code
      new_user_word("not-a-worker", "量子机器狗")
    Condition
      Error in `new_user_word()`:
      ! `worker` must be a `jieba_worker` object.

---

    Code
      new_user_word(engine1, 1:3)
    Condition
      Error in `new_user_word()`:
      ! `words` must be a character vector without NAs.

---

    Code
      new_user_word(engine1, c("量子机器狗", NA_character_))
    Condition
      Error in `new_user_word()`:
      ! `words` must be a character vector without NAs.

---

    Code
      new_user_word(engine1, c("量子机器狗", "超导量子比特"), c("n", "nz", "v"))
    Condition
      Error in `new_user_word()`:
      ! `words` and `tags` must have the same length.

---

    Code
      new_user_word(engine1, "量子机器狗", NA_character_)
    Condition
      Error in `new_user_word()`:
      ! `tags` must be a character vector without NAs.

