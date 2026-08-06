test_that("动漫大全 BDICT imports specialized terms", {
  fixture <- testthat::test_path("fixtures", "cidian", "动漫大全.bdict")
  testthat::skip_if_not(file.exists(fixture), "Real cidian fixtures are not available.")

  cutter <- worker()
  texts <- c("圣斗士星矢", "百变小樱", "东京食尸鬼", "十万个冷笑话", "妖精的尾巴")
  expect_identical(
    segment_batch(texts, cutter, batch = "list"),
    list(
      c("圣斗士", "星矢"),
      c("百", "变小", "樱"),
      c("东京", "食尸", "鬼"),
      c("十万个", "冷笑", "话"),
      c("妖精", "的", "尾巴")
    )
  )

  expect_invisible(import_cidian(cutter, fixture))
  expect_identical(
    segment_batch(texts, cutter, batch = "list"),
    list("圣斗士星矢", "百变小樱", "东京食尸鬼", "十万个冷笑话", "妖精的尾巴")
  )
})

test_that("象棋 SCEL imports specialized terms", {
  fixture <- testthat::test_path("fixtures", "cidian", "象棋.scel")
  testthat::skip_if_not(file.exists(fixture), "Real cidian fixtures are not available.")

  cutter <- worker()
  texts <- c("白马卧槽", "兵八进一", "边马对还中炮")
  expect_identical(
    segment_batch(texts, cutter, batch = "list"),
    list(
      c("白马", "卧槽"),
      c("兵八进", "一"),
      c("边马", "对", "还", "中炮")
    )
  )

  expect_invisible(import_cidian(cutter, fixture))
  expect_identical(
    segment_batch(texts, cutter, batch = "list"),
    list("白马卧槽", "兵八进一", "边马对还中炮")
  )
})

test_that("read_cidian returns dictionary entries and codes", {
  fixture1 <- testthat::test_path("fixtures", "cidian", "动漫大全.bdict")
  fixture2 <- testthat::test_path("fixtures", "cidian", "象棋.scel")
  testthat::skip_if_not(file.exists(fixture1), "Real cidian fixtures are not available.")
  testthat::skip_if_not(file.exists(fixture2), "Real cidian fixtures are not available.")

  dictionary <- read_cidian(fixture1)

  expect_s3_class(dictionary, "data.frame")
  expect_identical(names(dictionary), c("entry", "code"))
  expect_type(dictionary$entry, "character")
  expect_type(dictionary$code, "character")

  words <- c("圣斗士星矢", "百变小樱", "东京食尸鬼", "十万个冷笑话", "妖精的尾巴")
  entry_index <- match(words, dictionary$entry)
  expect_identical(dictionary$entry[entry_index], words)
  expect_identical(
    dictionary$code[entry_index],
    c(
      "sheng dou shi xing shi",
      "bai bian xiao ying",
      "dong jing shi shi gui",
      "shi wan ge leng xiao hua",
      "yao jing de wei ba"
    )
  )
  expect_identical(nrow(dictionary), 17830L)

  dictionary <- read_cidian(fixture2)
  expect_identical(nrow(dictionary), 1772L)
})

test_that("import_cidian snapshots missing file errors", {
  missing_file <- withr::local_tempfile(fileext = ".scel")

  expect_snapshot(
    import_cidian(worker(), missing_file),
    error = TRUE
  )
})

test_that("import_cidian snapshots unsupported extension errors", {
  unsupported_file <- withr::local_tempfile(fileext = ".txt")
  expect_true(file.create(unsupported_file))
  scrub_path <- function(x) {
    gsub(unsupported_file, "<unsupported-file>", x, fixed = TRUE)
  }

  expect_snapshot(
    import_cidian(worker(), unsupported_file),
    error = TRUE,
    transform = scrub_path
  )
})
