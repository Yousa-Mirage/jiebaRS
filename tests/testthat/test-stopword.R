keyword_stopword_text <- paste0(
  "今天纽约的天气真好啊，京华大酒店的张尧经理吃了一只北京烤鸭。",
  "后天纽约的天气不好，昨天纽约的天气也不好，北京烤鸭真好吃"
)

test_that("worker stores normalized stop words in config", {
  stop_file <- withr::local_tempfile()
  writeLines(c(" 一个 ", "测试", "", "一个", "  "), stop_file, useBytes = TRUE)

  engine1 <- worker(
    stop_word = c("这是", NA_character_, "测试", "  ", "这是"),
    stop_word_file = stop_file
  )

  expect_identical(engine1$config$stop_word, c("这是", "测试", "一个"))
})

test_that("segment filters stop words from vectors and files", {
  stop_file <- withr::local_tempfile()
  writeLines(c("一个", "长江大桥"), stop_file, useBytes = TRUE)

  engine1 <- worker(
    stop_word = c("这是", "长江大桥", NA_character_, "  "),
    stop_word_file = stop_file
  )

  expect_identical(
    segment(c("南京市长江大桥", "这是一个测试"), engine1),
    list(
      "南京市",
      "测试"
    )
  )
})

test_that("tagging filters stop words from vectors and files", {
  stop_file <- withr::local_tempfile()
  writeLines(c("一个", "再"), stop_file, useBytes = TRUE)

  tagger <- worker(
    type = "tag",
    stop_word = c("这是", "来", NA_character_, "  "),
    stop_word_file = stop_file
  )

  expect_identical(
    tagging(c("这是一个测试", "再来一次"), tagger),
    list(
      stats::setNames("vn", "测试"),
      stats::setNames("m", "一次")
    )
  )
})

test_that("keywords filter stop words during TF-IDF extraction", {
  stop_file <- withr::local_tempfile()
  writeLines(c("天气"), stop_file, useBytes = TRUE)

  keys_worker <- worker(
    type = "keywords",
    topn = 5,
    stop_word = c("纽约", NA_character_, "  "),
    stop_word_file = stop_file
  )

  result <- keywords(keyword_stopword_text, keys_worker)

  expect_identical(
    names(result),
    c("北京烤鸭", "张尧", "不好", "大酒店", "京华")
  )
})

test_that("keywords do not inherit implicit default english stop words", {
  keys_worker <- worker(type = "keywords", topn = 3)

  expect_identical(
    names(keywords("this is a test", keys_worker)),
    c("is", "test", "this")
  )
})
