idf_docs <- list(
  c("abc", "def"),
  c("abc", "ghi")
)

test_that("get_idf computes IDF from a list of documents", {
  result <- get_idf(idf_docs)

  expect_s3_class(result, "data.frame")
  expect_identical(names(result), c("name", "count"))
  expect_type(result$count, "double")

  # 2 docs: "abc" in 2 -> log(2/2)=0, "def" in 1 -> log(2/1), "ghi" in 1 -> log(2/1)
  expect_equal(
    result$count[result$name == "abc"],
    log(2 / 2)
  )
  expect_equal(
    result$count[result$name == "def"],
    log(2 / 1)
  )
})

test_that("get_idf matches the jiebaR example", {
  result <- get_idf(list(c("abc", "def"), c("abc", " ")))

  # "abc" appears in both docs -> idf 0
  expect_equal(result$count[result$name == "abc"], 0)
  # "def" appears in one doc -> log(2)
  expect_equal(result$count[result$name == "def"], log(2))
})

test_that("get_idf counts each word once per document", {
  result <- get_idf(list(c("a", "a", "a"), c("a", "b")))

  # "a" is in both docs even though it repeats -> df 2 -> log(2/2)=0
  expect_equal(result$count[result$name == "a"], 0)
  # "b" is in one doc -> log(2/1)
  expect_equal(result$count[result$name == "b"], log(2 / 1))
})

test_that("get_idf removes stop words", {
  result <- get_idf(
    list(c("abc", "def", "x"), c("abc", "x")),
    stop_word = "x"
  )

  expect_false("x" %in% result$name)
  expect_setequal(result$name, c("abc", "def"))
})

test_that("get_idf removes stop words from a file", {
  stop_file <- withr::local_tempfile()
  writeLines(c("x", "y"), stop_file, useBytes = TRUE)

  result <- get_idf(
    list(c("abc", "x", "y"), c("abc", "def")),
    stop_word_file = stop_file
  )

  expect_false("x" %in% result$name)
  expect_false("y" %in% result$name)
  expect_setequal(result$name, c("abc", "def"))
})

test_that("get_idf writes a file and returns the path invisibly", {
  out_file <- withr::local_tempfile()
  visible <- withr::with_options(
    list(rlang_trace_top_env = NULL),
    withVisible(get_idf(idf_docs, path = out_file))
  )

  expect_false(visible$visible)
  expect_identical(visible$value, out_file)
  expect_true(file.exists(out_file))

  lines <- readLines(out_file)
  expect_length(lines, 3L)
  # Each line is `word idf_value` with a single space separator.
  expect_match(lines[[1]], "^\\S+ .+$")
})

test_that("get_idf output file works with worker(idf = ...)", {
  out_file <- withr::local_tempfile()
  get_idf(
    list(c("北京", "烤鸭"), c("北京", "天气"), c("纽约", "天气")),
    path = out_file
  )

  keys_custom <- worker(type = "keywords", topn = 2, idf = out_file)
  keys_default <- worker(type = "keywords", topn = 2)

  text <- "今天纽约的天气真好啊，北京烤鸭真好吃"
  custom_result <- keywords(text, keys_custom)
  default_result <- keywords(text, keys_default)

  expect_type(custom_result, "double")
  expect_length(custom_result, 2L)
  expect_false(identical(custom_result, default_result))
})

test_that("get_idf handles empty document elements", {
  result <- get_idf(list(c("a", "b"), character(), c("a")))

  expect_setequal(result$name, c("a", "b"))
  # "a" in 2 of 3 docs -> log(3/2), "b" in 1 of 3 -> log(3/1)
  expect_equal(result$count[result$name == "a"], log(3 / 2))
  expect_equal(result$count[result$name == "b"], log(3 / 1))
})

test_that("get_idf returns an empty data frame for all-empty documents", {
  result <- get_idf(list(character(), character()))

  expect_s3_class(result, "data.frame")
  expect_identical(names(result), c("name", "count"))
  expect_equal(nrow(result), 0L)
})

test_that("get_idf snapshots invalid inputs", {
  expect_snapshot(
    get_idf("not a list"),
    error = TRUE
  )

  expect_snapshot(
    get_idf(list()),
    error = TRUE
  )

  expect_snapshot(
    get_idf(list(c("a"), 5)),
    error = TRUE
  )

  expect_snapshot(
    get_idf(idf_docs, path = 5),
    error = TRUE
  )
})
