keyword_text <- paste0(
  "今天纽约的天气真好啊，京华大酒店的张尧经理吃了一只北京烤鸭。",
  "后天纽约的天气不好，昨天纽约的天气也不好，北京烤鸭真好吃"
)

test_that("keyword worker returns a named vector by default", {
  keys_worker <- worker(type = "keywords", topn = 3)
  result <- keywords(keyword_text, keys_worker)

  expect_type(result, "double")
  expect_length(result, 3L)
  expect_false(is.null(names(result)))
  expect_identical(names(result), c("北京烤鸭", "纽约", "天气"))
  expect_true(all(is.finite(unname(result))))
})

test_that("keyword worker can return a data frame", {
  keys_worker <- worker(type = "keywords", topn = 3)
  result <- keywords(keyword_text, keys_worker, format = "data.frame")

  result_df <- keywords_df(keyword_text, keys_worker)

  expect_s3_class(result, "data.frame")
  expect_identical(names(result), c("term", "weight"))
  expect_identical(result$term, c("北京烤鸭", "纽约", "天气"))
  expect_type(result$weight, "double")

  expect_identical(result, result_df)
})

test_that("keyword worker can return the legacy format", {
  keys_worker <- worker(type = "keywords", topn = 3)
  result <- keywords(keyword_text, keys_worker, format = "legacy")

  expect_type(result, "character")
  expect_identical(unname(result), c("北京烤鸭", "纽约", "天气"))
  expect_false(is.null(names(result)))
  expect_true(all(nzchar(names(result))))
})

test_that("keyword worker loads a custom IDF dictionary", {
  idf_file <- withr::local_tempfile()
  writeLines(
    c("北京烤鸭 99.0", "纽约 7.0", "天气 6.0"),
    idf_file,
    useBytes = TRUE
  )

  keys_default <- worker(type = "keywords", topn = 3)
  keys_custom <- worker(type = "keywords", topn = 3, idf = idf_file)

  # The custom IDF changes the weights.
  default_result <- keywords(keyword_text, keys_default)
  custom_result <- keywords(keyword_text, keys_custom)
  expect_false(identical(default_result, custom_result))

  # The custom IDF boosts "北京烤鸭" to a much higher weight.
  expect_true(custom_result[["北京烤鸭"]] > default_result[["北京烤鸭"]])

  # The config records the IDF path.
  expect_identical(keys_custom$config$idf, idf_file)
  expect_null(keys_default$config$idf)
})

test_that("keyword worker snapshots invalid IDF input", {
  expect_snapshot(
    worker(type = "keywords", idf = 5),
    error = TRUE
  )

  expect_snapshot(
    worker(type = "keywords", idf = "/nonexistent/idf.txt"),
    error = TRUE
  )
})

test_that("keywords requires optional arguments to be named", {
  keys_worker <- worker(type = "keywords", topn = 3)

  expect_snapshot(
    keywords(keyword_text, keys_worker, "legacy"),
    error = TRUE
  )
})

test_that("keywords snapshots invalid format input", {
  keys_worker <- worker(type = "keywords", topn = 3)

  expect_snapshot(
    keywords(keyword_text, keys_worker, format = "bad-format"),
    error = TRUE
  )

  expect_snapshot(
    keywords(5, keys_worker),
    error = TRUE
  )

  expect_snapshot(
    keywords(keyword_text, worker(type = "mix")),
    error = TRUE
  )
})
