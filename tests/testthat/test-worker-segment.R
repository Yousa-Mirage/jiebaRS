test_that("worker returns a simple S3 object", {
  engine1 <- worker()

  expect_s3_class(engine1, "jieba_segmenter")
  expect_s3_class(engine1, "jieba_worker")
  expect_identical(engine1$type, "mix")
  expect_identical(engine1$config$hmm, TRUE)
})

test_that("segment tokenizes a simple sentence", {
  engine1 <- worker()

  expect_identical(
    segment("南京市长江大桥", engine1),
    c("南京市", "长江大桥")
  )
})
