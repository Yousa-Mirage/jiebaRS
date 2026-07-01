#' Extract keywords from text
#'
#' Extract TF-IDF keywords from a single in-memory string with a keyword worker
#' created by [worker()]. This is separate from [textrank()], which uses
#' TextRank weighting.
#'
#' @param code A character to analyze.
#' @param jiebar A `jieba_worker` object created with `worker(type = "keywords")`.
#' @param ... Must be empty. This enforces that optional arguments such as
#'   `format` are supplied with explicit names.
#' @param format Output format. `"numeric"` returns a named numeric vector,
#'   `"data.frame"` returns a data frame with `term` and `weight` columns, and
#'   `"legacy"` returns the old `jiebaR` style character vector with weights in
#'   `names()`. Default is `"numeric"`.
#'
#' @return Keyword results in the requested format.
#' @export
keywords <- function(code, jiebar, ..., format = c("numeric", "data.frame", "legacy")) {
  rlang::check_dots_empty()

  # TODO: Implement `vector_keywords()` to accept a pre-tokenized
  # character vector, skipping segmentation.
  format <- rlang::arg_match(format)

  if (!inherits(jiebar, "jieba_keywords")) {
    cli::cli_abort(
      r"(`jiebar` must be a `jieba_keywords` object created with `worker(type = "keywords")`.)"
    )
  }

  if (!rlang::is_string(code)) {
    cli::cli_abort(
      r"(`code` must be a single non-NA character string.)"
    )
  }

  code <- enc2utf8(code)
  code <- symbol_handle(code, jiebar$config$symbol)

  result <- keywords_worker(code, jiebar$ptr)
  keywords <- result$keyword
  weights <- result$weight

  switch(
    format,
    "numeric" = stats::setNames(weights, keywords),
    "data.frame" = data.frame(
      term = keywords,
      weight = weights
    ),
    "legacy" = stats::setNames(keywords, sprintf("%.17g", weights))
  )
}

#' Extract keywords as a data frame
#'
#' Convenience wrapper around [keywords()] that always returns a data frame with
#' `term` and `weight` columns.
#'
#' @param x A character to analyze.
#' @param jiebar A `jieba_worker` object created with `worker(type = "keywords")`.
#'
#' @return A data frame with `term` and `weight` columns.
#' @export
keywords_df <- function(x, jiebar) {
  keywords(x, jiebar, format = "data.frame")
}
