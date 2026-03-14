#' Segment text with a jieba worker
#'
#' Segment a single in-memory string with a `jieba_worker` created by [worker()].
#'
#' @param code A character scalar to segment.
#' @param jiebar A `jieba_worker` object.
#'
#' @return A character vector of segmented tokens.
#' @export
segment <- function(code, jiebar) {
  if (!inherits(jiebar, "jieba_worker")) {
    stop("`jiebar` must be a `jieba_worker` object.", call. = FALSE)
  }

  if (!is.character(code) || length(code) != 1L || is.na(code)) {
    stop("`code` must be a non-missing character scalar.", call. = FALSE)
  }

  segment_worker(enc2utf8(code), jiebar$ptr)
}
