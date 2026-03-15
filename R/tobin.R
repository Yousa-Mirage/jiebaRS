#' Convert a simhash value to binary
#'
#' Convert a decimal simhash value into a fixed-width 64-bit binary string.
#'
#' @param x A non-missing character scalar containing a decimal unsigned
#'   64-bit integer.
#'
#' @return A character scalar containing the 64-bit binary representation.
#' @examples
#' tobin("1")
#' tobin("2")
#' @export
tobin <- function(x) {
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort("`x` must be a non-missing character scalar.")
  }

  res <- tobin_rs(enc2utf8(x))

  if (is.na(res)) {
    cli::cli_abort("`x` must be a valid unsigned 64-bit integer written in base 10.")
  }

  res
}
