test_that("expect_comparison_linter skips allowed usages", {
  linter <- expect_comparison_linter()

  # there's no expect_ne() for this operator
  expect_lint("expect_true(x != y)", NULL, linter)
  # NB: also applies to tinytest, but it's sufficient to test testthat
  expect_lint("testthat::expect_true(x != y)", NULL, linter)

  # multiple comparisons are OK
  expect_lint("expect_true(x > y || x > z)", NULL, linter)

  # expect_gt() and friends don't have an info= argument
  expect_lint(
    "expect_true(x > y, info = 'x is bigger than y yo')",
    NULL,
    linter
  )

  # expect_true() used incorrectly, and as executed the first argument is not a lint
  expect_lint("expect_true(is.count(n_draws), n_draws > 1)", NULL, linter)
})

test_that("expect_comparison_linter blocks simple disallowed usages", {
  linter <- expect_comparison_linter()

  expect_lint(
    "expect_true(x > y)",
    "expect_gt(x, y) is better than expect_true(x > y).",
    linter
  )

  expect_lint(
    "expect_true(x < y)",
    "expect_lt(x, y) is better than expect_true(x < y).",
    linter
  )

  expect_lint(
    "expect_true(foo(x) >= y[[2]])",
    "expect_gte(x, y) is better than expect_true(x >= y).",
    linter
  )

  expect_lint(
    "expect_true(x <= y)",
    "expect_lte(x, y) is better than expect_true(x <= y).",
    linter
  )
})

test_that("fix works", {
  linter <- expect_comparison_linter()

  expect_snapshot(fix_text("expect_true(x > y)", linters = linter))
  expect_snapshot(fix_text("expect_true(x >= y)", linters = linter))
  expect_snapshot(fix_text("expect_true(x < y)", linters = linter))
  expect_snapshot(fix_text("expect_true(x <= y)", linters = linter))
})
