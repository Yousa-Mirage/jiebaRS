#' Built-in stopword lists
#'
#' Three UTF-8 character vectors of stopwords bundled with `jiebaRS`. They are
#' provided for explicit use with the `stop_word` argument; none is enabled by
#' default.
#'
#' @format Three character vectors:
#' \describe{
#'   \item{stopwords_cn}{A compiled Chinese stopword list. The upstream list
#'     also contains some punctuation, numbers, and English entries.}
#'   \item{stopwords_en}{A commonly used English stopword list.}
#'   \item{stopwords_full}{A combined Chinese and English stopword list.}
#' }
#'
#' @usage data(stopwords_cn)
#' @usage data(stopwords_en)
#' @usage data(stopwords_full)
#'
#' @source The source files were downloaded from commit
#'   `0f77b15` of
#'   \url{https://github.com/Northriven/Stopwords} on 2026-08-05:
#'   - \url{https://github.com/Northriven/Stopwords/blob/0f77b15d8658cdb14cd12f0338af014c902c9d40/stopwords_cn.txt}
#'   - \url{https://github.com/Northriven/Stopwords/blob/0f77b15d8658cdb14cd12f0338af014c902c9d40/stopwords_english.txt}
#'   - \url{https://github.com/Northriven/Stopwords/blob/0f77b15d8658cdb14cd12f0338af014c902c9d40/stopwords_full.txt}
#'
#' @examples
#' cutter <- worker(stop_word = stopwords_cn)
#' segment("\u8fd9\u662f\u4e00\u4e2a\u6d4b\u8bd5", cutter)
#'
#' @name stopwords
#' @aliases stopwords_cn stopwords_en stopwords_full
#' @docType data
NULL
