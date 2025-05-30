test_that("matrix_apply_linter skips allowed usages", {
  linter <- matrix_apply_linter()

  expect_lint("apply(x, 1, prod)", NULL, linter)

  expect_lint("apply(x, 1, function(i) sum(i[i > 0]))", NULL, linter)

  # sum as FUN argument
  expect_lint("apply(x, 1, f, sum)", NULL, linter)

  # mean() with named arguments other than na.rm is skipped because they are not
  # implemented in colMeans() or rowMeans()
  expect_lint("apply(x, 1, mean, trim = 0.2)", NULL, linter)
})

test_that("matrix_apply_linter is not implemented for complex MARGIN values", {
  linter <- matrix_apply_linter()

  # Could be implemented at some point
  expect_lint("apply(x, seq(2, 4), sum)", NULL, linter)

  # No equivalent
  expect_lint("apply(x, c(2, 4), sum)", NULL, linter)

  # Beyond the scope of static analysis
  expect_lint("apply(x, m, sum)", NULL, linter)

  expect_lint("apply(x, 1 + 2:4, sum)", NULL, linter)
})

test_that("matrix_apply_linter simple disallowed usages", {
  linter <- matrix_apply_linter()
  lint_message <- "rowSums(x)"

  expect_lint("apply(x, 1, sum)", lint_message, linter)
  expect_lint("apply(x, MARGIN = 1, FUN = sum)", lint_message, linter)
  expect_lint("apply(x, 1L, sum)", lint_message, linter)

  # TODO
  # expect_lint("apply(x, 1:4, sum)", "rowSums(x, dims = 4)", linter)
  # expect_lint("apply(x, 2, sum)", "rowSums(colSums(x))", linter)
  # expect_lint("apply(x, 2:4, sum)", "rowSums(colSums(x), dims = 3)", linter)

  lint_message <- "rowMeans"
  expect_lint("apply(x, 1, mean)", lint_message, linter)
  expect_lint("apply(x, MARGIN = 1, FUN = mean)", lint_message, linter)

  lint_message <- "colMeans"
  expect_lint("apply(x, 2, mean)", lint_message, linter)

  # TODO
  # expect_lint("apply(x, 2:4, mean)", lint_message, linter)
})

test_that("matrix_apply_linter recommendation includes na.rm if present in original call", {
  linter <- matrix_apply_linter()
  lint_message <- "na.rm = TRUE"

  expect_lint("apply(x, 1, sum, na.rm = TRUE)", lint_message, linter)
  expect_lint("apply(x, 2, sum, na.rm = TRUE)", lint_message, linter)
  expect_lint("apply(x, 1, mean, na.rm = TRUE)", lint_message, linter)
  expect_lint("apply(x, 2, mean, na.rm = TRUE)", lint_message, linter)

  lint_message <- "rowSums(x)"
  expect_lint("apply(x, 1, sum)", lint_message, linter)
  expect_lint("apply(x, 1L, sum)", lint_message, linter)

  lint_message <- "na.rm = foo"
  expect_lint("apply(x, 1, sum, na.rm = foo)", lint_message, linter)
  expect_lint("apply(x, 1L, sum, na.rm = foo)", lint_message, linter)
})

test_that("fix works", {
  linter <- matrix_apply_linter()

  expect_snapshot(fix_text("apply(x, 1, sum)", linters = linter))
  expect_snapshot(fix_text("apply(x, 1L, sum)", linters = linter))
  expect_snapshot(fix_text("apply(x, MARGIN = 1, sum)", linters = linter))
  expect_snapshot(fix_text("apply(x, MARGIN = 1, FUN = sum)", linters = linter))
  expect_snapshot(
    fix_text("apply(x, MARGIN = 1, FUN = sum, na.rm = TRUE)", linters = linter)
  )

  expect_snapshot(fix_text("apply(x, 2, sum)", linters = linter))
  expect_snapshot(fix_text("apply(x, 2L, sum)", linters = linter))
  expect_snapshot(fix_text("apply(x, MARGIN = 2, sum)", linters = linter))
  expect_snapshot(fix_text("apply(x, MARGIN = 2, FUN = sum)", linters = linter))
  expect_snapshot(
    fix_text("apply(x, MARGIN = 2, FUN = sum, na.rm = TRUE)", linters = linter)
  )

  expect_snapshot(fix_text("apply(x, 1, mean)", linters = linter))
  expect_snapshot(fix_text("apply(x, 1L, mean)", linters = linter))
  expect_snapshot(fix_text("apply(x, MARGIN = 1, mean)", linters = linter))
  expect_snapshot(
    fix_text("apply(x, MARGIN = 1, FUN = mean)", linters = linter)
  )
  expect_snapshot(
    fix_text("apply(x, MARGIN = 1, FUN = mean, na.rm = TRUE)", linters = linter)
  )

  expect_snapshot(fix_text("apply(x, 2, mean)", linters = linter))
  expect_snapshot(fix_text("apply(x, MARGIN = 2, mean)", linters = linter))
  expect_snapshot(
    fix_text("apply(x, MARGIN = 2, FUN = mean)", linters = linter)
  )
  expect_snapshot(
    fix_text("apply(x, MARGIN = 2, FUN = mean, na.rm = TRUE)", linters = linter)
  )
})
