test_that("empty_assignment_linter skips valid usage", {
  expect_no_lint("x <- { 3 + 4 }", empty_assignment_linter())
  expect_no_lint("x <- if (x > 1) { 3 + 4 }", empty_assignment_linter())

  # also triggers assignment_linter
  expect_no_lint("x = { 3 + 4 }", empty_assignment_linter())
})

test_that("empty_assignment_linter blocks disallowed usages", {
  linter <- empty_assignment_linter()
  lint_msg <- "Assign NULL explicitly or, whenever possible, allocate the empty object"

  expect_lint("xrep <- {}", lint_msg, linter)

  # assignment with equal works as well, and white space doesn't matter
  expect_lint("x = {   }", lint_msg, linter)

  # ditto right assignments
  # expect_lint("{} -> x", lint_msg, linter)
  # expect_lint("{} ->> x", lint_msg, linter)

  # ditto data.table-style walrus assignments
  # expect_lint("x[, col := {}]", lint_msg, linter)

  # newlines also don't matter
  expect_lint("x <- {\n}", lint_msg, linter)

  # LHS of assignment doesn't matter
  expect_lint("env$obj <- {}", lint_msg, linter)
})

test_that("lints vectorize", {
  lint_msg <- "Assign NULL explicitly or, whenever possible, allocate the empty object"

  expect_equal(
    nrow(
      lint_text(
        "{
      x <- {}
      y = {}
    }",
        linters = empty_assignment_linter()
      )
    ),
    2
  )
})
