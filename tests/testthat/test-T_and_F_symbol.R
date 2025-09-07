test_that("T_and_F_symbol_linter skips allowed usages", {
  linter <- T_and_F_symbol_linter()

  expect_no_lint("FALSE", linter)
  expect_no_lint("TRUE", linter)
  expect_no_lint("F()", linter)
  expect_no_lint("T()", linter)
  expect_no_lint("x <- \"TRUE a vs FALSE b\"", linter)
})

test_that("T_and_F_symbol_linter is correct in formulas", {
  linter <- T_and_F_symbol_linter()

  expect_no_lint("lm(weight ~ T, data)", linter)
  expect_no_lint("lm(weight ~ F, data)", linter)
  expect_no_lint("lm(weight ~ T + var, data)", linter)
  expect_no_lint("lm(weight ~ A + T | var, data)", linter)
  expect_no_lint("lm(weight ~ var | A + T, data)", linter)
  expect_no_lint("lm(weight ~ var + var2 + T, data)", linter)
  expect_no_lint("lm(T ~ weight, data)", linter)

  expect_lint(
    "lm(weight ~ var + foo(x, arg = T), data)",
    "Use TRUE instead of the symbol T.",
    linter
  )
})

# https://github.com/etiennebacher/flir/issues/80
test_that("T_and_F_symbol_linter not applied if part of `:`", {
  linter <- T_and_F_symbol_linter()

  expect_no_lint("A:T", linter)
  expect_no_lint("A:F", linter)
  expect_no_lint("T:A", linter)
  expect_no_lint("F:A", linter)
  expect_no_lint("f(F:A)", linter)
})

test_that("T_and_F_symbol_linter blocks disallowed usages", {
  linter <- T_and_F_symbol_linter()
  msg_true <- "Use TRUE instead of the symbol T."
  msg_false <- "Use FALSE instead of the symbol F."
  msg_variable_true <- "Don't use T as a variable name, as it can break code relying on T being TRUE."
  msg_variable_false <- "Don't use F as a variable name, as it can break code relying on F being FALSE."

  expect_no_lint("'T <- 1'", linter)
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
  expect_no_lint("mtcars$F", linter)
  expect_no_lint("mtcars$T", linter)
})

test_that("do not block parameters named T/F", {
  linter <- T_and_F_symbol_linter()
  expect_no_lint("myfun <- function(T) {}", linter)
  expect_no_lint("myfun <- function(F) {}", linter)
})

test_that("do not block vector names T/F", {
  linter <- T_and_F_symbol_linter()
  expect_no_lint("c(T = 'foo', F = 'foo')", linter)
})

test_that("don't replace T/F when they receive the assignment", {
  expect_snapshot(fix_text("T <- N/G"))
  expect_snapshot(fix_text("F <- N/G"))
})
