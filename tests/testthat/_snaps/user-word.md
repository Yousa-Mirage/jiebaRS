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
      ! `tags` must have length 1 or the same length as `words`.

---

    Code
      new_user_word(engine1, c("量子机器狗", "超导量子比特"), freq = c(10L, 20L, 30L))
    Condition
      Error in `new_user_word()`:
      ! `freq` must have length 1 or the same length as `words`.

---

    Code
      new_user_word(engine1, "量子机器狗", freq = -1L)
    Condition
      Error in `new_user_word()`:
      ! `freq` must be `NULL` or a non-negative integer vector.

---

    Code
      new_user_word(engine1, "量子机器狗", freq = 1.5)
    Condition
      Error in `new_user_word()`:
      ! `freq` must be `NULL` or a non-negative integer vector.

---

    Code
      new_user_word(engine1, "量子机器狗", freq = "100")
    Condition
      Error in `new_user_word()`:
      ! `freq` must be `NULL` or a non-negative integer vector.

