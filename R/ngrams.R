# TODO: Implement n-gram counting in Rust to improve performance.

.validate_ngrams_input <- function(x) {
  if (is.character(x)) {
    return(list(enc2utf8(x)))
  }

  if (is.list(x) && all(vapply(x, is.character, logical(1)))) {
    return(lapply(x, enc2utf8))
  }

  cli::cli_abort(
    "`x` must be a character vector or a list of character vectors."
  )
}

.validate_ngrams_n <- function(n) {
  if (!is.numeric(n) || length(n) < 1L || anyNA(n)) {
    cli::cli_abort("`n` must be a non-empty integer vector.")
  }

  n_int <- as.integer(n)
  if (any(n_int < 1L) || any(n != n_int)) {
    cli::cli_abort("`n` must contain positive integers only.")
  }

  unique(n_int)
}

.make_ngrams_one <- function(x, n, sep) {
  len <- length(x)

  if (len < n) {
    return(character())
  }

  if (n == 1L) {
    return(x)
  }

  args <- lapply(seq_len(n), function(i) x[i:(len - n + i)])
  args$sep <- sep
  do.call(paste, args)
}

.count_ngrams_df <- function(x, n, sep) {
  docs <- .validate_ngrams_input(x)
  n_values <- .validate_ngrams_n(n)

  results <- vector("list", length(n_values))

  for (i in seq_along(n_values)) {
    n_i <- n_values[[i]]
    terms_i <- unlist(
      lapply(docs, .make_ngrams_one, n = n_i, sep = sep),
      use.names = FALSE
    )

    if (length(terms_i) == 0L) {
      next
    }

    uniq_terms <- unique(terms_i)
    counts <- tabulate(match(terms_i, uniq_terms), nbins = length(uniq_terms))

    results[[i]] <- data.frame(
      term = uniq_terms,
      n = rep.int(n_i, length(uniq_terms)),
      count = counts,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  }

  if (all(vapply(results, is.null, logical(1)))) {
    return(data.frame(
      term = character(),
      n = integer(),
      count = integer(),
      stringsAsFactors = FALSE,
      check.names = FALSE
    ))
  }

  do.call(rbind, results)
}

#' Count n-grams from segmented text
#'
#' @description
#' Count contiguous n-grams from a segmented character vector or from each
#' element of a list of segmented character vectors.
#'
#' This function is a drop-in replacement for `jiebaR::get_tuple()`, which
#' is deprecated in `jiebaRS`. See Details for more information.
#'
#' @details
#' The original `jiebaR::get_tuple()` interface has several design problems:
#'
#' 1. Its n-gram extraction behavior does not match the most obvious reading of
#'    the argument name: `size = n` counts all contiguous n-grams from `2:n`,
#'    not just the exact size `n`.
#' 2. Its documentation says it accepts list input, but the original exported
#'    implementation does not reliably support lists.
#' 3. It concatenates tokens without a separator, which makes tuple boundaries
#'    ambiguous.
#'
#' `count_ngrams()` addresses these issues, providing more explicit and
#' abundant parameters. In addition, this function is about **1.3x** to
#' **2.0x** faster than `jiebaR::get_tuple()`.
#'
#' @param x A character vector of tokens or a list of character vectors.
#' @param n A positive integer or integer vector giving the n-gram sizes to
#'   count. The default is `2`. If `n` is a integer vector of length > 1,
#'   n-grams of all specified sizes will be counted.
#' @param sep Separator inserted between tokens when constructing the n-gram
#'   label. The default is `" "`, a single space.
#' @param sort Whether to sort results by descending frequency. The default
#'   is `TRUE`. If `FALSE`, results keep first-appearance order within each
#'   requested n.
#' @param format Output format. `"data.frame"` returns a data frame with
#'   `term`, `n`, and `count` columns. `"vector"` returns a named integer
#'   vector using the n-gram terms as names.
#'
#' @return N-gram counts in the requested format.
#' @seealso [get_tuple()]
#' @examples
#' count_ngrams(c("我", "爱", "R"), n = 2)
#' count_ngrams(c("我", "爱", "R"), n = 1:2, format = "data.frame")
#' count_ngrams(c("a", "b", "b", "b", "a"), n = 1, sort = FALSE)
#' count_ngrams(list(c("a", "b", "c"), c("a", "b")), n = 2)
#' @export
count_ngrams <- function(
  x,
  n = 2,
  sep = " ",
  sort = TRUE,
  format = c("data.frame", "vector")
) {
  if (!is.logical(sort) || length(sort) != 1L || is.na(sort)) {
    cli::cli_abort("`sort` must be a single `TRUE` or `FALSE` value.")
  }
  sep <- as.character(sep)
  format <- match.arg(format)

  res <- .count_ngrams_df(x, n = n, sep = sep)

  if (isTRUE(sort) && nrow(res) > 1L) {
    ord <- order(res$count, decreasing = TRUE, method = "radix")
    res <- res[ord, , drop = FALSE]
    rownames(res) <- NULL
  }

  switch(
    format,
    "data.frame" = res,
    "vector" = stats::setNames(res$count, res$term)
  )
}

#' Compatibility wrapper for `jiebaR::get_tuple()`
#'
#' `get_tuple()` is kept only for compatibility with `jiebaR`. New code should
#' use [count_ngrams()] instead.
#'
#' @details
#' This function is deprecated and should not be used in new code.
#' It is provided only as a compatibility wrapper around [count_ngrams()]
#' and replicates the behavior of `jiebaR::get_tuple()`.
#'
#' Prefer [count_ngrams()] because the original `jiebaR::get_tuple()` interface
#' has several design problems:
#'
#' 1. Its n-gram extraction behavior does not match the most obvious reading of
#'    the argument name: `size = n` counts all contiguous n-grams from `2:n`,
#'    not just the exact size `n`.
#' 2. Its documentation says it accepts list input, but the original exported
#'    implementation does not reliably support lists.
#' 3. It concatenates tokens without a separator, which makes tuple boundaries
#'    ambiguous.
#'
#' @param x A character vector of tokens or a list of character vectors.
#' @param size A single integer >= 2. The compatibility semantics count all
#'   contiguous n-grams from 2 up to `size`.
#' @param dataframe Whether to return a data frame. If `FALSE`, a named integer
#'   vector is returned.
#'
#' @return If `dataframe = TRUE`, a data frame with `name` and `count` columns,
#'   sorted by descending count. Otherwise, a named integer vector.
#' @seealso [count_ngrams()]
#' @examples
#' suppressWarnings(get_tuple(c("sd", "sd", "sd", "rd"), 2))
#' @export
get_tuple <- function(x, size = 2, dataframe = TRUE) {
  .Deprecated(
    "count_ngrams",
    package = "jiebaRS",
    msg = paste(
      "`get_tuple()` is deprecated; use `count_ngrams()` instead.",
      "The legacy jiebaR API mixes 2:n grams into `size`, does not reliably",
      "support list inputs, and cannot represent tuple boundaries because it",
      "concatenates tokens without a separator."
    )
  )

  if (!is.numeric(size) || length(size) != 1L || is.na(size)) {
    cli::cli_abort("`size` must be a single integer >= 2.")
  }

  size_int <- as.integer(size)
  if (size_int < 2L || size != size_int) {
    cli::cli_abort("`size` must be a single integer >= 2.")
  }

  if (!is.logical(dataframe) || length(dataframe) != 1L || is.na(dataframe)) {
    cli::cli_abort("`dataframe` must be a single `TRUE` or `FALSE` value.")
  }

  res <- count_ngrams(x, n = 2:size_int, sep = "", sort = FALSE, format = "data.frame")

  if (nrow(res) == 0L) {
    if (isTRUE(dataframe)) {
      return(data.frame(
        name = character(),
        count = integer(),
        stringsAsFactors = FALSE,
        check.names = FALSE
      ))
    }
    return(stats::setNames(integer(), character()))
  }

  agg <- rowsum(res$count, res$term, reorder = FALSE)
  counts <- as.integer(agg[, 1L])
  terms <- rownames(agg)

  ord <- order(counts, decreasing = TRUE)
  terms <- terms[ord]
  counts <- counts[ord]

  if (isFALSE(dataframe)) {
    return(stats::setNames(counts, terms))
  }

  data.frame(
    name = terms,
    count = counts,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}
