.validate_ngrams_input <- function(x) {
  if (rlang::is_character(x)) {
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
  if (!rlang::is_integerish(n, finite = TRUE) || rlang::is_empty(n)) {
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
      count = counts
    )
  }

  if (all(vapply(results, is.null, logical(1)))) {
    return(data.frame(
      term = character(),
      n = integer(),
      count = integer()
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
#' @details
#' Use `n` to select one or more n-gram sizes, and `sep` to control how tokens
#' are joined in the returned term labels.
#'
#' @param x A character vector of tokens or a list of character vectors.
#' @param ... Must be empty. This enforces that optional arguments such as `n`,
#'   `sep`, `sort`, and `format` are supplied with explicit names.
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
#' @examples
#' count_ngrams(c("\u6211", "\u7231", "R"), n = 2)
#' count_ngrams(c("\u6211", "\u7231", "R"), n = 1:2, format = "data.frame")
#' count_ngrams(c("a", "b", "b", "b", "a"), n = 1, sort = FALSE)
#' count_ngrams(list(c("a", "b", "c"), c("a", "b")), n = 2)
#' @export
count_ngrams <- function(
  x,
  ...,
  n = 2,
  sep = " ",
  sort = TRUE,
  format = c("data.frame", "vector")
) {
  rlang::check_dots_empty()

  if (!rlang::is_bool(sort)) {
    cli::cli_abort("`sort` must be a single `TRUE` or `FALSE` value.")
  }
  sep <- as.character(sep)
  format <- rlang::arg_match(format)

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
