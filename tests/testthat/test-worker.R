test_that("segment worker returns a S3 object", {
  engine1 <- worker()

  expect_s3_class(engine1, "jieba_segmenter")
  expect_s3_class(engine1, "jieba_worker")
  expect_equal(engine1$type, "mix")
  expect_equal(engine1$config$hmm, TRUE)
  expect_equal(engine1$config$topn, 5L)
  expect_equal(engine1$config$symbol, FALSE)
})

test_that("keyword worker returns a S3 object", {
  engine1 <- worker(type = "keywords", topn = 3)

  expect_s3_class(engine1, "jieba_keywords")
  expect_s3_class(engine1, "jieba_worker")
  expect_equal(engine1$type, "keywords")
  expect_equal(engine1$config$hmm, TRUE)
  expect_equal(engine1$config$topn, 3L)
  expect_equal(engine1$config$symbol, FALSE)
})

test_that("worker snapshots invalid type input", {
  expect_snapshot(
    worker(type = "nope"),
    error = TRUE
  )
})
