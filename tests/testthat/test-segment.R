test_that("segment tokenizes a simple sentence", {
  engine1 <- worker()

  expect_identical(
    segment("南京市长江大桥", engine1),
    c("南京市", "长江大桥")
  )
})
