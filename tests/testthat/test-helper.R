test_that("symbol_handle leaves text unchanged when symbol is TRUE", {
  expect_identical(symbol_handle("你好，世界！", TRUE), "你好，世界！")
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

test_that("drop_space_tokens removes only literal space tokens", {
  expect_identical(
    drop_space_tokens(c("你好", " ", "世界", "\t")),
    c("你好", "世界", "\t")
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
