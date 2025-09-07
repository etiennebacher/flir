test_that("expect_not_linter skips allowed usages", {
  expect_no_lint("expect_true(x)", expect_not_linter())
  expect_no_lint("expect_false(x)", expect_not_linter())

  # not a strict ban on !
  ##  (expect_false(x && y) is the same, but it's not clear which to prefer)
  expect_no_lint("expect_true(!x || !y)", expect_not_linter())
})

test_that("expect_not_linter doesn't block rlang bang-bang", {
  expect_no_lint("expect_true(!!x)", expect_not_linter())
  expect_no_lint("expect_true(!!!x)", expect_not_linter())
  expect_no_lint("expect_false(!!x)", expect_not_linter())
  expect_no_lint("expect_false(!!!x)", expect_not_linter())
})

test_that("expect_not_linter blocks simple disallowed usages", {
  linter <- expect_not_linter()
  lint_msg <- "expect_false(x) is better than expect_true(!x), and vice versa."

  expect_lint("expect_true(!x)", lint_msg, linter)
  expect_lint("expect_false(!foo(x))", lint_msg, linter)
  expect_lint("expect_true(!(x && y))", lint_msg, linter)
})

test_that("lints vectorize", {
  expect_equal(
    nrow(
      lint_text(
        "{
      expect_true(!x)
      expect_false(!y)
    }",
        linters = expect_not_linter()
      )
    ),
    2
  )
})

test_that("fix works", {
  linter <- expect_not_linter()

  expect_snapshot(fix_text("expect_true(!anyNA(x))", linters = linter))
  expect_snapshot(fix_text("expect_false(!anyNA(x))", linters = linter))

  # Do not change
  expect_snapshot(fix_text("expect_true(!anyNA(x) & TRUE)", linters = linter))
  expect_snapshot(fix_text("expect_false(!anyNA(x) & TRUE)", linters = linter))
})
