# TODO: 补充错误测试

test_that("new_user_word updates worker segmentation for a single word", {
  engine1 <- worker()

  expect_equal(segment("量子机器狗", engine1), c("量子", "机器", "狗"))
  expect_no_error(new_user_word(engine1, "量子机器狗", "n"))
  expect_equal(segment("量子机器狗", engine1), "量子机器狗")
})

test_that("new_user_word accepts multiple words", {
  engine1 <- worker()

  expect_equal(segment("超导量子比特", engine1), c("超导", "量子", "比特"))
  expect_equal(segment("量子机器狗", engine1), c("量子", "机器", "狗"))

  expect_no_error(new_user_word(engine1, c("超导量子比特", "量子机器狗"), "n"))

  expect_equal(segment("超导量子比特", engine1), "超导量子比特")
  expect_equal(segment("量子机器狗", engine1), "量子机器狗")
})
