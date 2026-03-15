.symbol_text_pattern <- r"([^\p{L}\p{M}\p{N}])"

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
