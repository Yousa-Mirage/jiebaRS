# Internal helper for applying a single, package-wide symbol preprocessing step
# before calling the Rust backend.
symbol_handle <- function(x, symbol) {
  if (isTRUE(symbol)) {
    return(x)
  }

  gsub(r"([^\p{L}\p{M}\p{N}])", " ", x, perl = TRUE)
}

normalize_stop_words <- function(stop_word = NULL, stop_word_file = NULL) {
  if (is.null(stop_word) && is.null(stop_word_file)) {
    return(character())
  }

  if (!is.null(stop_word) && !rlang::is_character(stop_word)) {
    cli::cli_abort("`stop_word` must be `NULL` or a character vector.")
  }

  if (!is.null(stop_word_file)) {
    if (!rlang::is_string(stop_word_file)) {
      cli::cli_abort("`stop_word_file` must be `NULL` or a single file path string.")
    }

    if (!file.exists(stop_word_file)) {
      cli::cli_abort("`stop_word_file` must point to an existing file.")
    }
  }

  words <- if (is.null(stop_word)) character() else stop_word

  if (!is.null(stop_word_file)) {
    stop_words_from_file <- readLines(stop_word_file, warn = FALSE, encoding = "UTF-8")
    words <- c(words, stop_words_from_file)
  }

  if (length(words) == 0L) {
    return(character())
  }

  words <- enc2utf8(words)
  words <- trimws(words)
  words <- words[!is.na(words) & nzchar(words)]
  unique(words)
}
