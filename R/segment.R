#' Segment text with a jieba worker
#'
#' Segment one or more strings with a `jieba_worker` created by [worker()].
#'
#' @details
#' For a single input string, `segment()` always returns a character vector of
#' segmented tokens.
#'
#' In the current release benchmarks on the bundled *Fortress Besieged* and
#' *Dream of the Red Chamber* texts, `jiebaRS::segment()` is about **1.7x to
#' 1.9x faster** than `jiebaR::segment()` when each novel is segmented as one
#' long string. When the input is many short strings segmented in parallel,
#' `jiebaRS::segment()` reaches about **7x to 12x speedup** over `jiebaR`.
#'
#' For very long texts, splitting into about **32 to 128 chunks** before
#' segmentation is recommended for good throughput.
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
#' The `mod` argument from `jiebaR::segment()` is retained only as a deprecated
#' compatibility placeholder. In `jiebaRS`, segmentation behavior should be
#' controlled by the worker type itself (for example, `worker(type = "mix")` or
#' `worker(type = "query")`), not by mutating behavior at call time. When `mod`
#' is supplied, `jiebaRS` warns and ignores it.
#'
#' @param code A character vector to segment.
#' @param jiebar A `jieba_worker` object.
#' @param ... Must be empty. This enforces that optional arguments such as
#'   `mod` and `batch` are supplied with explicit names.
#' @param mod [Deprecated] Compatibility argument retained from `jiebaR`. This
#'   argument no longer has any effect.
#' @param batch Batch aggregation mode for **multi-string input**. Must be
#' one of `"list"`, `"data.frame"`, or `"flatten"`. The default is `"list"`.
#'
#' @return Segmented tokens in the requested aggregation form.
#' @examples
#' seg <- worker()
#' text1 <- "\u5357\u4eac\u5e02\u957f\u6c5f\u5927\u6865"
#' text2 <- "\u8fd9\u662f\u4e00\u4e2a\u6d4b\u8bd5"
#' segment(text1, seg)
#' segment(c(text1, text2), seg, batch = "list")
#' segment(c(text1, text2), seg, batch = "data.frame")
#' @export
segment <- function(code, jiebar, ..., mod = NULL, batch = c("list", "data.frame", "flatten")) {
  rlang::check_dots_empty()

  if (!inherits(jiebar, "jieba_segmenter")) {
    cli::cli_abort("`jiebar` must be a `jieba_segmenter` object.")
  }

  if (!rlang::is_character(code) || anyNA(code) || rlang::is_empty(code)) {
    cli::cli_abort("`code` must be a non-empty character vector without missing values.")
  }

  if (!missing(mod)) {
    cli::cli_warn(
      paste(
        "`mod` is deprecated in `jiebaRS` and no longer has any effect.",
        "Use a worker with the desired type instead."
      )
    )
  }

  batch <- if (!missing(batch)) rlang::arg_match(batch) else "list"

  code <- enc2utf8(code)
  code <- symbol_handle(code, jiebar$config$symbol)

  if (length(code) == 1L) {
    return(segment_worker(code[[1]], jiebar$ptr))
  }

  result <- segment_batch_worker(code, jiebar$ptr)

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
#' In the current release benchmarks on the bundled *Fortress Besieged* and
#' *Dream of the Red Chamber* texts, batch segmentation reaches about **7x to
#' 12x speedup** over the comparable `jiebaR` workflow on many-string inputs.
#' For very long texts, splitting into about **32 to 128 chunks** before calling
#' `segment_batch()` is recommended for good throughput.
#'
#' @param texts A character vector of strings to segment.
#' @param jiebar A `jieba_worker` object.
#' @param ... Must be empty. This enforces that optional arguments such as
#'   `batch` are supplied with explicit names.
#' @param batch Batch aggregation mode. Must be one of `"list"`,
#'   `"data.frame"`, or `"flatten"`. The default is `"list"`.
#'
#' @return Segmented tokens in the requested aggregation form.
#' @examples
#' seg <- worker()
#' texts <- c("\u5357\u4eac\u5e02\u957f\u6c5f\u5927\u6865", "\u8fd9\u662f\u4e00\u4e2a\u6d4b\u8bd5")
#' segment_batch(texts, seg)
#' segment_batch(texts, seg, batch = "flatten")
#' @export
segment_batch <- function(texts, jiebar, ..., batch = c("list", "data.frame", "flatten")) {
  rlang::check_dots_empty()

  batch <- rlang::arg_match(batch)
  segment(texts, jiebar, batch = batch)
}
