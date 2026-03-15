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
  expect_snapshot(
    filter_segment(c("a", "b"), "a", unit = 10)
  )
})

test_that("filter_segment matches jiebaR on supported inputs", {
  skip_if_not_installed("jiebaR")

  cases <- list(
    list(
      input = c("我", "是", "测试", "文本", "我"),
      filter_words = c("我", "你"),
      unit = 50
    ),
    list(
      input = list(
        c("我", "是", "测试", "文本"),
        c("测试", "文本", "我", "你")
      ),
      filter_words = c("我", "你"),
      unit = 50
    ),
    list(
      input = c("a", NA, "b", "a"),
      filter_words = c(NA, "b"),
      unit = 50
    ),
    list(
      input = c("abc", "def", " ", "."),
      filter_words = c("abc"),
      unit = 50
    ),
    list(
      input = c("a", "b", "c"),
      filter_words = c("a", "b", "c"),
      unit = 1
    )
  )

  for (case in cases) {
    new_res <- suppressWarnings(
      filter_segment(input = case$input, filter_words = case$filter_words, unit = case$unit)
    )
    old_res <- jiebaR::filter_segment(input = case$input, filter_words = case$filter_words, unit = case$unit)

    expect_identical(new_res, old_res)
  }
})
