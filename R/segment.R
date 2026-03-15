#' Segment text with a jieba worker
#'
#' Segment one or more strings with a `jieba_worker` created by [worker()].
#'
#' @param code A character vector to segment.
#' @param jiebar A `jieba_worker` object.
#' @param format Output format. `"list"` returns one token vector per input
#'   string, `"data.frame"` returns `doc_id` and `word` columns, and
#'   `"flatten"` concatenates all token vectors into one character vector. When
#'   omitted, the worker's `bylines` setting is used for compatibility:
#'   `bylines = TRUE` maps to `"list"` and `bylines = FALSE` maps to
#'   `"flatten"`.
#'
#' @return Segmented tokens in the requested format.
#' @examples
#' seg <- worker()
#' segment("南京市长江大桥", seg)
#' segment(c("南京市长江大桥", "这是一个测试"), seg, format = "list")
#' segment(c("南京市长江大桥", "这是一个测试"), seg, format = "data.frame")
#' @export
segment <- function(code, jiebar, format = c("list", "data.frame", "flatten")) {
  if (!inherits(jiebar, "jieba_segmenter")) {
    cli::cli_abort("`jiebar` must be a `jieba_segmenter` object.")
  }

  if (!rlang::is_character(code) || anyNA(code) || rlang::is_empty(code)) {
    cli::cli_abort("`code` must be a non-empty character vector without missing values.")
  }

  format <- if (!missing(format)) {
    rlang::arg_match(format)
  } else if (isTRUE(jiebar$config$bylines)) {
    "list"
  } else {
    "flatten"
  }

  code <- enc2utf8(code)
  code <- symbol_handle(code, jiebar$config$symbol)

  segment_one <- function(text) {
    tokens <- segment_worker(text, jiebar$ptr)
    tokens[tokens != " "]
  }

  # TODO: implement in Rust
  result <- lapply(code, segment_one)

  switch(
    format,
    list = result,
    data.frame = data.frame(
      doc_id = rep.int(seq_along(result), lengths(result)),
      word = unlist(result, use.names = FALSE)
    ),
    flatten = unlist(result, use.names = FALSE)
  )
}

#' Segment a batch of strings
#'
#' Convenience wrapper around [segment()] for multi-string input. When
#' `format` is not supplied, `segment_batch()` always returns **list** output
#' and ignores the worker's `bylines` compatibility setting.
#'
#' @param texts A character vector of strings to segment.
#' @param jiebar A `jieba_worker` object.
#' @param format Output format. Supports `"list"`, `"data.frame"`, and
#'   `"flatten"`. The default is `"list"`.
#'
#' @return Segmented tokens in the requested format.
#' @examples
#' seg <- worker()
#' texts <- c("南京市长江大桥", "这是一个测试")
#' segment_batch(texts, seg)
#' segment_batch(texts, seg, format = "flatten")
#' @export
segment_batch <- function(texts, jiebar, format = c("list", "data.frame", "flatten")) {
  format <- rlang::arg_match(format)
  segment(texts, jiebar, format = format)
}
