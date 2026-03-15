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
      tag = c("x", "m", "vn"),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  )

  expect_identical(
    tagging("这是一个测试", engine1, format = "legacy"),
    stats::setNames(c("这是", "一个", "测试"), c("x", "m", "vn"))
  )
})

test_that("tagging_df is a convenience wrapper", {
  engine1 <- worker(type = "tag")

  expect_identical(
    tagging_df("123 abc 你好", engine1),
    tagging("123 abc 你好", engine1, format = "data.frame")
  )
})

test_that("tagging matches jiebaR on representative inputs", {
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

test_that("tagging snapshots invalid inputs", {
  segmenter <- worker()
  tagger <- worker(type = "tag")

  expect_snapshot(tagging("测试", segmenter), error = TRUE)
  expect_snapshot(tagging(NA_character_, tagger), error = TRUE)
  expect_snapshot(tagging("测试", tagger, format = "bad"), error = TRUE)
})
