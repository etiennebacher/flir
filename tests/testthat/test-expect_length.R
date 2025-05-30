test_that("expect_length_linter skips allowed usages", {
  linter <- expect_length_linter()

  expect_lint("expect_equal(nrow(x), 4L)", NULL, linter)
  # NB: also applies to tinytest, but it's sufficient to test testthat
  expect_lint("expect_equal(nrow(x), 4L)", NULL, linter)

  # only check the first argument. yoda tests in the second argument will be
  #   missed, but there are legitimate uses of length() in argument 2
  # expect_lint("expect_equal(nrow(x), length(y))", NULL, linter)

  # expect_length() doesn't have info= or label= arguments
  expect_lint(
    "expect_equal(length(x), n, info = 'x should have size n')",
    NULL,
    linter
  )
  expect_lint("expect_equal(length(x), n, label = 'x size')", NULL, linter)
  expect_lint("expect_equal(length(x), length(y))", NULL, linter)
  expect_lint(
    "expect_equal(length(x), n, expected.label = 'target size')",
    NULL,
    linter
  )
})

test_that("expect_length_linter blocks simple disallowed usages", {
  linter <- expect_length_linter()
  lint_msg <- "expect_length(x, n) is better than expect_equal(length(x), n)"

  expect_lint("expect_equal(length(x), 2L)", lint_msg, linter)

  # yoda test cases
  expect_lint("expect_equal(2, length(x))", lint_msg, linter)
  expect_lint("expect_equal(2L, length(x))", lint_msg, linter)
})

test_that("expect_length_linter blocks expect_identical usage as well", {
  expect_lint(
    "expect_identical(length(x), 2L)",
    "expect_length(x, n) is better than expect_identical(length(x), n)",
    expect_length_linter()
  )
})

test_that("lints vectorize", {
  expect_equal(
    nrow(
      lint_text(
        "{
      expect_equal(length(x), n)
      expect_identical(length(x), n)
    }",
        linter = expect_length_linter()
      )
    ),
    2
  )
})

test_that("fix works", {
  linter <- expect_length_linter()

  expect_snapshot(fix_text("expect_equal(length(x), 2L)", linters = linter))
  expect_snapshot(fix_text("expect_identical(length(x), 2L)", linters = linter))

  expect_snapshot(fix_text("expect_equal(2L, length(x))", linters = linter))
  expect_snapshot(fix_text("expect_identical(2L, length(x))", linters = linter))
})
