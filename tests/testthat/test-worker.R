test_that("segment worker returns a S3 object", {
  engine1 <- worker()

  expect_s3_class(engine1, "jieba_segmenter")
  expect_s3_class(engine1, "jieba_worker")
  expect_identical(engine1$type, "mix")
  expect_identical(engine1$config$hmm, TRUE)
  expect_identical(engine1$config$topn, 5L)
  expect_identical(engine1$config$symbol, FALSE)
  expect_identical(engine1$config$bylines, FALSE)
})

test_that("full, query, mp, and hmm workers return segmenter objects", {
  full_worker <- worker(type = "full")
  query_worker <- worker(type = "query")

  mp_worker <- suppressWarnings(worker(type = "mp"))
  hmm_worker <- suppressWarnings(worker(type = "hmm"))

  expect_s3_class(full_worker, "jieba_segmenter")
  expect_s3_class(query_worker, "jieba_segmenter")
  expect_s3_class(mp_worker, "jieba_segmenter")
  expect_s3_class(hmm_worker, "jieba_segmenter")
  expect_identical(full_worker$type, "full")
  expect_identical(query_worker$type, "query")
  expect_identical(mp_worker$type, "mp")
  expect_identical(hmm_worker$type, "hmm")
})

test_that("tag worker returns a tagger object", {
  engine1 <- worker(type = "tag")

  expect_s3_class(engine1, "jieba_tagger")
  expect_s3_class(engine1, "jieba_worker")
  expect_identical(engine1$type, "tag")
  expect_identical(engine1$config$hmm, TRUE)
  expect_identical(engine1$config$topn, 5L)
  expect_identical(engine1$config$symbol, FALSE)
  expect_identical(engine1$config$bylines, FALSE)
})

test_that("keyword worker returns a S3 object", {
  engine1 <- worker(type = "keywords", topn = 3)

  expect_s3_class(engine1, "jieba_keywords")
  expect_s3_class(engine1, "jieba_worker")
  expect_identical(engine1$type, "keywords")
  expect_identical(engine1$config$hmm, TRUE)
  expect_identical(engine1$config$topn, 3L)
  expect_identical(engine1$config$idf, NULL)
  expect_identical(engine1$config$symbol, FALSE)
  expect_identical(engine1$config$bylines, FALSE)
})


test_that("TextRank worker returns a S3 object", {
  engine1 <- worker(type = "textrank", topn = 3)

  expect_s3_class(engine1, "jieba_textrank")
  expect_s3_class(engine1, "jieba_worker")
  expect_identical(engine1$type, "textrank")
  expect_identical(engine1$config$hmm, TRUE)
  expect_identical(engine1$config$topn, 3L)
  expect_identical(engine1$config$symbol, FALSE)
  expect_identical(engine1$config$bylines, FALSE)
})


test_that("user dictionary appends to the default dictionary", {
  user_file <- withr::local_tempfile()
  writeLines(c("量子机器狗 1000 n", "超导量子比特 1000"), user_file, useBytes = TRUE)

  default_engine <- worker()
  user_engine <- worker(user = user_file)

  # New user word is recognized as a single token.
  expect_identical(segment("量子机器狗", default_engine), c("量子", "机器", "狗"))
  expect_identical(segment("量子机器狗", user_engine), "量子机器狗")

  expect_identical(segment("超导量子比特", default_engine), c("超导", "量子", "比特"))
  expect_identical(segment("超导量子比特", user_engine), "超导量子比特")

  # Default dictionary words still work.
  expect_identical(segment("我们爱北京", default_engine), c("我们", "爱", "北京"))

  # Config records the path.
  expect_identical(user_engine$config$user, user_file)
  expect_null(worker()$config$user)
})

test_that("dictionary files handle a UTF-8 BOM and omitted frequencies", {
  user_file <- withr::local_tempfile()
  user_contents <- c(
    as.raw(c(0xef, 0xbb, 0xbf)),
    charToRaw("量子机器狗 n\n超导量子比特\n")
  )
  writeBin(user_contents, user_file)

  user_engine <- worker(user = user_file)
  tag_engine <- worker(type = "tag", user = user_file)

  expect_identical(segment("量子机器狗", user_engine), "量子机器狗")
  expect_identical(segment("超导量子比特", user_engine), "超导量子比特")
  expect_identical(tagging("量子机器狗", tag_engine), stats::setNames("n", "量子机器狗"))

  dict_file <- withr::local_tempfile()
  dict_contents <- c(
    as.raw(c(0xef, 0xbb, 0xbf)),
    charToRaw("量子机器狗\n")
  )
  writeBin(dict_contents, dict_file)

  dict_engine <- worker(dict = dict_file, hmm = FALSE)
  expect_identical(segment("量子机器狗", dict_engine), "量子机器狗")
})

test_that("dictionary files reject zero frequencies and invalid formats", {
  user_zero <- withr::local_tempfile(lines = "量子机器狗 0 n")
  dict_zero <- withr::local_tempfile(lines = "量子机器狗 0 n")
  user_bad_frequency <- withr::local_tempfile(lines = "量子机器狗 -1")
  user_too_many <- withr::local_tempfile(lines = "量子机器狗 1000 n extra")
  scrub_paths <- function(x) {
    x <- gsub(user_zero, "<user-zero>", x, fixed = TRUE)
    x <- gsub(dict_zero, "<dict-zero>", x, fixed = TRUE)
    x <- gsub(user_bad_frequency, "<user-bad-frequency>", x, fixed = TRUE)
    gsub(user_too_many, "<user-too-many>", x, fixed = TRUE)
  }

  expect_snapshot(worker(user = user_zero), error = TRUE, transform = scrub_paths)
  expect_snapshot(worker(dict = dict_zero), error = TRUE, transform = scrub_paths)
  expect_snapshot(worker(user = user_bad_frequency), error = TRUE, transform = scrub_paths)
  expect_snapshot(worker(user = user_too_many), error = TRUE, transform = scrub_paths)
})

test_that("multiple user dictionaries are loaded in order", {
  user_file1 <- withr::local_tempfile()
  user_file2 <- withr::local_tempfile()
  writeLines("量子机器狗 1000 n", user_file1, useBytes = TRUE)
  writeLines("超导量子比特 1000 n", user_file2, useBytes = TRUE)

  engine <- worker(user = c(user_file1, user_file2))

  expect_identical(segment("量子机器狗", engine), "量子机器狗")
  expect_identical(segment("超导量子比特", engine), "超导量子比特")
  expect_identical(engine$config$user, c(user_file1, user_file2))
})

test_that("dict dictionary replaces the default dictionary", {
  dict_file <- withr::local_tempfile()
  writeLines(c("我们 1000 r", "北京 1000 ns", "量子机器狗 1000 n"), dict_file, useBytes = TRUE)

  default_engine <- worker()
  dict_engine <- worker(dict = dict_file)

  # Custom dict words are recognized.
  expect_identical(segment("我们北京大学", default_engine), c("我们", "北京大学"))
  expect_identical(segment("我们北京大学", dict_engine), c("我们", "北京", "大学"))

  # Words NOT in the custom dict are cut to single characters.
  expect_identical(segment("你好", dict_engine), c("你", "好"))

  expect_identical(dict_engine$config$dict, dict_file)
  expect_null(worker()$config$dict)
})

test_that("dict and user can be combined", {
  dict_file <- withr::local_tempfile()
  writeLines(c("我们 1000 r"), dict_file, useBytes = TRUE)
  user_file <- withr::local_tempfile()
  writeLines(c("量子机器狗 1000 n"), user_file, useBytes = TRUE)

  engine <- worker(dict = dict_file, user = user_file)

  # dict word works.
  expect_identical(segment("我们", engine), "我们")
  # user word works.
  expect_identical(segment("量子机器狗", engine), "量子机器狗")
  # word not in either -> chars.
  expect_identical(segment("你好", engine), c("你", "好"))
})

test_that("worker snapshots invalid dict and user inputs", {
  expect_snapshot(
    worker(dict = 5),
    error = TRUE
  )

  expect_snapshot(
    worker(dict = "/nonexistent/dict.txt"),
    error = TRUE
  )

  expect_snapshot(
    worker(user = 5),
    error = TRUE
  )

  expect_snapshot(
    worker(user = "/nonexistent/user.txt"),
    error = TRUE
  )
})

test_that("worker snapshots invalid type input", {
  expect_snapshot(
    worker(type = "nope"),
    error = TRUE
  )
})

test_that("worker accepts a custom HMM model path", {
  hmm_file <- withr::local_tempfile()
  writeLines(
    c(
      "0 0 0 0",
      "0 0 0 0",
      "0 0 0 0",
      "0 0 0 0",
      "0 0 0 0",
      "你:0",
      "好:0",
      "世:0",
      "界:0"
    ),
    hmm_file,
    useBytes = TRUE
  )

  engine1 <- worker(hmm = hmm_file)

  expect_identical(engine1$config$hmm, TRUE)
  expect_identical(engine1$config$hmm_model, enc2utf8(hmm_file))
})

test_that("worker validates custom HMM model paths", {
  expect_snapshot(
    worker(hmm = "path/to/hmm_model.utf8"),
    error = TRUE
  )
})

test_that("worker warns once for approximate mp and hmm mappings", {
  withr::local_options(rlib_warning_verbosity = "verbose")

  expect_snapshot_warning(worker(type = "mp"))
  expect_snapshot_warning(worker(type = "hmm"))
})

test_that("worker warns when bylines is specified for compatibility", {
  withr::local_options(rlib_warning_verbosity = "verbose")

  expect_snapshot_warning(
    worker(bylines = TRUE)
  )
})
