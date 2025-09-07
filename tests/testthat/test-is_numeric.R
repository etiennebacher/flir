test_that("is_numeric_linter skips allowed usages involving ||", {
  linter <- is_numeric_linter()

  expect_no_lint("is.numeric(x) || is.integer(y)", linter)
  # x is used, but not identically
  expect_no_lint("is.numeric(x) || is.integer(foo(x))", linter)
  # not totally crazy, e.g. if input accepts a vector or a list
  expect_no_lint("is.numeric(x) || is.integer(x[[1]])", linter)
})

test_that("is_numeric_linter skips allowed usages involving %in%", {
  linter <- is_numeric_linter()

  # false positives for class(x) %in% c('integer', 'numeric') style
  expect_no_lint("class(x) %in% 1:10", linter)
  expect_no_lint("class(x) %in% 'numeric'", linter)
  expect_no_lint("class(x) %in% c('numeric', 'integer', 'factor')", linter)
  expect_no_lint("class(x) %in% c('numeric', 'integer', y)", linter)
})

test_that("is_numeric_linter blocks disallowed usages involving ||", {
  linter <- is_numeric_linter()
  lint_msg <- "can be simplified to is.numeric"

  expect_lint("is.numeric(x) || is.integer(x)", lint_msg, linter)

  # order doesn't matter
  expect_lint("is.integer(x) || is.numeric(x)", lint_msg, linter)

  # identical expressions match too
  expect_lint("is.integer(DT$x) || is.numeric(DT$x)", lint_msg, linter)

  # line breaks don't matter
  lines <- trim_some(
    "
    if (
      is.integer(x)
      || is.numeric(x)
    ) TRUE
  "
  )
  expect_lint(lines, lint_msg, linter)

  # caught when nesting
  expect_lint(
    "all(y > 5) && (is.integer(x) || is.numeric(x))",
    lint_msg,
    linter
  )

  # implicit nesting
  expect_lint(
    "is.integer(x) || is.numeric(x) || is.logical(x)",
    lint_msg,
    linter
  )
})

test_that("is_numeric_linter blocks disallowed usages involving %in%", {
  linter <- is_numeric_linter()
  lint_msg <- "can be simplified to is.numeric"

  expect_lint("class(x) %in% c('integer', 'numeric')", lint_msg, linter)
  expect_lint('class(x) %in% c("numeric", "integer")', lint_msg, linter)
})

test_that("raw strings are handled properly when testing in class", {
  skip_if_not_r_version("4.0.0")
  linter <- is_numeric_linter()
  lint_msg <- "can be simplified to is.numeric"

  expect_no_lint("class(x) %in% c(R'(numeric)', 'integer', 'factor')", linter)
  expect_no_lint("class(x) %in% c('numeric', R'--(integer)--', y)", linter)

  # TODO: fix that
  # expect_lint("class(x) %in% c(R'(integer)', 'numeric')", lint_msg, linter)
  # expect_lint('class(x) %in% c("numeric", R"--[integer]--")', lint_msg, linter)
})

test_that("lints vectorize", {
  expect_lint(
    trim_some(
      "{
      is.numeric(x) || is.integer(x)
      class(x) %in% c('integer', 'numeric')
    }"
    ),
    "can be simplified to is.numeric",
    NULL
  )
})
