#' Add user word
#'
#' Add one or more custom words to a jieba worker.
#'
#' @param worker A `jieba_worker` object.
#' @param words A non-empty string or a non-empty character vector of new words.
#' @param tags A single tag or a character vector of tags. Defaults to `"n"`
#'   for each supplied word. `NA` values are allowed and will be interpreted as missing tags.
#' @param freq Optional non-negative integer frequency or integer vector of
#'   frequencies. Defaults to `NULL`. `NA` values are allowed and will be
#'   interpreted as missing frequencies.
#' @return `NULL`, invisibly. Called for its side effect of adding the supplied
#'   words to `worker`, thereby modifying the state used by subsequent
#'   operations with the same worker.
#' @examples
#' cutter <- worker()
#' segment("\u91cf\u5b50\u673a\u5668\u72d7", cutter)
#' new_user_word(cutter, "\u91cf\u5b50\u673a\u5668\u72d7", tags = "n", freq = 1000L)
#' segment("\u91cf\u5b50\u673a\u5668\u72d7", cutter)
#'
#' cutter2 <- worker()
#' add_word(
#'   cutter2,
#'   c("\u8d85\u5bfc\u91cf\u5b50\u6bd4\u7279", "\u91cf\u5b50\u673a\u5668\u72d7"),
#'   tags = c(NA, "n"),
#'   freq = c(NA, 1000L)
#' )
#' segment("\u8d85\u5bfc\u91cf\u5b50\u6bd4\u7279", cutter2)
#'
#' @export
new_user_word <- function(worker, words, tags = "n", freq = NULL) {
  if (!inherits(worker, "jieba_worker")) {
    cli::cli_abort("`worker` must be a `jieba_worker` object.")
  }
  if (
    !rlang::is_character(words) ||
      rlang::is_empty(words) ||
      anyNA(words) ||
      any(words == "")
  ) {
    cli::cli_abort(
      "`words` must be a non-empty character vector of non-empty strings."
    )
  }

  n_words <- length(words)

  if (!rlang::is_character(tags)) {
    cli::cli_abort("`tags` must be a character vector.")
  }
  n_tags <- length(tags)
  if (n_tags != 1L && n_tags != n_words) {
    cli::cli_abort("`tags` must have length 1 or the same length as `words`.")
  }

  if (!is.null(freq)) {
    if (!rlang::is_integerish(freq) || any(freq < 0L, na.rm = TRUE)) {
      cli::cli_abort("`freq` must be `NULL` or a non-negative integer vector.")
    }
    n_freq <- length(freq)
    if (n_freq != 1L && n_freq != n_words) {
      cli::cli_abort("`freq` must have length 1 or the same length as `words`.")
    }

    freq <- as.integer(freq)
  }

  words <- enc2utf8(words)
  tags <- enc2utf8(tags)

  add_user_words(worker$ptr, words, tags, freq)
  invisible(NULL)
}

#' @rdname new_user_word
#' @export
add_word <- new_user_word
