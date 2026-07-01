#' Generate IDF dict
#'
#' Generate IDF dict from a list of documents.
#'
#' @details
#' Input list contains multiple character vectors with words,
#' and each vector represents a document.
#'
#' Stop words will be removed from the result.
#'
#' If path is not NULL, it will write the result to the path.
#'
#' @param x a list of character vectors. Each vector represents a document of
#'   already-segmented words.
#' @param stop_word Optional character vector of stop words supplied directly.
#' @param stop_word_file Optional file path containing one stop word per line.
#' @param path Optional output file path. When `NULL`, a data frame is returned.
#'   Otherwise, the result is written to the file as `word idf_value` per line
#'   (the format expected by `worker(type = "keywords", idf = ...)`) and the
#'   path is returned invisibly.
#'
#' @return A data frame with `name` and `count` columns, or a file path
#'   (invisibly) when `path` is supplied.
#'
#' @examples
#' get_idf(list(c("abc", "def"),c("abc", " ")))
#' @export
get_idf <- function(x, stop_word = NULL, stop_word_file = NULL, path = NULL) {
  if (!rlang::is_list(x)) {
    cli::cli_abort("`x` must be a list of character vectors.")
  }

  if (!is.null(path) && !rlang::is_string(path)) {
    cli::cli_abort("`path` must be `NULL` or a single file path string.")
  }

  n_docs <- length(x)
  if (n_docs == 0L) {
    cli::cli_abort("`x` must contain at least one document.")
  }

  # Validate that every element is a character vector and strip non-words
  # (NA / empty string) up front so they never enter the document-frequency
  # count. UTF-8 normalize for a consistent vocabulary.
  all_words <- character()
  for (i in seq_len(n_docs)) {
    doc <- x[[i]]
    if (!rlang::is_character(doc)) {
      cli::cli_abort("Every element of `x` must be a character vector.")
    }
    doc <- enc2utf8(doc)
    doc <- doc[!is.na(doc) & nzchar(doc)]
    if (length(doc)) {
      all_words <- c(all_words, unique(doc))
    }
  }

  if (length(all_words) == 0L) {
    result <- data.frame(name = character(), count = double())
  } else {
    # Count document frequency per word via match + tabulate.
    uwords <- unique(all_words)
    df_counts <- tabulate(match(all_words, uwords), nbins = length(uwords))

    # idf = log(N / df)
    idf <- log(n_docs / df_counts)

    result <- data.frame(
      name = uwords,
      count = idf,
      stringsAsFactors = FALSE
    )
  }

  # Remove stop words from the result.
  stop_words <- normalize_stop_words(stop_word, stop_word_file)
  if (length(stop_words) && nrow(result)) {
    keep <- !result$name %in% stop_words
    result <- result[keep, , drop = FALSE]
  }

  if (is.null(path)) {
    return(result)
  }

  if (!nzchar(path)) {
    cli::cli_abort("`path` must not be an empty string.")
  }

  write.table(
    result,
    file = path,
    sep = " ",
    row.names = FALSE,
    col.names = FALSE,
    quote = FALSE
  )

  invisible(path)
}
