## Source commit:
## https://github.com/Northriven/Stopwords/tree/0f77b15d8658cdb14cd12f0338af014c902c9d40

source_files <- c(
  stopwords_cn = file.path("data-raw", "stopwords", "stopwords_cn.txt"),
  stopwords_en = file.path("data-raw", "stopwords", "stopwords_en.txt"),
  stopwords_full = file.path("data-raw", "stopwords", "stopwords_full.txt")
)

read_stopwords <- function(path) {
  words <- readLines(path, encoding = "UTF-8", warn = FALSE)
  words <- sub("^\\ufeff", "", words)
  words <- trimws(words)
  stopifnot(
    length(words) > 0L,
    !anyNA(words),
    all(nzchar(words)),
    anyDuplicated(words) == 0L
  )
  enc2utf8(words)
}

dir.create("data", showWarnings = FALSE)

for (name in names(source_files)) {
  value <- read_stopwords(source_files[[name]])
  assign(name, value)
  save(
    list = name,
    file = file.path("data", paste0(name, ".rda")),
    version = 2,
    compress = "xz"
  )
}
