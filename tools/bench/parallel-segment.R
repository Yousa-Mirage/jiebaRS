args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)

if (length(file_arg) > 0L) {
  script_path <- normalizePath(sub("^--file=", "", file_arg[1L]))
  repo_root <- normalizePath(file.path(dirname(script_path), "..", ".."))
} else {
  # Fallback when running interactively or via source()
  ofile <- sys.frame(1)$ofile
  if (is.null(ofile)) {
    ofile <- "tools/bench/parallel-segment.R"
  }
  script_path <- normalizePath(ofile, mustWork = FALSE)
  repo_root <- normalizePath(file.path(dirname(script_path), "..", ".."))
}

datasets <- c(
  weicheng = file.path(repo_root, "examples", "weicheng", "weicheng.txt"),
  hongloumeng = file.path(repo_root, "examples", "hongloumeng", "hongloumeng.txt")
)

if (!requireNamespace("jiebaR", quietly = TRUE)) {
  stop("The `jiebaR` package is required to run this benchmark.", call. = FALSE)
}

install_release <- function(repo_root) {
  lib <- tempfile("jiebaRS-release-lib-")
  dir.create(lib, recursive = TRUE)
  install_args <- c("CMD", "INSTALL", "-l", shQuote(lib), shQuote(repo_root))
  status <- system2(
    file.path(R.home("bin"), "R"),
    install_args,
    env = c("DEBUG=", "NOT_CRAN="),
    stdout = "",
    stderr = ""
  )

  if (!identical(status, 0L)) {
    stop("Release installation of `jiebaRS` failed.", call. = FALSE)
  }

  lib
}

read_text <- function(path) {
  size <- file.info(path)$size
  con <- file(path, open = "rb")
  on.exit(close(con), add = TRUE)
  enc2utf8(readChar(con, nchars = size, useBytes = TRUE))
}

split_sentences <- function(text) {
  pieces <- unlist(strsplit(text, "[。！？；\n]+", perl = TRUE), use.names = FALSE)
  pieces <- trimws(pieces)
  pieces[nzchar(pieces)]
}

build_texts <- function(pieces, n_texts) {
  if (length(pieces) == 0L) {
    stop("No sentence-like pieces found in text.", call. = FALSE)
  }

  set.seed(42 + n_texts)
  sample(pieces, n_texts, replace = TRUE)
}

bench_once <- function(fun, input, reps) {
  invisible(fun(input))
  gc()
  unname(system.time(
    for (i in seq_len(reps)) {
      invisible(fun(input))
    }
  )[["elapsed"]]) /
    reps
}

token_count <- function(x) {
  if (is.list(x)) {
    return(sum(lengths(x)))
  }
  length(x)
}

run_case <- function(dataset, mode, input, reps) {
  rs_worker <- jiebaRS::worker(type = "mix")
  jr_worker <- jiebaR::worker(type = "mix")

  rs_fun <- function(x) jiebaRS::segment(x, rs_worker)

  jr_fun <- if (identical(mode, "whole")) {
    function(x) jiebaR::segment(x, jr_worker)
  } else {
    function(x) lapply(x, jiebaR::segment, jiebar = jr_worker)
  }

  rs_out <- rs_fun(input)
  jr_out <- jr_fun(input)

  data.frame(
    dataset = dataset,
    mode = mode,
    n_inputs = if (is.character(input) && length(input) == 1L) 1L else length(input),
    reps = reps,
    jiebaRS = bench_once(rs_fun, input, reps),
    jiebaR = bench_once(jr_fun, input, reps),
    jiebaRS_tokens = token_count(rs_out),
    jiebaR_tokens = token_count(jr_out),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

lib <- install_release(repo_root)
on.exit(unlink(lib, recursive = TRUE, force = TRUE), add = TRUE)

library("jiebaRS", lib.loc = lib, character.only = TRUE)
library(jiebaR)

cases <- list(
  list(mode = "whole", n = NULL, reps = 5L),
  list(mode = "split_1000", n = 1000L, reps = 5L),
  list(mode = "split_10000", n = 10000L, reps = 3L),
  list(mode = "split_100000", n = 100000L, reps = 1L)
)

results <- list()
idx <- 1L

# Pre-load and pre-process datasets
dataset_info <- list()
for (dataset in names(datasets)) {
  path <- datasets[[dataset]]
  text <- read_text(path)
  pieces <- split_sentences(text)
  dataset_info[[dataset]] <- list(
    path = path,
    text = text,
    pieces = pieces,
    chars = nchar(text, type = "chars"),
    n_sentences = length(pieces)
  )
}

for (dataset in names(datasets)) {
  info <- dataset_info[[dataset]]

  for (case in cases) {
    input <- if (identical(case$mode, "whole")) {
      info$text
    } else {
      build_texts(info$pieces, case$n)
    }

    results[[idx]] <- run_case(dataset, case$mode, input, case$reps)
    idx <- idx + 1L
  }
}

results <- do.call(rbind, results)
results$jiebaRS_vs_jiebaR <- results$jiebaR / results$jiebaRS

cat("parallel segment benchmark (release)\n")
cat(sprintf("repo_root: %s\n", repo_root))
for (dataset in names(datasets)) {
  info <- dataset_info[[dataset]]
  cat(sprintf(
    "%s: path=%s chars=%d sentences=%d\n",
    dataset,
    info$path,
    info$chars,
    info$n_sentences
  ))
}
cat("\n")
print(results, row.names = FALSE)
