test_that("T_and_F_symbol_linter skips allowed usages", {
  linter <- T_and_F_symbol_linter()

  expect_lint("FALSE", NULL, linter)
  expect_lint("TRUE", NULL, linter)
  expect_lint("F()", NULL, linter)
  expect_lint("T()", NULL, linter)
  expect_lint("x <- \"TRUE a vs FALSE b\"", NULL, linter)
})

test_that("T_and_F_symbol_linter is correct in formulas", {
  linter <- T_and_F_symbol_linter()

  expect_lint("lm(weight ~ T, data)", NULL, linter)
  expect_lint("lm(weight ~ F, data)", NULL, linter)
  expect_lint("lm(weight ~ T + var, data)", NULL, linter)
  expect_lint("lm(weight ~ A + T | var, data)", NULL, linter)
  expect_lint("lm(weight ~ var | A + T, data)", NULL, linter)
  expect_lint("lm(weight ~ var + var2 + T, data)", NULL, linter)
  expect_lint("lm(T ~ weight, data)", NULL, linter)

  expect_lint(
    "lm(weight ~ var + foo(x, arg = T), data)",
    "Use TRUE instead of the symbol T.",
    linter
  )
})

# https://github.com/etiennebacher/flir/issues/80
test_that("T_and_F_symbol_linter not applied if part of `:`", {
  linter <- T_and_F_symbol_linter()

  expect_lint("A:T", NULL, linter)
  expect_lint("A:F", NULL, linter)
  expect_lint("T:A", NULL, linter)
  expect_lint("F:A", NULL, linter)
  expect_lint("f(F:A)", NULL, linter)
})

test_that("T_and_F_symbol_linter blocks disallowed usages", {
  linter <- T_and_F_symbol_linter()
  msg_true <- "Use TRUE instead of the symbol T."
  msg_false <- "Use FALSE instead of the symbol F."
  msg_variable_true <- "Don't use T as a variable name, as it can break code relying on T being TRUE."
  msg_variable_false <- "Don't use F as a variable name, as it can break code relying on F being FALSE."

  expect_lint("'T <- 1'", NULL, linter)
  expect_lint("T", msg_true, linter)
  expect_lint("F", msg_false, linter)
  expect_lint("T = 42", msg_variable_true, linter)
  expect_lint("F = 42", msg_variable_false, linter)
  expect_lint(
    "for (i in 1:10) {x <- c(T, TRUE, F, FALSE)}",
    msg_true,
    linter
  )
  expect_lint(
    "for (i in 1:10) {x <- c(T, TRUE, F, FALSE)}",
    msg_false,
    linter
  )

  expect_lint("DF$bool <- T", msg_true, linter)
  expect_lint("S4@bool <- T", msg_true, linter)
  expect_lint("sum(x, na.rm = T)", msg_true, linter)

  # Regression test for #657
  expect_lint(
    trim_some(
      "
      x <- list(
        T = 42L,
        F = 21L
      )

      x$F <- 42L
      y@T <- 84L

      T <- \"foo\"
      F = \"foo2\"
      \"foo3\" -> T
    "
    ),
    msg_variable_true,
    linter
  )
  expect_lint(
    trim_some(
      "
      x <- list(
        T = 42L,
        F = 21L
      )

      x$F <- 42L
      y@T <- 84L

      T <- \"foo\"
      F = \"foo2\"
      \"foo3\" -> T
    "
    ),
    msg_variable_false,
    linter
  )
})

test_that("T_and_F_symbol_linter doesn't block variables called T or F", {
  linter <- T_and_F_symbol_linter()
  expect_lint("mtcars$F", NULL, linter)
  expect_lint("mtcars$T", NULL, linter)
})

test_that("do not block parameters named T/F", {
  linter <- T_and_F_symbol_linter()
  expect_lint("myfun <- function(T) {}", NULL, linter)
  expect_lint("myfun <- function(F) {}", NULL, linter)
})

test_that("do not block vector names T/F", {
  linter <- T_and_F_symbol_linter()
  expect_lint("c(T = 'foo', F = 'foo')", NULL, linter)
})

test_that("don't replace T/F when they receive the assignment", {
  expect_snapshot(fix_text("T <- N/G"))
  expect_snapshot(fix_text("F <- N/G"))
})
