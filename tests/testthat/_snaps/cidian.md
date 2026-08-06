# import_cidian snapshots missing file errors

    Code
      import_cidian(worker(), missing_file)
    Condition
      Error in `import_cidian()`:
      ! `path` must point to an existing input-method dictionary file.

# import_cidian snapshots unsupported extension errors

    Code
      import_cidian(worker(), unsupported_file)
    Condition
      Error in `import_cidian()`:
      ! Unsupported input-method dictionary extension in '<unsupported-file>'.
      i Supported extensions are `.scel`, `.qcel`, `.qpyd`, `.bdict`, `.bcd`.

