test_that("expect_true_false_linter skips allowed usages", {
  # expect_true is a scalar test; testing logical vectors with expect_equal is OK
  expect_no_lint("expect_equal(x, c(TRUE, FALSE))", expect_true_false_linter())
})

test_that("expect_true_false_linter blocks simple disallowed usages", {
  linter <- expect_true_false_linter()

  expect_lint(
    "expect_equal(foo(x), TRUE)",
    "expect_true(x) is better than expect_equal(x, TRUE)",
    linter
  )

  expect_lint(
    "expect_equal(TRUE, foo(x))",
    "expect_true(x) is better than expect_equal(x, TRUE)",
    linter
  )

  # expect_identical is treated the same as expect_equal
  expect_lint(
    "expect_identical(x, FALSE)",
    "expect_false(x) is better than expect_identical(x, FALSE)",
    linter
  )

  # also caught when TRUE/FALSE is the first argument
  expect_lint(
    "expect_equal(TRUE, foo(x))",
    "expect_true(x) is better than expect_equal(x, TRUE)",
    linter
  )
})

test_that("lints vectorize", {
  linter <- expect_true_false_linter()
  expect_equal(
    nrow(
      lint_text(
        "{
      expect_equal(x, TRUE)
      expect_equal(x, FALSE)
    }",
        linters = linter
      )
    ),
    2
  )
})

test_that("fix works", {
  linter <- expect_true_false_linter()

  expect_snapshot(fix_text("expect_equal(foo(x), TRUE)", linters = linter))
  expect_snapshot(fix_text("expect_equal(foo(x), FALSE)", linters = linter))

  expect_snapshot(fix_text("expect_identical(foo(x), TRUE)", linters = linter))
  expect_snapshot(fix_text("expect_identical(foo(x), FALSE)", linters = linter))

  expect_snapshot(fix_text("expect_equal(TRUE, foo(x))", linters = linter))
  expect_snapshot(fix_text("expect_equal(FALSE, foo(x))", linters = linter))
})
