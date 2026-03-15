test_that("freq counts words in first-appearance order", {
  input <- c("b", "a", "b", "c", "a")
  res <- data.frame(
    char = c("b", "a", "c"),
    freq = c(2L, 2L, 1L)
  )

  expect_identical(freq(input), res)
})

test_that("freq requires a character vector", {
  expect_snapshot(
    freq(1:5),
    error = TRUE
  )
})
