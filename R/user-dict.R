#' Add user word
#'
#' Add one or more custom words to a jieba worker.
#'
#' @param worker A `jieba_worker` object.
#' @param words A single string or a character vector of new words.
#' @param tags A single tag or a character vector of tags. Defaults to `"n"`
#'   for each supplied word.
#'
#' @export
new_user_word <- function(worker, words, tags = "n") {
  if (rlang::is_string(tags)) {
    tags <- rep(tags, length(words))
  }

  if (!inherits(worker, "jieba_worker")) {
    cli::cli_abort("`worker` must be a `jieba_worker` object.")
  }
  if (!rlang::is_character(words) || anyNA(words)) {
    cli::cli_abort("`words` must be a character vector without NAs.")
  }
  if (!rlang::is_character(tags) || anyNA(tags)) {
    cli::cli_abort("`tags` must be a character vector without NAs.")
  }
  if (length(words) != length(tags)) {
    cli::cli_abort("`words` and `tags` must have the same length.")
  }

  words <- enc2utf8(words)
  tags <- enc2utf8(tags)

  add_user_words(worker$ptr, words, tags)
}

#' @rdname new_user_word
#' @export
add_word <- new_user_word
