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
  if (is.character(tags) && length(tags) == 1L) {
    tags <- rep(tags, length(words))
  }

  # TODO: use cli::cli_abort() here for better error messages.
  stopifnot(
    inherits(worker, "jieba_worker"),
    length(words) == length(tags),
    is.character(words),
    is.character(tags)
  )

  words <- enc2utf8(words)
  tags <- enc2utf8(tags)

  add_user_words(worker$ptr, words, tags)
}
