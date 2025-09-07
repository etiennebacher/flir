test_that("stopifnot_all_linter skips allowed usages", {
  expect_no_lint("stopifnot(all(x) || any(y))", stopifnot_all_linter())
})

# TODO
# test_that("stopifnot_all_linter blocks simple disallowed usages", {
#   linter <- stopifnot_all_linter()
#   lint_msg <- "Use stopifnot(x) instead of"

#   expect_lint("stopifnot(all(A))", lint_msg, linter)
#   expect_lint("stopifnot(x, y, all(z))", lint_msg, linter)

#   expect_lint(
#     trim_some("{
#       stopifnot(all(x), all(y),
#         all(z)
#       )
#       stopifnot(a > 0, b < 0, all(c == 0))
#     }"),
#     list(
#       list(lint_msg, line_number = 2L, column_number = 13L),
#       list(lint_msg, line_number = 2L, column_number = 21L),
#       list(lint_msg, line_number = 3L, column_number = 5L),
#       list(lint_msg, line_number = 5L, column_number = 27L)
#     ),
#     linter
#   )
# })

test_that("fix works", {
  linter <- stopifnot_all_linter()
  expect_snapshot(
    fix_text("stopifnot(all(x > 0 & y < 1))", linters = linter)
  )

  lines <- "
stopifnot(exprs = {
  all(x > 0 & y < 1)
})"
  expect_snapshot(fix_text(lines, linters = linter))
})
