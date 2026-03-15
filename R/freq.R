# TODO: Implement `freq()` in Rust to improve performance.

#' The frequency of words
#'
#' This function returns the frequency of words.
#'
#' @param x A character vector of words.
#'
#' @return A data frame with `char` and `freq` columns.
#' @export
freq <- function(x) {
  if (!is.character(x)) {
    cli::cli_abort("`x` must be a character vector.")
  }

  x <- enc2utf8(x)

  # TODO: Add optional sorting modes for first appearance order, character
  # order, pinyin order, and frequency order.
  chars <- unique(x)
  counts <- tabulate(match(x, chars), nbins = length(chars))

  data.frame(
    char = chars,
    freq = counts,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}
