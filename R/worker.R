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
#' `stop_word` and `stop_word_file` can be both supplied at once and then
#' be merged together. Then they will be normalized.
#'
#' In `jiebaRS`, `hmm` accepts either a logical scalar or a file path. A
#' logical value controls whether the underlying `jieba-rs`
#' segmentation/tagging pipeline may fall back to HMM for unknown terms. A
#' character scalar is interpreted as a path to a custom HMM model file and
#' enables HMM fallback with that model. The flag affects `mix` and `query`
#' workers directly, `tag` workers through the underlying mixed tagging path,
#' and `keywords` workers through TF-IDF keyword extraction. `mp`, `hmm`, and
#' `full` workers ignore the runtime switch because their `jieba-rs` backends
#' do not use this runtime switch.
#'
#' `dict` and `user` load dictionary files at worker creation time. `dict`
#' *replaces* the embedded main dictionary entirely; `user` accepts one or more
#' file paths whose entries are appended, in the supplied order, to whatever
#' main dictionary is in place (default or custom `dict`). Main dictionary
#' entries use `word [freq] [tag]`; an omitted frequency defaults to `1`. User
#' dictionary entries may use `word`, `word freq`, `word tag` (the legacy
#' two-column `jiebaR` format), or `word freq tag`. User frequencies must be
#' positive integers; when omitted, a frequency is inferred from the current
#' dictionary. Files must be UTF-8; a leading byte order mark (BOM) is allowed.
#'
#' @param type Worker type. Supported values are `"mix"`, `"mp"`, `"hmm"`,
#'   `"full"`, `"query"`, `"tag"`, `"keywords"`, and `"textrank"`.
#'   Default is `"mix"`.
#' @param stop_word Optional character vector of stop words supplied directly.
#' @param stop_word_file Optional file path containing one stop word per line.
#' @param hmm Logical scalar or character scalar. If logical, controls whether
#'   to enable HMM fallback for unknown terms. If character, must be a path to a
#'   custom HMM model file compatible with `jieba-rs`'s `hmm.model` format, and
#'   HMM fallback is enabled with that model. Default is `TRUE`.
#' @param topn Integer. The number of terms returned by `keywords` and
#'   `textrank` workers. Default is `5`.
#' @param min_keyword_length Positive integer. The minimum number of Unicode
#'   scalar values in terms returned by `keywords` and `textrank` workers.
#'   Default is `2`.
#' @param idf Optional character scalar. A path to a custom IDF dictionary
#'   file for `keywords` workers. Each line should be `word idf_value`. When
#'   `NULL`, the embedded default IDF dictionary is used. Ignored by non-keyword
#'   workers. Default is `NULL`.
#' @param dict Optional character scalar. A path to a custom main dictionary
#'   file that *replaces* the embedded dictionary. Each line should be
#'   `word [freq] [tag]` (whitespace-separated; `freq` defaults to `1`, `tag`
#'   defaults to empty). When `NULL`, the embedded dictionary is used. Default
#'   is `NULL`.
#' @param user Optional character vector containing one or more paths to user
#'   dictionary files whose entries are *appended* to the main dictionary in
#'   the supplied order. Supported line formats are `word`, `word freq`,
#'   `word tag`, and `word freq tag`. Omitted frequencies are inferred from the
#'   current dictionary. Default is `NULL`.
#' @param symbol Logical. Whether to keep symbol-like tokens in the sentence. Default is `FALSE`.
#' @param bylines [Deprecated] compatibility argument retained from `jiebaR`.
#'   `jiebaRS` no longer uses this value; control batch aggregation directly
#'   in specific functions.
#'
#' @return A `jieba_worker` S3 object.
#' @export
worker <- function(
  type = c("mix", "mp", "hmm", "full", "query", "tag", "keywords", "textrank"),
  stop_word = NULL,
  stop_word_file = NULL,
  hmm = TRUE,
  topn = 5L,
  min_keyword_length = 2L,
  idf = NULL,
  dict = NULL,
  user = NULL,
  symbol = FALSE,
  bylines = FALSE
) {
  type <- rlang::arg_match(type)
  stop_words <- normalize_stop_words(stop_word, stop_word_file)
  hmm_model <- ""

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

  if (rlang::is_string(hmm)) {
    if (!file.exists(hmm)) {
      cli::cli_abort("`hmm` must point to an existing custom HMM model file.")
    }
    hmm_model <- enc2utf8(hmm)
    hmm <- TRUE
  } else if (!rlang::is_bool(hmm)) {
    cli::cli_abort("`hmm` must be `TRUE`, `FALSE`, or a custom HMM model file path.")
  }

  if (!rlang::is_integerish(topn, n = 1) || topn < 0) {
    cli::cli_abort("`topn` must be a non-negative integer.")
  }
  topn <- as.integer(topn)

  if (
    !rlang::is_integerish(min_keyword_length, n = 1) ||
      min_keyword_length < 1
  ) {
    cli::cli_abort("`min_keyword_length` must be a positive integer.")
  }
  min_keyword_length <- as.integer(min_keyword_length)

  idf_path <- ""
  if (!is.null(idf)) {
    if (!rlang::is_string(idf)) {
      cli::cli_abort("`idf` must be `NULL` or a path to an IDF dictionary file.")
    }
    if (!file.exists(idf)) {
      cli::cli_abort("`idf` must point to an existing IDF dictionary file.")
    }
    idf_path <- enc2utf8(idf)
  }

  dict_path <- ""
  if (!is.null(dict)) {
    if (!rlang::is_string(dict)) {
      cli::cli_abort("`dict` must be `NULL` or a path to a main dictionary file.")
    }
    if (!file.exists(dict)) {
      cli::cli_abort("`dict` must point to an existing main dictionary file.")
    }
    dict_path <- enc2utf8(dict)
  }

  user_paths <- character()
  if (!is.null(user)) {
    if (!rlang::is_character(user) || rlang::is_empty(user) || anyNA(user)) {
      cli::cli_abort(
        "`user` must be `NULL` or a non-empty character vector of user dictionary file paths."
      )
    }
    if (!all(file.exists(user))) {
      cli::cli_abort("Every path in `user` must point to an existing user dictionary file.")
    }
    user_paths <- enc2utf8(user)
  }

  if (!rlang::is_bool(symbol)) {
    cli::cli_abort("`symbol` must be `TRUE` or `FALSE`.")
  }

  if (!missing(bylines)) {
    cli::cli_warn(
      paste(
        "`bylines` is deprecated in `jiebaRS` and no longer has any effect.",
        "Control batch aggregation explicitly in specific functions."
      )
    )
  }

  classes <- c(
    switch(
      type,
      keywords = "jieba_keywords",
      textrank = "jieba_textrank",
      tag = "jieba_tagger",
      "jieba_segmenter"
    ),
    "jieba_worker"
  )

  structure(
    list(
      ptr = new_worker(
        type,
        hmm,
        hmm_model,
        idf_path,
        dict_path,
        user_paths,
        topn,
        min_keyword_length,
        stop_words
      ),
      type = type,
      config = list(
        hmm = hmm,
        hmm_model = if (nzchar(hmm_model)) hmm_model else NULL,
        topn = topn,
        min_keyword_length = min_keyword_length,
        idf = if (nzchar(idf_path)) idf_path else NULL,
        dict = if (nzchar(dict_path)) dict_path else NULL,
        user = if (length(user_paths)) user_paths else NULL,
        stop_word = stop_words,
        symbol = symbol,
        bylines = bylines
      )
    ),
    class = classes
  )
}
