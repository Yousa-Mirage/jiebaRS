#' Create a jieba worker
#'
#' Create a segmentation worker backed by the Rust `jieba-rs` engine.
#'
#' @param type Segmentation worker type. Only `"mix"` is currently supported.
#' @param hmm Whether to enable HMM fallback in mixed mode.
#'
#' @return A `jieba_worker` S3 object.
#' @export
worker <- function(type = "mix", hmm = TRUE) {
  stopifnot(is.character(type), length(type) == 1L, !is.na(type))
  stopifnot(is.logical(hmm), length(hmm) == 1L, !is.na(hmm))

  if (!identical(type, "mix")) {
    stop("Only `type = \"mix\"` is implemented right now.", call. = FALSE)
  }

  structure(
    list(
      ptr = new_worker(type, hmm),
      type = type,
      config = list(hmm = hmm)
    ),
    class = c("jieba_segmenter", "jieba_worker")
  )
}
