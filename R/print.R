#' @export
print.jieba_worker <- function(x, ...) {
  cat("<jieba_worker>\n", sep = "")
  cat("  type: ", x$type, "\n", sep = "")

  hmm <- x$config$hmm
  if (!is.null(hmm)) {
    cat("  hmm: ", hmm, "\n", sep = "")
  }

  invisible(x)
}
