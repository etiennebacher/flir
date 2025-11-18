test_that("redundant_equals_linter skips allowed usages", {
  # comparisons to non-logical constants
  expect_no_lint("x == 1", redundant_equals_linter())
  # comparison to TRUE as a string
  expect_no_lint("x != 'TRUE'", redundant_equals_linter())
})

test_that("multiple lints return correct custom messages", {
  expect_equal(
    nrow(
      lint_text(
        "
      list(
        x == TRUE,
        y != TRUE
      )
    ",
        linters = redundant_equals_linter()
      )
    ),
    2
  )
})

test_that("Order doesn't matter", {
  expect_lint(
    "TRUE == x",
    "Using == on a logical vector is redundant.",
    redundant_equals_linter()
  )
})

patrick::with_parameters_test_that(
  "redundant_equals_linter blocks simple disallowed usages",
  {
    lint_msg <- paste("Using", op, "on a logical vector is redundant.")
    code <- paste("x", op, bool)
    expect_lint(code, lint_msg, redundant_equals_linter())
  },
  .cases = tibble::tribble(
    ~.test_name , ~op  , ~bool   ,
    "==, TRUE"  , "==" , "TRUE"  ,
    "==, FALSE" , "==" , "FALSE" ,
    "!=, TRUE"  , "!=" , "TRUE"  ,
    "!=, FALSE" , "!=" , "FALSE"
  )
)
