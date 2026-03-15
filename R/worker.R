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
#' `jieba-rs` does not expose dedicated public implementations for `mp` or
#' `hmm` workers. `jiebaRS` therefore maps `mp` to `cut(..., false)` and `hmm`
#' to `cut(..., true)`. This is a compatibility approximation rather than a
#' byte-for-byte reimplementation of `jiebaR`, and `jiebaRS` warns once per R
#' session when either type is requested.
#'
#' `tag` workers use `jieba-rs` tagging on top of the default mixed
#' segmentation path, which is the closest public behavior to `jiebaR`.
#'
#' The `hmm` flag currently affects `mix` and `query` workers. `mp`, `hmm`, and
#' `full` workers ignore `hmm`. `tag` workers use it for the underlying mixed
#' segmentation step, and `keywords` workers currently keep the value only for
#' API compatibility while the Rust keyword backend still uses its default HMM
#' behavior.
#'
#' @param type Worker type. Supported values are `"mix"`, `"mp"`, `"hmm"`,
#'   `"full"`, `"query"`, `"tag"`, and `"keywords"`. Default is `"mix"`.
#' @param hmm Whether to enable HMM fallback when the selected worker type uses
#'   mixed-mode segmentation. Default is `TRUE`.
#' @param topn Integer. The number of keywords returned by `keywords`
#'   workers. Default is `5`.
#' @param symbol Logical. Whether to keep symbol-like tokens in the sentence. Default is `FALSE`.
#' @param bylines Logical compatibility argument retained from `jiebaR`. When
#'   `segment()` or `tagging()` are called without an explicit `format`,
#'   `bylines = TRUE` maps to list output and `bylines = FALSE` maps to a
#'   flattened vector. Prefer controlling the output with `format` in those
#'   functions directly.
#'
#' @return A `jieba_worker` S3 object.
#' @export
worker <- function(
  type = c("mix", "mp", "hmm", "full", "query", "tag", "keywords"),
  hmm = TRUE,
  topn = 5L,
  symbol = FALSE,
  bylines = FALSE
) {
  type <- rlang::arg_match(type)

  if (identical(type, "mp")) {
    cli::cli_warn(
      paste(
        "`worker(type = 'mp')` is currently mapped to `jieba-rs`",
        "`cut(..., false)` because `jieba-rs` does not expose a dedicated",
        "`mp` segmenter. Results may differ from `jiebaR`."
      ),
      .frequency = "once",
      .frequency_id = "worker_mp_mapping"
    )
  }

  if (identical(type, "hmm")) {
    cli::cli_warn(
      paste(
        "`worker(type = 'hmm')` is currently mapped to `jieba-rs`",
        "`cut(..., true)` because `jieba-rs` does not expose a dedicated",
        "`hmm` segmenter. Results may differ from `jiebaR`."
      ),
      .frequency = "once",
      .frequency_id = "worker_hmm_mapping"
    )
  }

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

  if (!rlang::is_bool(bylines)) {
    cli::cli_abort("`bylines` must be `TRUE` or `FALSE`.")
  }

  if (!missing(bylines)) {
    cli::cli_warn(
      paste(
        "`bylines` is retained only for jiebaR compatibility.",
        "Prefer controlling output shape with the `format` argument in",
        "`segment()` and `tagging()`."
      )
    )
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
    switch(
      type,
      keywords = "jieba_keywords",
      tag = "jieba_tagger",
      "jieba_segmenter"
    ),
    "jieba_worker"
  )

  structure(
    list(
      ptr = new_worker(type, hmm, topn),
      type = type,
      config = list(
        hmm = hmm,
        topn = topn,
        symbol = symbol,
        bylines = bylines
      )
    ),
    class = classes
  )
}
