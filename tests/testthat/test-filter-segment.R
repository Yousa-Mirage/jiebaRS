test_that("filter_segment removes words from a character vector", {
  input <- c("我", "是", "测试", "文本", "我")

  expect_identical(
    filter_segment(input, c("我", "你")),
    c("是", "测试", "文本")
  )
})

test_that("filter_segment removes words from each list element", {
  input <- list(
    c("我", "是", "测试", "文本"),
    c("测试", "文本", "我", "你")
  )

  expect_identical(
    filter_segment(input, c("我", "你")),
    list(
      c("是", "测试", "文本"),
      c("测试", "文本")
    )
  )
})

test_that("filter_segment ignores missing values in filter words", {
  input <- c("a", NA, "b", "a")

  expect_identical(
    filter_segment(input, c(NA, "b")),
    c("a", NA, "a")
  )
})

test_that("filter_segment can drop missing values from the result", {
  input <- c("a", NA, "b", "a")

  expect_identical(
    filter_segment(input, c(NA, "b"), keep_na = FALSE),
    c("a", "a")
  )
})

test_that("filter_segment returns input unchanged when filter_words is empty", {
  input <- list(c("a", "b"), c("c"))

  expect_identical(filter_segment(input, character()), input)
})

test_that("filter_segment snapshots invalid inputs", {
  expect_snapshot(
    filter_segment(1:3, "a"),
    error = TRUE
  )
  expect_snapshot(
    filter_segment(list(c("a"), 1:3), "a"),
    error = TRUE
  )
  expect_snapshot(
    filter_segment(c("a", "b"), 1:2),
    error = TRUE
  )
  expect_snapshot(
    filter_segment(c("a", NA), "a", keep_na = NA),
    error = TRUE
  )
})
