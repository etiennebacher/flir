lint_message <- "anyNA(x) is better than any(is.na(x))."

test_that("any_is_na_linter skips allowed usages", {
  linter <- any_is_na_linter()

  expect_lint("x <- any(y)", NULL, linter)
  expect_lint("y <- is.na(z)", NULL, linter)

  # negation shouldn't list
  expect_lint("any(!is.na(x))", NULL, linter)
  expect_lint("any(!is.na(foo(x)))", NULL, linter)

  # extended usage of ... arguments to any is not covered
  expect_lint("any(is.na(y), b)", NULL, linter)
  expect_lint("any(b, is.na(y))", NULL, linter)
})

test_that("any_is_na_linter blocks disallowed usages", {
  linter <- any_is_na_linter()

  expect_lint("any(is.na(x))", lint_message, linter)
  expect_lint("any(is.na(foo(x)))", lint_message, linter)

  # na.rm doesn't really matter for this since is.na can't return NA
  expect_lint("any(is.na(x), na.rm = TRUE)", lint_message, linter)

  # also catch nested usage
  expect_lint("foo(any(is.na(x)))", lint_message, linter)
})

test_that("NA %in% x is also found", {
  linter <- any_is_na_linter()
  lint_message <- "anyNA(x) is better than NA %in% x."

  expect_lint("NA %in% x", lint_message, linter)
  expect_lint("NA_real_ %in% x", lint_message, linter)
  expect_lint("NA_not_a_sentinel_ %in% x", NULL, linter)
})
