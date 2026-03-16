test_that("segment tokenizes a simple sentence", {
  engine1 <- worker()

  expect_identical(
    segment("南京市长江大桥", engine1),
    c("南京市", "长江大桥")
  )

  expect_identical(
    segment("南京市长江大桥", engine1, batch = "list"),
    c("南京市", "长江大桥")
  )
})

test_that("segment warns and ignores deprecated mod", {
  engine1 <- worker()

  expect_snapshot_warning(
    segment("南京市长江大桥", engine1, mod = "full")
  )
})

test_that("full worker enumerates all possible words", {
  engine1 <- worker(type = "full")

  expect_identical(
    segment("南京市长江大桥", engine1),
    c("南", "南京", "南京市", "京", "京市", "市", "市长", "长", "长江", "长江大桥", "江", "大", "大桥", "桥")
  )
})

test_that("query worker uses search mode segmentation", {
  engine1 <- worker(type = "query")

  expect_identical(
    segment("南京市长江大桥", engine1),
    c("南京", "京市", "南京市", "长江", "大桥", "长江大桥")
  )
})

test_that("mp and hmm workers follow documented mix mappings", {
  text <- "南京市长江大桥"

  mp_worker <- suppressWarnings(worker(type = "mp"))
  hmm_worker <- suppressWarnings(worker(type = "hmm"))

  expect_identical(
    segment(text, mp_worker),
    segment(text, worker(type = "mix", hmm = FALSE))
  )
  expect_identical(
    segment(text, hmm_worker),
    segment(text, worker(type = "mix", hmm = TRUE))
  )
})

test_that("mix matches jiebaR on representative text", {
  skip_if_not_installed("jiebaR")

  text <- "南京市长江大桥"
  jiebaRS_res <- segment(text, worker(type = "mix"))
  jiebaR_res <- jiebaR::segment(text, jiebaR::worker(type = "mix"))

  expect_identical(jiebaRS_res, jiebaR_res)
})

test_that("segment supports vector input with explicit batch aggregation", {
  engine1 <- worker()
  input <- c("南京市长江大桥", "这是一个测试")

  expect_identical(
    segment(input, engine1),
    list(
      c("南京市", "长江大桥"),
      c("这是", "一个", "测试")
    )
  )

  expect_identical(
    segment(input, engine1, batch = "list"),
    list(
      c("南京市", "长江大桥"),
      c("这是", "一个", "测试")
    )
  )

  expect_identical(
    segment(input, engine1, batch = "flatten"),
    c("南京市", "长江大桥", "这是", "一个", "测试")
  )

  expect_identical(
    segment(input, engine1, batch = "data.frame"),
    data.frame(
      doc_id = c(1L, 1L, 2L, 2L, 2L),
      word = c("南京市", "长江大桥", "这是", "一个", "测试")
    )
  )
})

test_that("segment ignores bylines and still defaults to list for vectors", {
  engine1 <- suppressWarnings(worker(bylines = TRUE))
  engine2 <- suppressWarnings(worker(bylines = FALSE))
  input <- c("南京市长江大桥", "这是一个测试")

  expect_identical(
    segment(input, engine1),
    list(
      c("南京市", "长江大桥"),
      c("这是", "一个", "测试")
    )
  )

  expect_identical(
    segment(input, engine2),
    list(
      c("南京市", "长江大桥"),
      c("这是", "一个", "测试")
    )
  )
})

test_that("segment handles empty input for each format", {
  engine1 <- worker()

  expect_snapshot(segment(character(0), engine1), error = TRUE)
})

test_that("segment_batch defaults to list output and ignores bylines", {
  engine1 <- suppressWarnings(worker(bylines = FALSE))
  input <- c("南京市长江大桥", "这是一个测试")

  expect_identical(
    segment_batch(input, engine1),
    list(
      c("南京市", "长江大桥"),
      c("这是", "一个", "测试")
    )
  )
})

test_that("segment_batch forwards explicit formats", {
  engine1 <- worker()
  input <- c("南京市长江大桥", "这是一个测试")

  expect_identical(
    segment_batch(input, engine1, batch = "flatten"),
    c("南京市", "长江大桥", "这是", "一个", "测试")
  )

  expect_identical(
    segment_batch(input, engine1, batch = "data.frame"),
    data.frame(
      doc_id = c(1L, 1L, 2L, 2L, 2L),
      word = c("南京市", "长江大桥", "这是", "一个", "测试")
    )
  )
})
