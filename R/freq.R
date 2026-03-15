# TODO: Implement `freq()` in Rust to improve performance.

#' The frequency of words
#'
#' This function returns the frequency of words.
#'
#' @param x A character vector of words.
#' @param sort Whether to sort the result by descending frequency. The default
#'   `FALSE` keeps the first-appearance order.
#'
#' @return A data frame with `char` and `freq` columns.
#' @examples
#' freq(c("b", "a", "b", "c", "a"))
#' freq(c("b", "a", "b", "c", "a"), sort = TRUE)
#' @export
freq <- function(x, sort = FALSE) {
  if (!rlang::is_character(x)) {
    cli::cli_abort("`x` must be a character vector.")
  }

  if (!rlang::is_bool(sort)) {
    cli::cli_abort("`sort` must be `TRUE` or `FALSE`.")
  }

  x <- enc2utf8(x)

  chars <- unique(x)
  counts <- tabulate(match(x, chars), nbins = length(chars))

  if (isTRUE(sort) && length(counts) > 1L) {
    ord <- order(counts, decreasing = TRUE, method = "radix")
    chars <- chars[ord]
    counts <- counts[ord]
  }

  data.frame(
    char = chars,
    freq = counts,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}
