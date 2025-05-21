test_that("expect_*() rules are only present if the package uses testthat", {
  create_local_package()
  expect_rules <- grep("^expect\\_", list_linters(), value = TRUE)
  expect_length(expect_rules, 0)

  suppressMessages(usethis::use_testthat())
  expect_rules <- grep("^expect\\_", list_linters(), value = TRUE)
  expect_true(length(expect_rules) > 0)
})

test_that("expect_*() rules are only used if the package uses testthat", {
  create_local_package()
  fs::dir_create("inst/tinytest")

  cat(
    "expect_equal(names(x), c('a', 'b'))\n",
    file = "inst/tinytest/test-foo.R"
  )

  # lint() skips expect_* linters for tinytest
  expect_true(nrow(lint_package(open = FALSE)) == 0)
  expect_true(nrow(lint("inst/tinytest/test-foo.R", open = FALSE)) == 0)

  # fix() leaves that unchanged
  fix("inst/tinytest/test-foo.R")
  expect_equal(
    readLines("inst/tinytest/test-foo.R"),
    "expect_equal(names(x), c('a', 'b'))"
  )
})
