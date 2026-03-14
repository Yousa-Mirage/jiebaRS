.symbol_text_pattern <-
  r"([^\x{2E80}-\x{3000}\x{3021}-\x{FE4F}a-zA-Z0-9])"

# Internal helper for applying a single, package-wide symbol preprocessing step
# before calling the Rust backend.
symbol_handle <- function(x, symbol) {
  if (isTRUE(symbol)) {
    return(x)
  }

  gsub(.symbol_text_pattern, " ", x, perl = TRUE)
}

# Internal helper for removing whitespace tokens introduced by preprocessing.
drop_space_tokens <- function(x) {
  x[x != " "]
}
