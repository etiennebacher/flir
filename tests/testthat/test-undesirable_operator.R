test_that("linter returns correct linting", {
  linter <- undesirable_operator_linter()
  msg_assign <- "Avoid undesirable operators `<<-` and `->>`"

  expect_no_lint("cat(\"10$\")", linter)
  expect_lint(
    "a <<- log(10)",
    msg_assign,
    linter
  )
  expect_lint(
    "log(10) ->> a",
    msg_assign,
    linter
  )
})

test_that(":: is ok, ::: is not", {
  linter <- undesirable_operator_linter()
  expect_lint("a:::b", "Operator `:::` is undesirable", linter)
  expect_no_lint("a::b", linter)
})

test_that("undesirable_operator_linter vectorizes messages", {
  expect_equal(
    nrow(
      lint_text(
        "x <<- c(pkg:::foo, bar = baz)",
        linters = undesirable_operator_linter()
      )
    ),
    2
  )
})
