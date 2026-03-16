test_that("tagging supports vector, data frame and legacy formats", {
  engine1 <- worker(type = "tag")

  expect_identical(
    tagging("这是一个测试", engine1),
    stats::setNames(c("x", "m", "vn"), c("这是", "一个", "测试"))
  )

  expect_identical(
    tagging("这是一个测试", engine1, format = "data.frame"),
    data.frame(
      term = c("这是", "一个", "测试"),
      tag = c("x", "m", "vn")
    )
  )

  expect_identical(
    tagging("这是一个测试", engine1, format = "legacy"),
    stats::setNames(c("这是", "一个", "测试"), c("x", "m", "vn"))
  )
})

test_that("tagging supports vector input with batch aggregation", {
  engine1 <- worker(type = "tag")
  input <- c("这是一个测试", "再来一次")

  expect_identical(
    tagging(input, engine1),
    list(
      stats::setNames(c("x", "m", "vn"), c("这是", "一个", "测试")),
      stats::setNames(c("d", "v", "m"), c("再", "来", "一次"))
    )
  )

  expect_identical(
    tagging(input, engine1, batch = "flatten"),
    stats::setNames(c("x", "m", "vn", "d", "v", "m"), c("这是", "一个", "测试", "再", "来", "一次"))
  )

  expect_identical(
    tagging(input, engine1, format = "legacy", batch = "flatten"),
    stats::setNames(c("这是", "一个", "测试", "再", "来", "一次"), c("x", "m", "vn", "d", "v", "m"))
  )

  expect_identical(
    tagging(input, engine1, format = "data.frame", batch = "data.frame"),
    data.frame(
      doc_id = c(1L, 1L, 1L, 2L, 2L, 2L),
      term = c("这是", "一个", "测试", "再", "来", "一次"),
      tag = c("x", "m", "vn", "d", "v", "m")
    )
  )
})

test_that("tagging ignores bylines and still defaults to list for vectors", {
  tagger1 <- suppressWarnings(worker(type = "tag", bylines = TRUE))
  tagger2 <- suppressWarnings(worker(type = "tag", bylines = FALSE))
  input <- c("这是一个测试", "再来一次")

  expected <- list(
    stats::setNames(c("x", "m", "vn"), c("这是", "一个", "测试")),
    stats::setNames(c("d", "v", "m"), c("再", "来", "一次"))
  )

  expect_identical(tagging(input, tagger1), expected)
  expect_identical(tagging(input, tagger2), expected)
})

test_that("tagging matches jiebaR on representative single-string inputs", {
  skip_if_not_installed("jiebaR")

  texts <- c(
    "这是一个测试",
    "this is test",
    "123 abc 你好",
    "小明硕士毕业于中国科学院计算所"
  )

  jiebaRS_worker <- worker(type = "tag")
  jiebaR_worker <- jiebaR::worker(type = "tag")

  for (text in texts) {
    expect_identical(
      tagging(text, jiebaRS_worker, format = "legacy"),
      jiebaR::tagging(text, jiebaR_worker)
    )
  }
})

test_that("tagging rejects incompatible multi-string combinations", {
  tagger <- worker(type = "tag")
  input <- c("这是一个测试", "再来一次")

  expect_snapshot(
    tagging(input, tagger, format = "vector", batch = "data.frame"),
    error = TRUE
  )
  expect_snapshot(
    tagging(input, tagger, format = "legacy", batch = "data.frame"),
    error = TRUE
  )
  expect_snapshot(
    tagging(input, tagger, format = "data.frame", batch = "flatten"),
    error = TRUE
  )
})

test_that("tagging snapshots invalid inputs", {
  segmenter <- worker()
  tagger <- worker(type = "tag")

  expect_snapshot(tagging("测试", segmenter), error = TRUE)
  expect_snapshot(tagging(NA_character_, tagger), error = TRUE)
  expect_snapshot(tagging("测试", tagger, format = "bad"), error = TRUE)
  expect_snapshot(tagging_batch("测试", tagger, batch = "bad"), error = TRUE)
})

test_that("tagging_batch defaults to list output and ignores bylines", {
  tagger <- suppressWarnings(worker(type = "tag", bylines = FALSE))
  input <- c("这是一个测试", "再来一次")

  expect_identical(
    tagging_batch(input, tagger),
    list(
      stats::setNames(c("x", "m", "vn"), c("这是", "一个", "测试")),
      stats::setNames(c("d", "v", "m"), c("再", "来", "一次"))
    )
  )
})

test_that("tagging_batch forwards explicit formats", {
  tagger <- worker(type = "tag")
  input <- c("这是一个测试", "再来一次")

  expect_identical(
    tagging_batch(input, tagger, batch = "flatten"),
    stats::setNames(c("x", "m", "vn", "d", "v", "m"), c("这是", "一个", "测试", "再", "来", "一次"))
  )

  expect_identical(
    tagging_batch(input, tagger, format = "legacy", batch = "flatten"),
    stats::setNames(c("这是", "一个", "测试", "再", "来", "一次"), c("x", "m", "vn", "d", "v", "m"))
  )

  expect_identical(
    tagging_batch(input, tagger, format = "data.frame", batch = "data.frame"),
    data.frame(
      doc_id = c(1L, 1L, 1L, 2L, 2L, 2L),
      term = c("这是", "一个", "测试", "再", "来", "一次"),
      tag = c("x", "m", "vn", "d", "v", "m")
    )
  )
})
