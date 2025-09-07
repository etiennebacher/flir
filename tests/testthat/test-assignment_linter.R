test_that("assignment_linter skips allowed usages", {
  linter <- NULL

  expect_no_lint("blah", linter)
  expect_no_lint("blah <- 1", linter)
  expect_no_lint("blah<-1", linter)
  expect_no_lint("fun(blah=1)", linter)
})

test_that("assignment_linter blocks disallowed usages", {
  linter <- NULL
  lint_msg <- "Use <-, not =, for assignment."

  expect_lint("blah=1", lint_msg, linter)
  expect_lint("blah = 1", lint_msg, linter)
  expect_lint("blah = fun(1)", lint_msg, linter)
  expect_lint("fun((blah = fun(1)))", lint_msg, linter)

  expect_lint("blah = fun(1) {", lint_msg, linter)
})

test_that("arguments handle <<- and ->/->> correctly", {
  expect_lint("1 -> blah", "Use <-, not ->, for assignment.", NULL)
  expect_lint("1 ->> blah", "->> can have hard-to-predict behavior;", NULL)
  expect_lint("blah <<- blah", "<<- can have hard-to-predict behavior;", NULL)

  # <<- is only blocked optionally
  # expect_lint("1 <<- blah", NULL, NULL)
  # expect_lint(
  #   "1 <<- blah",
  #   "<<- can have hard-to-predict behavior;",
  #   assignment_linter(allow_cascading_assign = FALSE)
  # )

  # # blocking -> can be disabled
  # expect_lint("1 -> blah", NULL, assignment_linter(allow_right_assign = TRUE))
  # expect_lint("1 ->> blah", NULL, assignment_linter(allow_right_assign = TRUE))
  # # blocked under cascading assign but not under right assign --> blocked
  # expect_lint(
  #   "1 ->> blah",
  #   "->> can have hard-to-predict behavior;",
  #   assignment_linter(allow_cascading_assign = FALSE, allow_right_assign = TRUE)
  # )
})
#
# test_that("arguments handle trailing assignment operators correctly", {
#   expect_lint("x <- y", NULL, assignment_linter(allow_trailing = FALSE))
#   expect_lint("foo(bar = 1)", NULL, assignment_linter(allow_trailing = FALSE))
#
#   expect_lint(
#     "foo(bar =\n1)",
#     "= should not be trailing at the end of a line.",
#     assignment_linter(allow_trailing = FALSE)
#   )
#
#   expect_lint(
#     "x <<-\ny",
#     "<<- should not be trailing",
#     assignment_linter(allow_trailing = FALSE)
#   )
#   expect_lint(
#     "x <<-\ny",
#     "<<- can have hard-to-predict behavior",
#     assignment_linter(allow_trailing = FALSE, allow_cascading_assign = FALSE)
#   )
#
#   expect_lint(
#     "x <- #Test \ny",
#     "<- should not be trailing",
#     assignment_linter(allow_trailing = FALSE)
#   )
#
#   expect_lint(
#     "is_long <-\nis %>%\ngather(measure, value, -Species) %>%\narrange(-value)",
#     NULL,
#     NULL
#   )
#   expect_lint(
#     "is_long <-\nis %>%\ngather(measure, value, -Species) %>%\narrange(-value)",
#     "<- should not be trailing",
#     assignment_linter(allow_trailing = FALSE)
#   )
#
#   expect_lint(
#     "is %>%\ngather(measure, value, -Species) %>%\narrange(-value) ->\nis_long",
#     "Use <-, not ->",
#     NULL
#   )
#   expect_lint(
#     "is %>%\ngather(measure, value, -Species) %>%\narrange(-value) ->\nis_long",
#     "Use <-, not ->",
#     assignment_linter(allow_trailing = FALSE)
#   )
#   expect_lint(
#     "is %>%\ngather(measure, value, -Species) %>%\narrange(-value) ->\nis_long",
#     "-> should not be trailing",
#     assignment_linter(allow_right_assign = TRUE, allow_trailing = FALSE)
#   )
#
#   expect_lint(
#     "\n\nblah=\n42\nblh2<-\n54",
#     list(
#       list(message = "=", line_number = 3L, column_number = 5L),
#       list(message = "<-", line_number = 5L, column_number = 5L)
#     ),
#     assignment_linter(allow_trailing = FALSE)
#   )
# })
#
# test_that("allow_trailing interacts correctly with comments in braced expressions", {
#   linter <- assignment_linter(allow_trailing = FALSE)
#   expect_lint(
#     trim_some("
#     {
#       x <- 1
#       # blah
#       y <- 2
#     }
#     "),
#     NULL,
#     linter
#   )
#
#   expect_lint(
#     trim_some("
#     {
#       x <- '#x'
#       y <- '#y'
#     }
#     "),
#     NULL,
#     linter
#   )
#
#   expect_lint(
#     trim_some("
#     {
#       x <- # blah
#         'x'
#     }
#     "),
#     list(message = "<-", line_number = 2L),
#     linter
#   )
#
#   expect_lint(
#     trim_some("
#     {
#       x <- '
#         a string
#         with an assignment <-
#         at the end of the line
#       '
#     }
#     "),
#     NULL,
#     linter
#   )
# })
#
# test_that("%<>% throws a lint", {
#   expect_lint("x %<>% sum()", "Avoid the assignment pipe %<>%", NULL)
#   expect_lint("x %<>% sum()", NULL, assignment_linter(allow_pipe_assign = TRUE))
#
#   # interaction with allow_trailing
#   expect_lint("x %<>%\n  sum()", "Assignment %<>% should not be trailing", assignment_linter(allow_trailing = FALSE))
# })
#
# test_that("multiple lints throw correct messages", {
#   expect_lint(
#     "{ x <<- 1; y ->> 2; z -> 3; x %<>% as.character() }",
#     list(
#       list(message = "<<- can have hard-to-predict behavior"),
#       list(message = "->> can have hard-to-predict behavior"),
#       list(message = "Use <-, not ->"),
#       list(message = "Avoid the assignment pipe %<>%")
#     ),
#     assignment_linter(allow_cascading_assign = FALSE)
#   )
# })
