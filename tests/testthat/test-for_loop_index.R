test_that("for_loop_index_linter skips allowed usages", {
  linter <- for_loop_index_linter()

  expect_no_lint("for (xi in x) {}", linter)

  # this is OK, so not every symbol is problematic
  expect_no_lint("for (col in DF$col) {}", linter)
  expect_no_lint("for (col in S4@col) {}", linter)
  expect_no_lint("for (col in DT[, col]) {}", linter)

  # make sure symbol check is scoped
  expect_no_lint(
    trim_some(
      "
      {
        for (i in 1:10) {
          42L
        }
        i <- 7L
      }
    "
    ),
    linter
  )
})

test_that("for_loop_index_linter blocks simple disallowed usages", {
  linter <- for_loop_index_linter()
  lint_msg <- "Don't re-use any sequence symbols as the index symbol in a for loop"

  expect_lint("for (x in x) {}", lint_msg, linter)
  # these also overwrite a variable in calling scope
  expect_lint("for (x in foo(x)) {}", lint_msg, linter)
  expect_no_lint("for (x in foo(x = 1)) {}", linter)
  # arbitrary nesting
  expect_lint("for (x in foo(bar(y, baz(2, x)))) {}", lint_msg, linter)
  expect_no_lint("for (x in foo(bar(y, baz(2, x = z)))) {}", linter)
})
