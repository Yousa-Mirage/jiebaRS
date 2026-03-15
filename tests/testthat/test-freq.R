test_that("freq counts words in first-appearance order", {
  input <- c("b", "a", "b", "c", "a")
  res <- data.frame(
    char = c("b", "a", "c"),
    freq = c(2L, 2L, 1L)
  )

  expect_identical(freq(input), res)
})

test_that("freq can sort by descending frequency", {
  input <- c("b", "a", "b", "c", "a", "a")
  res <- data.frame(
    char = c("a", "b", "c"),
    freq = c(3L, 2L, 1L)
  )

  expect_identical(freq(input, sort = TRUE), res)
})

test_that("freq keeps stable order for ties when sorting", {
  input <- c("b", "a", "b", "a", "c")
  res <- data.frame(
    char = c("b", "a", "c"),
    freq = c(2L, 2L, 1L)
  )

  expect_identical(freq(input, sort = TRUE), res)
})

test_that("freq requires a character vector", {
  expect_snapshot(
    freq(1:5),
    error = TRUE
  )
})

test_that("freq validates sort", {
  expect_snapshot(
    freq(c("a", "b"), sort = NA),
    error = TRUE
  )
})
