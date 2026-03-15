test_that("segment tokenizes a simple sentence", {
  engine1 <- worker()

  expect_identical(
    segment("南京市长江大桥", engine1),
    c("南京市", "长江大桥")
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

test_that("mix matches jiebaR on representative text", {
  skip_if_not_installed("jiebaR")

  text <- "南京市长江大桥"
  jiebaRS_res <- segment(text, worker(type = "mix"))
  jiebaR_res <- jiebaR::segment(text, jiebaR::worker(type = "mix"))

  expect_identical(jiebaRS_res, jiebaR_res)
})
