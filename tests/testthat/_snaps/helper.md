# normalize_stop_words validates inputs

    Code
      normalize_stop_words(stop_word = 1:3)
    Condition
      Error in `normalize_stop_words()`:
      ! `stop_word` must be `NULL` or a character vector.

---

    Code
      normalize_stop_words(stop_word_file = 1)
    Condition
      Error in `normalize_stop_words()`:
      ! `stop_word_file` must be `NULL` or a single file path string.

---

    Code
      normalize_stop_words(stop_word_file = tempfile())
    Condition
      Error in `normalize_stop_words()`:
      ! `stop_word_file` must point to an existing file.

