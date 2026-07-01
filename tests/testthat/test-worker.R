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
  expect_identical(engine1$config$symbol, FALSE)
  expect_identical(engine1$config$bylines, FALSE)
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
