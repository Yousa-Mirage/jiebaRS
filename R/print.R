#' @export
print.jieba_worker <- function(x, ...) {
  cat("<jieba_worker>\n", sep = "")
  cat("  type: ", x$type, "\n", sep = "")

  hmm <- x$config$hmm
  if (!is.null(hmm)) {
    cat("  hmm: ", hmm, "\n", sep = "")
  }

  topn <- x$config$topn
  if (!is.null(topn) && x$type %in% c("keywords", "textrank")) {
    cat("  topn: ", topn, "\n", sep = "")
  }

  symbol <- x$config$symbol
  if (!is.null(symbol)) {
    cat("  symbol: ", symbol, "\n", sep = "")
  }

  invisible(x)
}
