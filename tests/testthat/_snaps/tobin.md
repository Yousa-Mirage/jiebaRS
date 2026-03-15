# tobin snapshots invalid input

    Code
      tobin(1)
    Condition
      Error in `tobin()`:
      ! `x` must be a non-missing character scalar.

---

    Code
      tobin(NA_character_)
    Condition
      Error in `tobin()`:
      ! `x` must be a non-missing character scalar.

---

    Code
      tobin("not-a-number")
    Condition
      Error in `tobin()`:
      ! `x` must be a valid unsigned 64-bit integer written in base 10.

