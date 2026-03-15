# worker snapshots invalid type input

    Code
      worker(type = "nope")
    Condition
      Error in `worker()`:
      ! `type` must be one of "mix", "full", "query", or "keywords", not "nope".

