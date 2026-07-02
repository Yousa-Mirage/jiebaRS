#' Filter segmentation results
#'
#' Remove selected words from a segmented character vector or from each element
#' of a list of segmented character vectors.
#'
#' @details
#' This is a modern reimplementation of `jiebaR::filter_segment()` with the
#' same core filtering behavior under the default settings.
#'
#' In the reproducible benchmark, this version is about **110x** to **140x**
#' faster than `jiebaR::filter_segment()` on the tested workloads.
#'
#' @param input A character vector or a list of character vectors.
#' @param filter_words A character vector of words to remove.
#' @param keep_na Whether to keep `NA` values in the returned result. The
#'   default `TRUE` matches `jiebaR::filter_segment()`.
#'
#' @return An object with the same shape as `input`, with matching words
#'   removed.
#' @examples
#' filter_segment(c("abc", "def", " ", "."), c("abc"))
#' filter_segment(c("a", NA, "b", "a"), c("b"), keep_na = FALSE)
#' input <- list(
#'   c("\u6211", "\u662f", "\u6d4b\u8bd5"),
#'   c("\u6d4b\u8bd5", "\u6587\u672c", "\u6211")
#' )
#' filter_segment(input, "\u6211")
#' @export
filter_segment <- function(input, filter_words, keep_na = TRUE) {
  if (!rlang::is_character(filter_words)) {
    cli::cli_abort("`filter_words` must be a character vector.")
  }
  if (!rlang::is_bool(keep_na)) {
    cli::cli_abort("`keep_na` must be a single `TRUE` or `FALSE` value.")
  }

  filter_words <- enc2utf8(filter_words)
  filter_words <- filter_words[!is.na(filter_words)]

  if (length(filter_words) == 0L) {
    return(input)
  }

  filter_one <- function(x) {
    x <- enc2utf8(x)
    x <- x[is.na(match(x, filter_words))]

    if (!isTRUE(keep_na)) {
      x <- x[!is.na(x)]
    }

    x
  }

  if (is.character(input)) {
    return(filter_one(input))
  }

  if (is.list(input) && all(vapply(input, is.character, logical(1)))) {
    return(lapply(input, filter_one))
  }

  cli::cli_abort(
    "`input` must be a character vector or a list of character vectors."
  )
}
