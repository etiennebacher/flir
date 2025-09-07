test_that("any_duplicated_linter skips allowed usages", {
  linter <- any_duplicated_linter()

  expect_no_lint("x <- any(y)", linter)
  expect_no_lint("y <- duplicated(z)", linter)
})

test_that("any_duplicated_linter blocks simple disallowed usages", {
  linter <- any_duplicated_linter()
  lint_msg <- "anyDuplicated(x, ...) > 0 is better than any(duplicated(x), ...)."

  expect_lint("any(duplicated(x))", lint_msg, linter)
  expect_lint("any(duplicated(foo(x)))", lint_msg, linter)

  expect_lint("any(duplicated(y), b)", lint_msg, linter)
  expect_lint("any(b, duplicated(y))", lint_msg, linter)

  # na.rm doesn't really matter for this since duplicated can't return NA
  expect_lint("any(duplicated(x), na.rm = TRUE)", lint_msg, linter)

  # also catch nested usage
  expect_lint("foo(any(duplicated(x)))", lint_msg, linter)
})

test_that("any_duplicated_linter catches length(unique()) equivalencies too", {
  linter <- any_duplicated_linter()
  lint_msg_x <- "anyDuplicated(x) == 0L is better than length(unique(x)) == length(x)."
  lint_msg_df <- "anyDuplicated(DF$col) == 0L is better than length(unique(DF$col)) == nrow(DF)"
  lint_msg_df2 <- "anyDuplicated(DF[[\"col\"]]) == 0L is better than length(unique(DF[[\"col\"]])) == nrow(DF)"

  # non-matches
  ## different variable
  expect_no_lint("length(unique(x)) == length(y)", linter)
  ## different table
  expect_no_lint("length(unique(DF$x)) == nrow(DT)", linter)
  expect_no_lint("length(unique(l1$DF$x)) == nrow(l2$DF)", linter)

  # lintable usage
  expect_lint("length(unique(x)) == length(x)", lint_msg_x, linter)
  # argument order doesn't matter
  expect_lint("length(x) == length(unique(x))", lint_msg_x, linter)

  # nrow-style equivalency
  expect_lint("nrow(DF) == length(unique(DF$col))", lint_msg_df, linter)
  expect_lint("length(unique(DF$col)) == nrow(DF)", lint_msg_df, linter)
  # TODO: problem is that if I put != instead, the error message/fix still
  # proposes ==
  # expect_lint("nrow(DF) == length(unique(DF[['col']]))", lint_msg_df2, linter)
  # expect_lint("length(unique(DF[['col']])) == nrow(DF)", lint_msg_df2, linter)

  # TODO: match with nesting too
  # expect_lint(
  #   "nrow(l$DF) == length(unique(l$DF[['col']]))",
  #   lint_msg_df,
  #   linter
  # )

  # !=, <, and > usages are all alternative ways of writing a test for dupes
  #   technically, the direction of > / < matter, but writing
  #   length(unique(x)) > length(x) doesn't seem like it would ever happen.
  expect_lint(
    "length(unique(x)) != length(x)",
    "Use anyDuplicated(x) != 0",
    linter
  )
  # expect_lint(
  #   "length(unique(x)) < length(x)",
  #   rex::rex("anyDuplicated(x) == 0L is better than length(unique(x)) == length(x)"),
  #   linter
  # )
  # expect_lint(
  #   "length(x) > length(unique(x))",
  #   rex::rex("anyDuplicated(x) == 0L is better than length(unique(x)) == length(x)"),
  #   linter
  # )

  # TODO(michaelchirico): try and match data.table- and dplyr-specific versions of
  #   this, e.g. DT[, length(unique(col)) == .N] or
  #   > DT %>% filter(length(unique(col)) == n())
})

test_that("any_duplicated_linter catches expression with two types of lint", {
  expect_lint(
    "table(any(duplicated(x)), length(unique(x)) != length(x)",
    "anyDuplicated",
    NULL
  )
})

test_that("fixes for any_duplicated rules", {
  # basic
  expect_fix("any(duplicated(x))", "anyDuplicated(x) > 0")
  expect_fix("any(duplicated(any(x)))", "anyDuplicated(any(x)) > 0")
  expect_fix("any(duplicated(var(x)))", "anyDuplicated(var(x)) > 0")

  # multiline
  expect_fix("any(\nduplicated(\nvar(x)\n)\n)", "anyDuplicated(var(x)) > 0")

  # other args
  expect_fix("any(duplicated(x), na.rm = TRUE)", "anyDuplicated(x) > 0")
  expect_fix("any(na.rm = TRUE, duplicated(x))", "anyDuplicated(x) > 0")

  # multiple fixes
  expect_fix(
    "any(duplicated(x)); 1 + 1; any(duplicated(y))",
    "anyDuplicated(x) > 0; 1 + 1; anyDuplicated(y) > 0"
  )
  expect_fix(
    "any(duplicated(x))\n1 + 1\n  any(duplicated(y))",
    "anyDuplicated(x) > 0\n1 + 1\n  anyDuplicated(y) > 0"
  )

  expect_fix("length(unique(x)) != length(x)", "anyDuplicated(x) != 0L")
  expect_fix("length(unique(x)) == length(x)", "anyDuplicated(x) == 0L")

  expect_fix("length(unique(x$y)) != nrow(x)", "anyDuplicated(x$y) != 0L")
  expect_fix("length(unique(x$y)) == nrow(x)", "anyDuplicated(x$y) == 0L")

  # TODO: why doesn't this work
  # expect_fix("length(unique(x[['y']])) != nrow(x)", "anyDuplicated(x[[\"y\"]]) != 0L")
  # expect_fix("length(unique(x[['y']])) == nrow(x)", "anyDuplicated(x[[\"y\"]]) == 0L")
})
