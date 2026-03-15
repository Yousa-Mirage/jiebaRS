args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_arg))
repo_root <- normalizePath(file.path(dirname(script_path), "..", ".."))

if (!requireNamespace("pkgload", quietly = TRUE)) {
  stop("The `pkgload` package is required to run this benchmark.", call. = FALSE)
}

if (!requireNamespace("jiebaR", quietly = TRUE)) {
  stop("The `jiebaR` package is required to run this benchmark.", call. = FALSE)
}

pkgload::load_all(repo_root, quiet = TRUE)

rs_filter <- getExportedValue("jiebaRS", "filter_segment")
jr_filter <- getExportedValue("jiebaR", "filter_segment")

bench_once <- function(f, input, filter_words, reps) {
  invisible(f(input, filter_words))
  gc()
  unname(system.time(for (i in seq_len(reps)) invisible(f(input, filter_words)))[["elapsed"]]) / reps
}

config <- list(
  seed = 42L,
  vocab_size = 5000L,
  filter_size = 300L,
  vector_tokens = 100000L,
  list_docs = 100L,
  list_doc_tokens = 1000L,
  reps = 30L
)

set.seed(config$seed)
vocab <- sprintf("词%04d", seq_len(config$vocab_size))
filter_words <- sample(vocab, config$filter_size)
vec_input <- sample(vocab, config$vector_tokens, replace = TRUE)
list_input <- replicate(
  config$list_docs,
  sample(vocab, config$list_doc_tokens, replace = TRUE),
  simplify = FALSE
)

vec_rs <- rs_filter(vec_input, filter_words)
vec_jr <- jr_filter(vec_input, filter_words)
stopifnot(identical(vec_rs, vec_jr))

list_rs <- rs_filter(list_input, filter_words)
list_jr <- jr_filter(list_input, filter_words)
stopifnot(identical(list_rs, list_jr))

vec_rs_time <- bench_once(rs_filter, vec_input, filter_words, config$reps)
vec_jr_time <- bench_once(jr_filter, vec_input, filter_words, config$reps)
list_rs_time <- bench_once(rs_filter, list_input, filter_words, config$reps)
list_jr_time <- bench_once(jr_filter, list_input, filter_words, config$reps)

results <- data.frame(
  input = c("vector", "list"),
  jiebaRS = c(vec_rs_time, list_rs_time),
  jiebaR = c(vec_jr_time, list_jr_time),
  speedup = c(vec_jr_time / vec_rs_time, list_jr_time / list_rs_time),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

cat("filter_segment benchmark\n")
cat(sprintf("repo_root: %s\n", repo_root))
cat(sprintf(
  paste0(
    "seed=%d vocab_size=%d filter_size=%d vector_tokens=%d ",
    "list_docs=%d list_doc_tokens=%d reps=%d\n\n"
  ),
  config$seed,
  config$vocab_size,
  config$filter_size,
  config$vector_tokens,
  config$list_docs,
  config$list_doc_tokens,
  config$reps
))

print(results, row.names = FALSE)
