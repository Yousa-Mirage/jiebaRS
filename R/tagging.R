.format_one <- function(terms, tags, format) {
  switch(
    format,
    "vector" = stats::setNames(tags, terms),
    "data.frame" = data.frame(
      term = terms,
      tag = tags
    ),
    "legacy" = stats::setNames(terms, tags)
  )
}

#' Tag text with a jiebaRS worker
#'
#' Tag one or more strings with a `jieba_worker` created by [worker()].
#'
#' @details
#' `format` controls the shape of each single-string tagging result:
#' - `"vector"`: a named character vector with token names and tag values.
#' - `"data.frame"`: a data frame with `term` and `tag` columns.
#' - `"legacy"`: the old `jiebaR` layout with token values and tag names.
#'
#' In the current release benchmarks on the bundled 《围城》 and 《红楼梦》
#' texts, `jiebaRS::tagging()` is about **1.6x to 1.8x faster** than
#' `jiebaR::tagging()` when each novel is tagged as one long string. When the
#' same content is split into many strings and processed in batch,
#' `jiebaRS::tagging()` is about **2x to 5x faster** than `jiebaR`.
#'
#' For very long texts, splitting before tagging is usually faster than sending
#' one huge string. In the same release benchmarks, the best results appeared
#' around **32 to 128 chunks**, while much finer splitting still helped but was
#' no longer optimal.
#'
#' When `code` contains multiple strings, `batch` controls how the per-string
#' results are aggregated:
#' - `"list"`: one single-string result per input string.
#' - `"data.frame"`: only valid when `format = "data.frame"`; combines all
#'   rows and adds `doc_id`.
#' - `"flatten"`: only valid when `format` is `"vector"` or `"legacy"`;
#'   concatenates all results into one named character vector.
#'
#' When `batch` is omitted, `jiebaRS` returns `"vector"` for single-string
#' input and `"list"` for multi-string input.
#'
#' @param code A non-empty character vector to tag.
#' @param jiebar A `jieba_worker` object created with `worker(type = "tag")`.
#' @param ... Must be empty. This enforces that optional arguments such as
#'   `format` and `batch` are supplied with explicit names.
#' @param format Output format for a single tagged string. Must be one of
#'   `"vector"`, `"data.frame"`, or `"legacy"`.
#' @param batch Aggregation mode for multi-string input. Must be one of
#'   `"list"`, `"data.frame"`, or `"flatten"`.
#'
#' @return Tagging results in the requested format.
#' @examples
#' tagger <- worker(type = "tag")
#' tagging("这是一个测试", tagger)
#' tagging(c("这是一个测试", "再来一次"), tagger)
#' tagging(c("这是一个测试", "再来一次"), tagger, format = "data.frame", batch = "data.frame")
#' @export
tagging <- function(
  code,
  jiebar,
  ...,
  format = c("vector", "data.frame", "legacy"),
  batch = c("list", "data.frame", "flatten")
) {
  rlang::check_dots_empty()

  if (!inherits(jiebar, "jieba_tagger")) {
    cli::cli_abort(
      r"(`jiebar` must be a `jieba_tagger` object created with `worker(type = "tag")`.)"
    )
  }

  if (!rlang::is_character(code) || anyNA(code) || rlang::is_empty(code)) {
    cli::cli_abort("`code` must be a non-empty character vector without missing values.")
  }

  format <- rlang::arg_match(format, c("vector", "data.frame", "legacy"))

  code <- enc2utf8(code)
  code <- symbol_handle(code, jiebar$config$symbol)

  is_single <- length(code) == 1L

  result <- if (is_single) {
    tagging_worker(code[[1]], jiebar$ptr)
  } else {
    tagging_batch_worker(code, jiebar$ptr)
  }

  if (is_single) {
    return(.format_one(result$term, result$tag, format))
  }

  batch <- rlang::arg_match(batch)

  if (identical(batch, "data.frame") && !identical(format, "data.frame")) {
    cli::cli_abort("`batch = 'data.frame'` requires `format = 'data.frame'`.")
  }

  if (identical(batch, "flatten") && identical(format, "data.frame")) {
    cli::cli_abort("`batch = 'flatten'` is not supported with `format = 'data.frame'`.")
  }

  if (identical(batch, "list")) {
    return(lapply(result, function(x) .format_one(x$term, x$tag, format)))
  }

  terms_list <- lapply(result, .subset2, "term")
  tags_list <- lapply(result, .subset2, "tag")
  all_terms <- unlist(terms_list, use.names = FALSE)
  all_tags <- unlist(tags_list, use.names = FALSE)

  if (identical(batch, "flatten")) {
    return(.format_one(all_terms, all_tags, format))
  }

  data.frame(
    doc_id = rep.int(seq_along(result), lengths(terms_list)),
    term = all_terms,
    tag = all_tags
  )
}

#' Tag a batch of strings
#'
#' Convenience wrapper around [tagging()] for multi-string input. When `batch`
#' is not supplied, `tagging_batch()` always returns list output.
#'
#' @details
#' `tagging_batch()` is a convenience wrapper for explicit multi-string input.
#' The returned object depends on both `format` and `batch`:
#' - `batch = "list"`: returns one single-string tagging result per input
#'   string.
#' - `batch = "data.frame"`: requires `format = "data.frame"`; combines all
#'   rows and adds `doc_id`.
#' - `batch = "flatten"`: requires `format = "vector"` or `"legacy"`;
#'   concatenates the individual results into one named character vector.
#'
#' In the current release benchmarks on the bundled 《围城》 and 《红楼梦》
#' texts, batch tagging is about **2x to 5x faster** than the comparable
#' `jiebaR` workflow on many-string inputs. For very long texts, the best
#' throughput was usually reached by splitting into about **32 to 128 chunks**,
#' while much finer splitting still helped but was no longer optimal.
#'
#' @param texts A non-empty character vector to tag.
#' @param jiebar A `jieba_worker` object created with `worker(type = "tag")`.
#' @param ... Must be empty. This enforces that optional arguments such as
#'   `format` and `batch` are supplied with explicit names.
#' @param format Output format for each single tagged result. Must be one of
#'   `"vector"`, `"data.frame"`, or `"legacy"`.
#' @param batch Aggregation mode. Must be one of `"list"`, `"data.frame"`, or
#'   `"flatten"`.
#'
#' @return Tagging results in the requested format.
#' @examples
#' tagger <- worker(type = "tag")
#' texts <- c("这是一个测试", "再来一次")
#' tagging_batch(texts, tagger)
#' tagging_batch(texts, tagger, format = "legacy", batch = "flatten")
#' @export
tagging_batch <- function(
  texts,
  jiebar,
  ...,
  format = c("vector", "data.frame", "legacy"),
  batch = c("list", "data.frame", "flatten")
) {
  rlang::check_dots_empty()

  format <- rlang::arg_match(format, c("vector", "data.frame", "legacy"))
  batch <- rlang::arg_match(batch, c("list", "data.frame", "flatten"))
  tagging(texts, jiebar, format = format, batch = batch)
}
