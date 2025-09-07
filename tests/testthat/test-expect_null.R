test_that("expect_null_linter skips allowed usages", {
  linter <- expect_null_linter()

  # NB: this usage should be expect_false(), but this linter should
  #   nevertheless apply (e.g. for maintainers not using expect_not_linter)
  expect_no_lint("expect_true(!is.null(x))", linter)
  # NB: also applies to tinytest, but it's sufficient to test testthat
  expect_no_lint("testthat::expect_true(!is.null(x))", linter)

  # length-0 could be NULL, but could be integer() or list(), so let it pass
  expect_no_lint("expect_length(x, 0L)", linter)

  # no false positive for is.null() at the wrong positional argument
  expect_no_lint("expect_true(x, is.null(y))", linter)
})

test_that("expect_null_linter blocks simple disallowed usages", {
  linter <- expect_null_linter()

  expect_lint(
    "expect_equal(x, NULL)",
    "expect_null(x) is better than expect_equal(x, NULL)",
    linter
  )

  # expect_identical is treated the same as expect_equal
  expect_lint(
    "expect_identical(x, NULL)",
    "expect_null(x) is better than expect_identical(x, NULL)",
    linter
  )

  # reverse order lints the same
  expect_lint(
    "expect_equal(NULL, x)",
    "expect_null(x) is better than expect_equal(x, NULL)",
    linter
  )

  # different equivalent usage
  expect_lint(
    "expect_true(is.null(foo(x)))",
    "expect_null(x) is better than expect_true(is.null(x))",
    linter
  )
})

test_that("lints vectorize", {
  expect_equal(
    nrow(
      lint_text(
        "{
      expect_equal(x, NULL)
      expect_identical(x, NULL)
      expect_true(is.null(x))
    }",
        linters = expect_null_linter()
      )
    ),
    3
  )
})

test_that("fix works", {
  linter <- expect_null_linter()

  expect_snapshot(fix_text("expect_identical(x, NULL)", linters = linter))
  expect_snapshot(fix_text("expect_equal(x, NULL)", linters = linter))
  expect_snapshot(fix_text("expect_true(is.null(x))", linters = linter))

  expect_snapshot(fix_text("expect_identical(NULL, x)", linters = linter))
  expect_snapshot(fix_text("expect_equal(NULL, x)", linters = linter))
})
