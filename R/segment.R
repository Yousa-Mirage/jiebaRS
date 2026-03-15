#' Segment text with a jieba worker
#'
#' Segment a single string with a `jieba_worker` created by [worker()].
#'
#' @param code A character scalar to segment.
#' @param jiebar A `jieba_worker` object.
#'
#' @return A character vector of segmented tokens.
#' @export
segment <- function(code, jiebar) {
  if (!inherits(jiebar, "jieba_segmenter")) {
    cli::cli_abort("`jiebar` must be a `jieba_segmenter` object.")
  }

  if (!rlang::is_string(code)) {
    cli::cli_abort("`code` must be a non-missing character scalar.")
  }

  code <- enc2utf8(code)
  code <- symbol_handle(code, jiebar$config$symbol)

  tokens <- segment_worker(code, jiebar$ptr)
  drop_space_tokens(tokens)
}
