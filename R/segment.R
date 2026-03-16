#' Segment text with a jieba worker
#'
#' Segment one or more strings with a `jieba_worker` created by [worker()].
#'
#' @details
#' For a single input string, `segment()` always returns a character vector of
#' segmented tokens.
#'
#' For multiple input strings, the argument `batch` controls how the
#' per-string token vectors are aggregated:
#' - `"list"`: one character vector per input string.
#' - `"data.frame"`: a data frame with `doc_id` and `word` columns.
#' - `"flatten"`: all token vectors concatenated into one character vector.
#'
#' When `batch` is omitted, `jiebaRS` returns list output for multi-string
#' input.
#'
#' @param code A character vector to segment.
#' @param jiebar A `jieba_worker` object.
#' @param batch Batch aggregation mode for **multi-string input**. Must be
#' one of `"list"`, `"data.frame"`, or `"flatten"`. The default is `"list"`.
#'
#' @return Segmented tokens in the requested aggregation form.
#' @examples
#' seg <- worker()
#' segment("南京市长江大桥", seg)
#' segment(c("南京市长江大桥", "这是一个测试"), seg, batch = "list")
#' segment(c("南京市长江大桥", "这是一个测试"), seg, batch = "data.frame")
#' @export
segment <- function(code, jiebar, batch = c("list", "data.frame", "flatten")) {
  if (!inherits(jiebar, "jieba_segmenter")) {
    cli::cli_abort("`jiebar` must be a `jieba_segmenter` object.")
  }

  if (!rlang::is_character(code) || anyNA(code) || rlang::is_empty(code)) {
    cli::cli_abort("`code` must be a non-empty character vector without missing values.")
  }

  batch <- if (!missing(batch)) rlang::arg_match(batch) else "list"

  code <- enc2utf8(code)
  code <- symbol_handle(code, jiebar$config$symbol)

  segment_one <- function(text) {
    tokens <- segment_worker(text, jiebar$ptr)
    tokens[tokens != " "]
  }

  # TODO: implement in Rust
  result <- lapply(code, segment_one)

  if (length(result) == 1L) {
    return(result[[1]])
  }

  switch(
    batch,
    "list" = result,
    "data.frame" = data.frame(
      doc_id = rep.int(seq_along(result), lengths(result)),
      word = unlist(result, use.names = FALSE)
    ),
    "flatten" = unlist(result, use.names = FALSE)
  )
}

#' Segment a batch of strings
#'
#' Convenience wrapper around [segment()] for multi-string input. When
#' `batch` is omitted, `segment_batch()` will return **list** output by default.
#'
#' @details
#' `segment_batch()` is a convenience wrapper around [segment()] for explicit
#' batch processing. It always treats `texts` as multi-string input. The
#' returned object depends on `batch`:
#' - `"list"`: one character vector per input string.
#' - `"data.frame"`: a data frame with `doc_id` and `word` columns.
#' - `"flatten"`: one concatenated character vector.
#'
#' @param texts A character vector of strings to segment.
#' @param jiebar A `jieba_worker` object.
#' @param batch Batch aggregation mode. Must be one of `"list"`,
#'   `"data.frame"`, or `"flatten"`. The default is `"list"`.
#'
#' @return Segmented tokens in the requested aggregation form.
#' @examples
#' seg <- worker()
#' texts <- c("南京市长江大桥", "这是一个测试")
#' segment_batch(texts, seg)
#' segment_batch(texts, seg, batch = "flatten")
#' @export
segment_batch <- function(texts, jiebar, batch = c("list", "data.frame", "flatten")) {
  batch <- rlang::arg_match(batch)
  segment(texts, jiebar, batch = batch)
}
