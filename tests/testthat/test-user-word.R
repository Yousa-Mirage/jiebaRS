test_that("new_user_word updates worker segmentation for a single word", {
  engine1 <- worker()

  expect_identical(segment("量子机器狗", engine1), c("量子", "机器", "狗"))
  expect_no_error(new_user_word(engine1, "量子机器狗", "n"))
  expect_identical(segment("量子机器狗", engine1), "量子机器狗")
})

test_that("new_user_word accepts multiple words", {
  engine1 <- worker()

  expect_identical(segment("超导量子比特", engine1), c("超导", "量子", "比特"))
  expect_identical(segment("量子机器狗", engine1), c("量子", "机器", "狗"))

  expect_no_error(new_user_word(engine1, c("超导量子比特", "量子机器狗"), "n"))

  expect_identical(segment("超导量子比特", engine1), "超导量子比特")
  expect_identical(segment("量子机器狗", engine1), "量子机器狗")
})

test_that("new_user_word accepts nullable tags and freq", {
  engine1 <- worker()

  expect_no_error(
    new_user_word(
      engine1,
      c("超导量子比特", "量子机器狗"),
      tags = c(NA_character_, "n"),
      freq = c(NA_integer_, 1000L)
    )
  )

  expect_identical(segment("超导量子比特", engine1), "超导量子比特")
  expect_identical(segment("量子机器狗", engine1), "量子机器狗")
})

test_that("add_word is an alias of new_user_word", {
  expect_identical(add_word, new_user_word)

  engine1 <- worker()

  expect_identical(segment("量子机器狗", engine1), c("量子", "机器", "狗"))
  expect_no_error(add_word(engine1, "量子机器狗", "n"))
  expect_identical(segment("量子机器狗", engine1), "量子机器狗")
})

test_that("new_user_word snapshots invalid inputs", {
  engine1 <- worker()

  expect_snapshot(
    new_user_word("not-a-worker", "量子机器狗"),
    error = TRUE
  )
  expect_snapshot(
    new_user_word(engine1, 1:3),
    error = TRUE
  )
  expect_snapshot(
    new_user_word(engine1, c("量子机器狗", NA_character_)),
    error = TRUE
  )
  expect_snapshot(
    new_user_word(engine1, character()),
    error = TRUE
  )
  expect_snapshot(
    new_user_word(engine1, ""),
    error = TRUE
  )
  expect_snapshot(
    new_user_word(engine1, c("量子机器狗", "超导量子比特"), c("n", "nz", "v")),
    error = TRUE
  )
  expect_snapshot(
    new_user_word(engine1, c("量子机器狗", "超导量子比特"), freq = c(10L, 20L, 30L)),
    error = TRUE
  )
  expect_snapshot(
    new_user_word(engine1, "量子机器狗", freq = -1L),
    error = TRUE
  )
  expect_snapshot(
    new_user_word(engine1, "量子机器狗", freq = 0L),
    error = TRUE
  )
  expect_snapshot(
    new_user_word(engine1, "量子机器狗", freq = 1.5),
    error = TRUE
  )
  expect_snapshot(
    new_user_word(engine1, "量子机器狗", freq = "100"),
    error = TRUE
  )
})
