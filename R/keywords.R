#' Extract keywords from text
#'
#' Extract TF-IDF keywords from a single in-memory string with a keyword worker
#' created by [worker()].
#'
#' @param code A character to analyze.
#' @param jiebar A `jieba_worker` object created with `worker(type = "keywords")`.
#' @param format Output format. `"numeric"` returns a named numeric vector,
#'   `"data.frame"` returns a data frame with `term` and `weight` columns, and
#'   `"legacy"` returns the old `jiebaR` style character vector with weights in
#'   `names()`. Default is `"numeric"`.
#'
#' @return Keyword results in the requested format.
#' @export
keywords <- function(code, jiebar, format = c("numeric", "data.frame", "legacy")) {
  # TODO: Fill in the remaining jiebaR keyword API surface.
  # - Implement `vector_keywords()` for pre-tokenized input.
  # - Add the `<=` / `[` sugar methods once the core API stabilizes.
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
      weight = weights,
      stringsAsFactors = FALSE,
      check.names = FALSE
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
