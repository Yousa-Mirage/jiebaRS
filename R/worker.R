#' Initialize a jiebaRS worker
#'
#' This function can initialize a jiebaRS worker. See Details for more information.
#'
#' @details
#' **The `qmax` argument is not supported.** Although `jiebaR` documented
#' `qmax` for query workers, the value was never actually passed to the
#' underlying segmentation call. Similarly, the `jieba-rs` backend implements
#' search-mode segmentation without a configurable query threshold. To avoid
#' user confusion, jiebaRS omits the qmax argument entirely rather than
#' retaining a no-op parameter.
#' 
#' The `hmm` flag currently affects `mix` and `query` workers. `full` workers
#' ignore `hmm`, and `keywords` workers currently keep the value only for API
#' compatibility while the Rust keyword backend still uses its default HMM
#' behavior.
#'
#' @param type Worker type. Supported values are `"mix"`, `"full"`, `"query"`,
#'   and `"keywords"`. Default is `"mix"`.
#' @param hmm Whether to enable HMM fallback when the selected worker type uses
#'   mixed-mode segmentation.
#' @param topn Integer. The number of keywords returned by `keywords` or
#'   `simhash` workers. Default is `5`.
#' @param symbol Logical. Whether to keep symbol-like tokens in the sentence. Default is `FALSE`.
#'
#' @return A `jieba_worker` S3 object.
#' @export
worker <- function(
  type = c("mix", "full", "query", "keywords"),
  hmm = TRUE,
  topn = 5L,
  symbol = FALSE
) {
  type <- rlang::arg_match(type, c("mix", "full", "query", "keywords"))

  if (!rlang::is_bool(hmm)) {
    cli::cli_abort("`hmm` must be `TRUE` or `FALSE`.")
  }

  if (!rlang::is_integerish(topn, n = 1) || topn < 0) {
    cli::cli_abort("`topn` must be a non-negative integer.")
  }
  topn <- as.integer(topn)

  if (!rlang::is_bool(symbol)) {
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

  classes <- c(
    ifelse(type == "keywords", "jieba_keywords", "jieba_segmenter"),
    "jieba_worker"
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
