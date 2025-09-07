test_that("list_comparison_linter skips allowed usages", {
  expect_no_lint("sapply(x, sum) > 10", list_comparison_linter())
})

local({
  linter <- list_comparison_linter()
  lint_msg <- "a list, is being coerced for comparison"

  cases <- expand.grid(
    list_mapper = c("lapply", "map", "Map", ".mapply"),
    comparator = c("==", "!=", ">=", "<=", ">", "<")
  )
  cases$.test_name <- with(cases, paste(list_mapper, comparator))
  patrick::with_parameters_test_that(
    "list_comparison_linter blocks simple disallowed usages",
    expect_lint(
      sprintf("%s(x, sum) %s 10", list_mapper, comparator),
      lint_msg,
      linter
    ),
    .cases = cases
  )
})

test_that("list_comparison_linter vectorizes", {
  expect_equal(
    nrow(
      lint_text(
        "{
      sapply(x, sum) > 10
      .mapply(`+`, list(1:10, 1:10), NULL) == 2
      lapply(x, sum) < 5
    }",
        linters = list_comparison_linter()
      )
    ),
    2
  )
})
