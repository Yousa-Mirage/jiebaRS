textrank_text <- paste0(
  "此外，公司拟对全资子公司吉林欧亚置业有限公司增资4.3亿元，",
  "增资后，吉林欧亚置业注册资本由7000万元增加到5亿元。",
  "吉林欧亚置业主要经营范围为房地产开发及百货零售等业务。",
  "目前在建吉林欧亚城市商业综合体项目。2013年，实现营业收入0万元，实现净利润-139.13万元。"
)

test_that("textrank returns a named vector by default", {
  ranker <- worker(type = "textrank", topn = 3)
  result <- textrank(textrank_text, ranker)

  expect_type(result, "double")
  expect_length(result, 3L)
  expect_false(is.null(names(result)))
  expect_identical(names(result), c("欧亚", "吉林", "置业"))
  expect_true(all(is.finite(unname(result))))
})

test_that("textrank supports single-character terms", {
  text <- "今天股票跌很厉害，股票又跌"
  default_result <- textrank(text, worker(type = "textrank", topn = 100))
  single_result <- textrank(
    text,
    worker(type = "textrank", topn = 100, min_keyword_length = 1)
  )

  expect_identical("跌" %in% names(default_result), FALSE)
  expect_identical("跌" %in% names(single_result), TRUE)
})

test_that("textrank can return a data frame", {
  ranker <- worker(type = "textrank", topn = 3)
  result <- textrank(textrank_text, ranker, format = "data.frame")
  result_df <- textrank_df(textrank_text, ranker)

  expect_s3_class(result, "data.frame")
  expect_identical(names(result), c("term", "weight"))
  expect_identical(result$term, c("欧亚", "吉林", "置业"))
  expect_type(result$weight, "double")
  expect_identical(result, result_df)
})

test_that("textrank can return the legacy format", {
  ranker <- worker(type = "textrank", topn = 3)
  result <- textrank(textrank_text, ranker, format = "legacy")

  expect_type(result, "character")
  expect_identical(unname(result), c("欧亚", "吉林", "置业"))
  expect_false(is.null(names(result)))
  expect_true(all(nzchar(names(result))))
})

test_that("textrank is distinct from TF-IDF keywords", {
  ranker <- worker(type = "textrank", topn = 3)
  keys_worker <- worker(type = "keywords", topn = 3)

  expect_false(identical(
    textrank(textrank_text, ranker),
    keywords(textrank_text, keys_worker)
  ))

  expect_snapshot(
    textrank(textrank_text, keys_worker),
    error = TRUE
  )

  expect_snapshot(
    keywords(textrank_text, ranker),
    error = TRUE
  )
})

test_that("textrank requires optional arguments to be named", {
  ranker <- worker(type = "textrank", topn = 3)

  expect_snapshot(
    textrank(textrank_text, ranker, "legacy"),
    error = TRUE
  )
})

test_that("textrank snapshots invalid inputs", {
  ranker <- worker(type = "textrank", topn = 3)

  expect_snapshot(
    textrank(textrank_text, ranker, format = "bad-format"),
    error = TRUE
  )

  expect_snapshot(
    textrank(5, ranker),
    error = TRUE
  )
})
