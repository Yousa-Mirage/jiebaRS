test_that("symbol_handle leaves text unchanged when symbol is TRUE", {
  expect_identical(symbol_handle("你好，世界！", TRUE), "你好，世界！")
})

test_that("normalize_stop_words merges and normalizes vectors and files", {
  stop_file <- withr::local_tempfile()
  writeLines(c(" 一个 ", "测试", "", "一个", "  "), stop_file, useBytes = TRUE)

  expect_identical(
    normalize_stop_words(
      stop_word = c("这是", NA_character_, "测试", "  ", "这是"),
      stop_word_file = stop_file
    ),
    c("这是", "测试", "一个")
  )
})

test_that("normalize_stop_words validates inputs", {
  expect_snapshot(
    normalize_stop_words(stop_word = 1:3),
    error = TRUE
  )

  expect_snapshot(
    normalize_stop_words(stop_word_file = 1),
    error = TRUE
  )

  expect_snapshot(
    normalize_stop_words(stop_word_file = tempfile()),
    error = TRUE
  )
})

test_that("symbol_handle replaces symbols with spaces when symbol is FALSE", {
  expect_identical(
    symbol_handle("你好，世界！", FALSE),
    "你好 世界 "
  )
})

test_that("symbol_handle works on character vectors", {
  expect_identical(
    symbol_handle(c("你好，世界！", "R 语言。"), FALSE),
    c("你好 世界 ", "R 语言 ")
  )
})

test_that("symbol_handle keeps Unicode letters, marks, and numbers", {
  expect_identical(
    symbol_handle(c("cafe\u0301!", "β2？"), FALSE),
    c("cafe\u0301 ", "β2 ")
  )
})

test_that("symbol handling is reused by segment", {
  keep_symbols <- worker(symbol = TRUE)
  drop_symbols <- worker(symbol = FALSE)

  expect_identical(
    segment("你好，世界！", keep_symbols),
    c("你好", "，", "世界", "！")
  )
  expect_identical(
    segment("你好，世界！", drop_symbols),
    c("你好", "世界")
  )
})
