#' Tag text with a jiebaRS worker
#'
#' Tag a single string with a `jieba_worker` created by [worker()].
#'
#' @param code A character scalar to tag.
#' @param jiebar A `jieba_worker` object created with `worker(type = "tag")`.
#' @param format Output format. `"vector"` returns a named character vector with
#'   token names and tag values, `"data.frame"` returns `term` and `tag`
#'   columns, and `"legacy"` returns the old `jiebaR` layout with token values
#'   and tag names.
#'
#' @return Tagging results in the requested format.
#' @export
tagging <- function(code, jiebar, format = c("vector", "data.frame", "legacy")) {
  format <- rlang::arg_match(format)

  if (!inherits(jiebar, "jieba_tagger")) {
    cli::cli_abort(
      r"(`jiebar` must be a `jieba_tagger` object created with `worker(type = "tag")`.)"
    )
  }

  # TODO: allow character vectors?
  if (!rlang::is_string(code)) {
    cli::cli_abort("`code` must be a non-missing character scalar.")
  }

  code <- enc2utf8(code)
  code <- symbol_handle(code, jiebar$config$symbol)

  result <- tagging_worker(code, jiebar$ptr)
  terms <- result$term
  tags <- result$tag

  if (!isTRUE(jiebar$config$symbol)) {
    keep <- terms != " "
    terms <- terms[keep]
    tags <- tags[keep]
  }

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

#' Tag text as a data frame
#'
#' Convenience wrapper around [tagging()] that always returns a data frame with
#' `term` and `tag` columns.
#'
#' @param x A character scalar to tag.
#' @param jiebar A `jieba_worker` object created with `worker(type = "tag")`.
#'
#' @return A data frame with `term` and `tag` columns.
#' @export
tagging_df <- function(x, jiebar) {
  tagging(x, jiebar, format = "data.frame")
}
