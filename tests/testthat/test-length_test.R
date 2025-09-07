test_that("skips allowed usages", {
  linter <- length_test_linter()

  expect_no_lint("length(x) > 0", linter)
  expect_no_lint("length(DF[key == val, cols])", linter)
})

test_that("blocks simple disallowed usages", {
  linter <- length_test_linter()
  lint_msg_stub <- "Checking the length of a logical vector is likely a mistake"

  expect_lint("length(x == 0)", lint_msg_stub, linter)
  expect_lint("length(x == y)", lint_msg_stub, linter)
  expect_lint("length(x + y == 2)", lint_msg_stub, linter)
})

test_that("blocks simple disallowed usages", {
  linter <- length_test_linter()
  lint_msg_stub <- "Checking the length of a logical vector is likely a mistake"

  expect_lint("length(x != 0)", lint_msg_stub, linter)
  expect_lint("length(x >= 0)", lint_msg_stub, linter)
  expect_lint("length(x <= 0)", lint_msg_stub, linter)
  expect_lint("length(x > 0)", lint_msg_stub, linter)
  expect_lint("length(x < 0)", lint_msg_stub, linter)
  expect_lint("length(x < 0)", lint_msg_stub, linter)
})

test_that("fix works", {
  linter <- length_test_linter()

  expect_snapshot(fix_text("length(x == 0)", linters = linter))
  expect_snapshot(fix_text("length(x != 0)", linters = linter))
  expect_snapshot(fix_text("length(x >= 0)", linters = linter))
  expect_snapshot(fix_text("length(x <= 0)", linters = linter))
  expect_snapshot(fix_text("length(x > 0)", linters = linter))
  expect_snapshot(fix_text("length(x < 0)", linters = linter))
})
