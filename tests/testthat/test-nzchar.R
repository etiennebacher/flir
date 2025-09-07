test_that("nzchar_linter skips allowed usages", {
  linter <- nzchar_linter()

  expect_lint('nchar(x, type = "width") > 0', NULL, linter)
  expect_lint('nchar(x, type = "width") != 0', NULL, linter)
  expect_lint('nchar(x, type = "width") <= 0', NULL, linter)
  expect_lint('nchar(x, type = "width") == 0', NULL, linter)
  expect_lint('nchar(x, type = "width") >= 0', NULL, linter)
  expect_lint('nchar(x, type = "width") < 0', NULL, linter)
  expect_lint('nchar(x) >= 02', NULL, linter)
  expect_lint('nchar(x) >= 02L', NULL, linter)
  expect_lint('nchar(x) == 0.5', NULL, linter)
})

test_that("nzchar_linter blocks simple disallowed usages", {
  linter <- nzchar_linter()

  lint_msg <- 'Use nzchar(x) instead of x > "".'
  expect_lint('x > ""', lint_msg, linter)
  expect_lint("x > ''", lint_msg, linter)
  expect_lint('"" < x', lint_msg, linter)
  lint_msg <- 'Use nzchar(x) instead of x != "".'
  expect_lint('x != ""', lint_msg, linter)
  expect_lint("x != ''", lint_msg, linter)
  expect_lint('"" != x', lint_msg, linter)
  lint_msg <- 'Use !nzchar(x) instead of x <= "".'
  expect_lint('x <= ""', lint_msg, linter)
  expect_lint('"" >= x', lint_msg, linter)
  lint_msg <- 'Use !nzchar(x) instead of x == "".'
  expect_lint('x == ""', lint_msg, linter)
  expect_lint("x == ''", lint_msg, linter)
  expect_lint("'' == x", lint_msg, linter)
  lint_msg <- 'x >= "" is always true, maybe you want nzchar(x)?'
  expect_lint('x >= ""', lint_msg, linter)
  expect_lint('"" <= x', lint_msg, linter)
  lint_msg <- 'x < "" is always false, maybe you want !nzchar(x)?'
  expect_lint('x < ""', lint_msg, linter)
  expect_lint('"" > x', lint_msg, linter)

  lint_msg <- 'Use nzchar(x) instead of nchar(x) > 0.'
  expect_lint('nchar(x) > 0', lint_msg, linter)
  expect_lint("nchar(x) > 0L", lint_msg, linter)
  expect_lint("nchar(x) > 0.0", lint_msg, linter)
  expect_lint('0 < nchar(x)', lint_msg, linter)
  lint_msg <- 'Use nzchar(x) instead of nchar(x) != 0.'
  expect_lint('nchar(x) != 0', lint_msg, linter)
  expect_lint('0 != nchar(x)', lint_msg, linter)
  lint_msg <- 'Use !nzchar(x) instead of nchar(x) <= 0.'
  expect_lint('nchar(x) <= 0', lint_msg, linter)
  expect_lint('0 >= nchar(x)', lint_msg, linter)
  lint_msg <- 'Use !nzchar(x) instead of nchar(x) == 0.'
  expect_lint('nchar(x) == 0', lint_msg, linter)
  expect_lint('0 == nchar(x)', lint_msg, linter)
  lint_msg <- 'nchar(x) >= 0 is always true, maybe you want nzchar(x)?'
  expect_lint('nchar(x) >= 0', lint_msg, linter)
  expect_lint('0 <= nchar(x)', lint_msg, linter)
  lint_msg <- 'nchar(x) < 0 is always false, maybe you want !nzchar(x)?'
  expect_lint('nchar(x) < 0', lint_msg, linter)
  expect_lint('0 > nchar(x)', lint_msg, linter)
})

test_that("fix works", {
  expect_fix('x > ""',  "nzchar(x, keepNA = TRUE)")
  expect_fix("x != ''", "nzchar(x, keepNA = TRUE)")
  expect_fix('x <= ""', "!nzchar(x, keepNA = TRUE)")
  expect_fix("x == ''", "!nzchar(x, keepNA = TRUE)")
  expect_fix('"" < x',  "nzchar(x, keepNA = TRUE)")
  expect_fix("'' != x", "nzchar(x, keepNA = TRUE)")
  expect_fix('"" >= x', "!nzchar(x, keepNA = TRUE)")
  expect_fix("'' == x", "!nzchar(x, keepNA = TRUE)")

  expect_fix("nchar(x) > 0",  "nzchar(x, keepNA = TRUE)")
  expect_fix("nchar(x) != 0", "nzchar(x, keepNA = TRUE)")
  expect_fix("nchar(x) <= 0", "!nzchar(x, keepNA = TRUE)")
  expect_fix("nchar(x) == 0", "!nzchar(x, keepNA = TRUE)")
  expect_fix("0 < nchar(x)",  "nzchar(x, keepNA = TRUE)")
  expect_fix("0 != nchar(x)", "nzchar(x, keepNA = TRUE)")
  expect_fix("0 >= nchar(x)", "!nzchar(x, keepNA = TRUE)")
  expect_fix("0 == nchar(x)", "!nzchar(x, keepNA = TRUE)")
})
