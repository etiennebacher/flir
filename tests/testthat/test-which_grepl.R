test_that("which_grepl_linter skips allowed usages", {
  # this _could_ be combined as p1|p2, but often it's cleaner to read this way
  expect_no_lint("which(grepl(p1, x) | grepl(p2, x))", which_grepl_linter())
})

test_that("which_grepl_linter blocks simple disallowed usages", {
  linter <- which_grepl_linter()
  lint_msg <- "grep(pattern, x) is better than which(grepl(pattern, x))."

  expect_lint("which(grepl('^a', x))", lint_msg, linter)
  # options also don't matter (grep has more arguments: value, invert)
  expect_lint(
    "which(grepl('^a', x, perl = TRUE, fixed = TRUE))",
    lint_msg,
    linter
  )

  expect_equal(
    nrow(
      lint_text(
        trim_some(
          '{
      which(x)
      grepl(y)
      which(grepl("pt1", x))
      which(grepl("pt2", y))
    }'
        ),
        linters = linter
      )
    ),
    2
  )
})

test_that("fix works", {
  linter <- which_grepl_linter()
  expect_snapshot(fix_text("which(grepl('^a', x))", linters = linter))
  expect_snapshot(
    fix_text("which(grepl('^a', x, ignore.case = TRUE))", linters = linter)
  )
})
