test_that("sort_linter skips allowed usages", {
  linter <- sort_linter()

  expect_no_lint("order(y)", linter)

  expect_no_lint("y[order(x)]", linter)

  # If another function is intercalated, don't fail
  expect_no_lint("x[c(order(x))]", linter)

  expect_no_lint("x[order(y, x)]", linter)
  expect_no_lint("x[order(x, y)]", linter)
  # pretty sure this never makes sense, but test anyway
  expect_no_lint("x[order(y, na.last = x)]", linter)
})

test_that("sort_linter blocks simple disallowed usages", {
  linter <- sort_linter()

  expect_lint("x[order(x)]", "sort(x, na.last = TRUE) is better than", linter)

  # Works with extra args in order()
  expect_lint(
    "x[order(x, decreasing = TRUE)]",
    "sort(x, decreasing = TRUE, na.last = TRUE) is better than",
    linter
  )

  # ...even in disorder
  expect_lint(
    "x[order(decreasing = TRUE, x)]",
    "sort(x, decreasing = TRUE, na.last = TRUE) is better than",
    linter
  )

  expect_lint(
    "y + x[order(x)]",
    "sort(x, na.last = TRUE) is better than x[order(x)].",
    linter
  )

  # TODO
  # expect_lint(
  #   "f()[order(f())]",
  #   "sort(f(), na.last = TRUE) is better than f()[order(f())]",
  #   linter
  # )
})

test_that("sort_linter works with multiple lints in a single expression", {
  linter <- sort_linter()

  expect_equal(
    nrow(
      lint_text(
        "c(
      x[order(x)],
      y[order(y, decreasing = TRUE, na.last = FALSE)]
    )",
        linters = linter
      )
    ),
    2
  )
})

test_that("sort_linter skips usages calling sort arguments", {
  linter <- sort_linter()

  # any arguments to sort --> not compatible
  expect_no_lint("sort(x, decreasing = TRUE) == x", linter)
  expect_no_lint("sort(x, na.last = TRUE) != x", linter)
  expect_no_lint("sort(x, method_arg = TRUE) == x", linter)
})

test_that("sort_linter skips when inputs don't match", {
  linter <- sort_linter()

  expect_no_lint("sort(x) == y", linter)
  expect_no_lint("sort(x) == foo(x)", linter)
  expect_no_lint("sort(foo(x)) == x", linter)
})

test_that("sort_linter blocks simple disallowed usages", {
  linter <- sort_linter()
  unsorted_msg <- "Use is.unsorted(x) to test the unsortedness of a vector."
  sorted_msg <- "Use !is.unsorted(x) to test the sortedness of a vector."

  expect_lint("sort(x) == x", sorted_msg, linter)

  # argument order doesn't matter
  expect_lint("x == sort(x)", sorted_msg, linter)

  # inverted version
  expect_lint("sort(x) != x", unsorted_msg, linter)

  # TODO: expression matching
  # expect_lint("sort(foo(x)) == foo(x)", sorted_msg, linter)
})

test_that("lints vectorize", {
  expect_equal(
    nrow(
      lint_text(
        "{
      x == sort(x)
      y[order(y)]
    }",
        linters = sort_linter()
      )
    ),
    2
  )
})

test_that("fix works", {
  linter <- sort_linter()

  # order
  expect_snapshot(fix_text("y[order(y)]", linters = linter))
  expect_snapshot(fix_text("y[order(y, decreasing = FALSE)]", linters = linter))
  expect_snapshot(fix_text("y[order(y, na.last = FALSE)]", linters = linter))

  # sortedness
  expect_snapshot(fix_text("sort(x + y) == x + y", linters = linter))
  expect_snapshot(fix_text("sort(x + y) != x + y", linters = linter))
})
