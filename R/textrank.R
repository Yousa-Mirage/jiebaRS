#' Extract TextRank keywords from text
#'
#' Extract TextRank-ranked keywords from a single in-memory string with a
#' TextRank worker created by [worker()]. This is separate from [keywords()],
#' which uses TF-IDF weighting.
#'
#' @param code A character to analyze.
#' @param jiebar A `jieba_worker` object created with `worker(type = "textrank")`.
#' @param ... Must be empty. This enforces that optional arguments such as
#'   `format` are supplied with explicit names.
#' @param format Output format. `"vector"` returns a named numeric vector,
#'   `"data.frame"` returns a data frame with `term` and `weight` columns, and
#'   `"legacy"` returns a `jiebaR`-style character vector with weights in
#'   `names()`. Default is `"vector"`.
#'
#' @return TextRank results in the requested format.
#' @export
textrank <- function(code, jiebar, ..., format = c("vector", "data.frame", "legacy")) {
  rlang::check_dots_empty()
  format <- rlang::arg_match(format)

  if (!inherits(jiebar, "jieba_textrank")) {
    cli::cli_abort(
      r"(`jiebar` must be a `jieba_textrank` object created with `worker(type = "textrank")`.)"
    )
  }

  if (!rlang::is_string(code)) {
    cli::cli_abort(
      r"(`code` must be a single non-NA character string.)"
    )
  }

  code <- enc2utf8(code)
  code <- symbol_handle(code, jiebar$config$symbol)

  result <- textrank_worker(code, jiebar$ptr)
  terms <- result$keyword
  weights <- result$weight

  switch(
    format,
    "vector" = stats::setNames(weights, terms),
    "data.frame" = data.frame(
      term = terms,
      weight = weights
    ),
    "legacy" = stats::setNames(terms, sprintf("%.17g", weights))
  )
}

#' Extract TextRank keywords as a data frame
#'
#' Convenience wrapper around [textrank()] that always returns a data frame with
#' `term` and `weight` columns.
#'
#' @param x A character to analyze.
#' @param jiebar A `jieba_worker` object created with `worker(type = "textrank")`.
#'
#' @return A data frame with `term` and `weight` columns.
#' @export
textrank_df <- function(x, jiebar) {
  textrank(x, jiebar, format = "data.frame")
}
