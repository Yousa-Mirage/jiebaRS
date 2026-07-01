test_that("count_ngrams counts a single n", {
  expect_identical(
    count_ngrams(c("我", "爱", "R", "语言"), n = 2),
    data.frame(
      term = c("我 爱", "爱 R", "R 语言"),
      n = c(2L, 2L, 2L),
      count = c(1L, 1L, 1L)
    )
  )
})

test_that("count_ngrams requires optional arguments to be named", {
  expect_snapshot(
    count_ngrams(c("我", "爱", "R", "语言"), 2),
    error = TRUE
  )
})

test_that("count_ngrams counts multiple n values", {
  expect_identical(
    count_ngrams(c("sd", "sd", "sd", "rd"), n = 2:3, sep = ""),
    data.frame(
      term = c("sdsd", "sdrd", "sdsdsd", "sdsdrd"),
      n = c(2L, 2L, 3L, 3L),
      count = c(2L, 1L, 1L, 1L)
    )
  )
})

test_that("count_ngrams supports list input", {
  expect_identical(
    count_ngrams(list(c("a", "b", "c"), c("a", "b")), n = 2),
    data.frame(
      term = c("a b", "b c"),
      n = c(2L, 2L),
      count = c(2L, 1L)
    )
  )
})

test_that("count_ngrams vector format uses raw term names", {
  expect_identical(
    count_ngrams(c("sd", "sd", "sd", "rd"), n = 2:3, sep = "", format = "vector"),
    stats::setNames(
      c(2L, 1L, 1L, 1L),
      c("sdsd", "sdrd", "sdsdsd", "sdsdrd")
    )
  )
})

test_that("count_ngrams sorts by count by default", {
  expect_identical(
    count_ngrams(c("a", "b", "b", "b", "a"), n = 1),
    data.frame(
      term = c("b", "a"),
      n = c(1L, 1L),
      count = c(3L, 2L)
    )
  )

  expect_identical(
    count_ngrams(c("a", "b", "b", "b", "a"), n = 1, format = "vector"),
    stats::setNames(c(3L, 2L), c("b", "a"))
  )
})

test_that("count_ngrams can keep first-appearance order", {
  expect_identical(
    count_ngrams(c("a", "b", "b", "b", "a"), n = 1, sort = FALSE),
    data.frame(
      term = c("a", "b"),
      n = c(1L, 1L),
      count = c(2L, 3L)
    )
  )

  expect_identical(
    count_ngrams(c("a", "b", "b", "b", "a"), n = 1, sort = FALSE, format = "vector"),
    stats::setNames(c(2L, 3L), c("a", "b"))
  )
})

test_that("count_ngrams snapshots invalid inputs", {
  expect_snapshot(count_ngrams(1:3), error = TRUE)
  expect_snapshot(count_ngrams(c("a", "b"), n = c(2, 0)), error = TRUE)
  expect_snapshot(count_ngrams(c("a", "b"), sort = NA), error = TRUE)
})

test_that("get_tuple is a deprecated compatibility wrapper", {
  expect_snapshot_warning(
    {
      res <- get_tuple(c("sd", "sd", "sd", "rd"), 2)
      invisible(res)
    }
  )

  expect_identical(
    res,
    data.frame(
      name = c("sdsd", "sdrd"),
      count = c(2L, 1L)
    )
  )

  expect_snapshot_warning(
    {
      res_vec <- get_tuple(c("sd", "sd", "sd", "rd"), 2, dataframe = FALSE)
      invisible(res_vec)
    }
  )

  expect_identical(
    res_vec,
    stats::setNames(c(2L, 1L), c("sdsd", "sdrd"))
  )
})

test_that("get_tuple matches jiebaR on supported vector input", {
  skip_if_not_installed("jiebaR")

  actual <- suppressWarnings(get_tuple(c("sd", "sd", "sd", "rd"), 3))
  expected <- jiebaR::get_tuple(c("sd", "sd", "sd", "rd"), 3)

  actual <- actual[order(actual$name), , drop = FALSE]
  expected <- expected[order(expected$name), , drop = FALSE]
  rownames(actual) <- NULL
  rownames(expected) <- NULL

  expect_equal(
    actual,
    expected
  )
})
