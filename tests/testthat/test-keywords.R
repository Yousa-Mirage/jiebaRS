keyword_text <- paste0(
  "今天纽约的天气真好啊，京华大酒店的张尧经理吃了一只北京烤鸭。",
  "后天纽约的天气不好，昨天纽约的天气也不好，北京烤鸭真好吃"
)

test_that("keyword worker returns a named numeric vector by default", {
  keys_worker <- worker(type = "keywords", topn = 3)
  result <- keywords(keyword_text, keys_worker)

  expect_type(result, "double")
  expect_length(result, 3L)
  expect_false(is.null(names(result)))
  expect_equal(names(result), c("北京烤鸭", "纽约", "天气"))
  expect_true(all(is.finite(unname(result))))
})

test_that("keyword worker can return a data frame", {
  keys_worker <- worker(type = "keywords", topn = 3)
  result <- keywords(keyword_text, keys_worker, format = "data.frame")

  result_df <- keywords_df(keyword_text, keys_worker)

  expect_s3_class(result, "data.frame")
  expect_equal(names(result), c("term", "weight"))
  expect_equal(result$term, c("北京烤鸭", "纽约", "天气"))
  expect_type(result$weight, "double")

  expect_equal(result, result_df)
})

test_that("keyword worker can return the legacy format", {
  keys_worker <- worker(type = "keywords", topn = 3)
  result <- keywords(keyword_text, keys_worker, format = "legacy")

  expect_type(result, "character")
  expect_equal(unname(result), c("北京烤鸭", "纽约", "天气"))
  expect_false(is.null(names(result)))
  expect_true(all(nzchar(names(result))))
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
