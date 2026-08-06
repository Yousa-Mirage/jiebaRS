.cidian_formats <- c("scel", "qcel", "qpyd", "bdict", "bcd")

.check_cidian_path <- function(path) {
  if (!rlang::is_string(path) || is.na(path) || !nzchar(path)) {
    cli::cli_abort(
      "`path` must be a non-empty file path string.",
      call = rlang::caller_call()
    )
  }

  path <- enc2utf8(path)
  if (!file.exists(path)) {
    cli::cli_abort(
      "`path` must point to an existing input-method dictionary file.",
      call = rlang::caller_call()
    )
  }

  format <- tolower(tools::file_ext(path))
  if (!format %in% .cidian_formats) {
    supported_extensions <- paste0(
      "{.code .",
      .cidian_formats,
      "}",
      collapse = ", "
    )
    cli::cli_abort(
      c(
        "Unsupported input-method dictionary extension in {.path {path}}.",
        "i" = paste0("Supported extensions are ", supported_extensions, ".")
      ),
      call = rlang::caller_call()
    )
  }

  list(path = path, format = format)
}

#' Import an input-method dictionary into a worker
#'
#' Parse a supported Chinese input-method dictionary with the Rust `cidian`
#' parser and add all parsed words to an existing `jieba_worker`. The file
#' extension selects the parser automatically. Supported formats are `.scel`,
#' `.qcel`, `.qpyd`, `.bdict`, and `.bcd`.
#'
#' The source dictionary's coding and weight fields are ignored. Imported words
#' are added without an explicit frequency, so `jieba-rs` infers each
#' frequency from the current dictionary. The same `tag` is assigned to every
#' imported word. By default, imported words have no tag (`tag = NULL`).
#'
#' @param worker A `jieba_worker` object to update in place.
#' @param path A path to a supported input-method dictionary file.
#' @param tag An optional single non-empty character string assigned to every
#'   imported word. `NULL` leaves the tag empty.
#'
#' @return `NULL`, invisibly. The supplied `worker` is modified in place.
#' @examples
#' \dontrun{
#' cutter <- worker()
#' import_cidian(cutter, "dictionary.scel")
#' segment("词库中的词语", cutter)
#' }
#' @export
import_cidian <- function(worker, path, tag = NULL) {
  if (!inherits(worker, "jieba_worker")) {
    cli::cli_abort("`worker` must be a `jieba_worker` object.")
  }
  if (!is.null(tag) && (!rlang::is_string(tag) || is.na(tag) || !nzchar(tag))) {
    cli::cli_abort("`tag` must be a single non-empty character string.")
  }

  dictionary <- .check_cidian_path(path)
  if (!is.null(tag)) {
    tag <- enc2utf8(tag)
  }
  import_cidian_worker(worker$ptr, dictionary$path, dictionary$format, tag)
  invisible(NULL)
}

#' Read an input-method dictionary as a data frame
#'
#' Parse a supported input-method dictionary with the Rust `cidian` parser and
#' return its entries and source coding components. The file extension selects
#' the parser automatically. Supported formats are `.scel`, `.qcel`, `.qpyd`,
#' `.bdict`, and `.bcd`.
#'
#' @param path A path to a supported input-method dictionary file.
#'
#' @return A data frame with `entry` and `code` character columns. Multiple
#'   coding components are joined with a single space.
#' @examples
#' \dontrun{
#' read_cidian("dictionary.scel")
#' }
#' @export
read_cidian <- function(path) {
  dictionary <- .check_cidian_path(path)
  result <- read_cidian_worker(dictionary$path, dictionary$format)
  data.frame(
    entry = result$entry,
    code = result$code,
    stringsAsFactors = FALSE
  )
}
