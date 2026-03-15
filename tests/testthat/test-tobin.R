test_that("tobin matches jiebaR examples", {
  expect_equal(
    tobin("200000000000000000"),
    "0000001011000110100010101111000010111011000101000000000000000000"
  )
  expect_equal(
    tobin("2"),
    "0000000000000000000000000000000000000000000000000000000000000010"
  )
})

test_that("tobin matches jiebaR on representative inputs", {
  skip_if_not_installed("jiebaR")

  values <- c(
    "0",
    "1",
    "2",
    "12",
    "123",
    "200000000000000000",
    as.character(.Machine$integer.max),
    "18446744073709551615"
  )

  for (value in values) {
    expect_identical(tobin(value), jiebaR::tobin(value))
  }
})

test_that("tobin snapshots invalid input", {
  expect_snapshot(tobin(1), error = TRUE)
  expect_snapshot(tobin(NA_character_), error = TRUE)
  expect_snapshot(tobin("not-a-number"), error = TRUE)
})
