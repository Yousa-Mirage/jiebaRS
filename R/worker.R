#' Initialize a jiebaRS worker
#'
#' This function can initialize a jiebaRS worker. See Details for more information.
#'
#' @param type Worker type. Supported values are `"mix"` and `"keywords"`. Default is `"mix"`.
#' @param hmm Whether to enable HMM fallback in mixed mode.
#' @param topn Integer. The number of keywords returned by `keywords` or `simhash` workers. Default is `5`.
#' @param symbol Logical. Whether to keep symbol-like tokens in the sentence. Default is `FALSE`.
#'
#' @return A `jieba_worker` S3 object.
#' @export
worker <- function(type = "mix", hmm = TRUE, topn = 5L, symbol = FALSE) {
  valid_type_list <- c("mix", "keywords")
  if (
    !is.character(type) ||
      length(type) != 1L ||
      is.na(type) ||
      !(type %in% valid_type_list)
  ) {
    cli::cli_abort("`type` must be a character scalar and one of: {paste(valid_type_list, collapse = ', ')}.")
  }

  # TODO: the `hmm` is currently different from `jiebaR`
  stopifnot(is.logical(hmm), length(hmm) == 1L, !is.na(hmm))

  if (!is.numeric(topn) || length(topn) != 1L || is.na(topn) || topn < 0) {
    cli::cli_abort("`topn` must be a non-negative integer.")
  }
  topn <- as.integer(topn)

  if (!is.logical(symbol) || length(symbol) != 1L || is.na(symbol)) {
    cli::cli_abort("`symbol` must be `TRUE` or `FALSE`.")
  }

  # TODO: Extend the `keywords` worker config to cover the remaining jiebaR
  # compatibility knobs.
  # - `idf` path is not configurable yet; the Rust backend always uses
  #   `TfIdf::default()`.
  # - `stop_word` path is not configurable yet; `symbol` preprocessing is the
  #   only R-side filtering currently exposed.
  # - `hmm` is accepted for API compatibility, but the keyword extractor does
  #   not consume it yet on the Rust side.

  classes <- switch(
    type,
    mix = c("jieba_segmenter", "jieba_worker"),
    keywords = c("jieba_keywords", "jieba_worker")
  )

  structure(
    list(
      ptr = new_worker(type, hmm, topn),
      type = type,
      config = list(
        hmm = hmm,
        topn = topn,
        symbol = symbol
      )
    ),
    class = classes
  )
}
