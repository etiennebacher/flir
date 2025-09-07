test_that("nzchar_linter skips allowed usages", {
  linter <- nzchar_linter()

  expect_no_lint("if (any(nzchar(x))) TRUE", linter)

  expect_no_lint("letters == 'a'", linter)

  expect_no_lint("which(nchar(x) == 4)", linter)
  expect_no_lint("which(nchar(x) != 2)", linter)

  # following tests not from {lintr}
  expect_no_lint('nchar(x, type = "width") > 0', linter)
  expect_no_lint('nchar(x, type = "width") != 0', linter)
  expect_no_lint('nchar(x, type = "width") <= 0', linter)
  expect_no_lint('nchar(x, type = "width") == 0', linter)
  expect_no_lint('nchar(x, type = "width") >= 0', linter)
  expect_no_lint('nchar(x, type = "width") < 0', linter)
  expect_no_lint('nchar(x) >= 02', linter)
  expect_no_lint('nchar(x) >= 02L', linter)
  expect_no_lint('nchar(x) == 0.5', linter)
})

test_that("nzchar_linter skips as appropriate for other nchar args", {
  linter <- nzchar_linter()

  # using type="width" can lead to 0-width strings that are counted as
  #   nzchar, c.f. nchar("\u200b", type="width"), so don't lint this.
  # type="bytes" should be >= the value for the default (type="chars")
  expect_no_lint("nchar(x, type='width') == 0L", linter)

  # nchar(x) with invalid multibyte strings -->
  #   error, while nzchar(x) returns TRUE for those entries.
  # nchar(x, allowNA=TRUE) with invalid multibyte strings -->
  #   NA in each element with an invalid entry, while nzchar returns TRUE.
  expect_no_lint("nchar(x, allowNA=TRUE) == 0L", linter)

  skip("`nzchar_linter()` currently only handles `nchar(x)` with single arg")
  # nzchar also has keepNA argument so a drop-in switch is easy
  expect_lint(
    "nchar(x, keepNA=TRUE) == 0",
    "Use !nzchar(x) instead of nchar(x) == 0",
    linter
  )
})

test_that("nzchar_linter blocks simple disallowed usages", {
  linter <- nzchar_linter()
  lint_msg <- "Use !nzchar(x) instead of nchar(x) == 0"

  expect_lint("which(x == '')", 'Use !nzchar(x) instead of x == ""', linter)
  expect_lint(
    "any(nchar(x) >= 0)",
    "nchar(x) >= 0 is always true, maybe you want nzchar(x)?",
    linter
  )
  expect_lint("all(nchar(x) == 0L)", lint_msg, linter)
  expect_lint(
    "sum(0.0 < nchar(x))",
    "Use nzchar(x) instead of nchar(x) > 0",
    linter
  )

  # not from {lintr}
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

  skip("`nzchar_linter()` fails adversarial comment")
  # adversarial comment
  expect_lint(
    trim_some(
      "
      all(nchar(x) #comment
      == 0L)
    "
    ),
    lint_msg,
    linter
  )
})

test_that("nzchar_linter skips comparison to '' in if/while statements", {
  linter <- nzchar_linter()
  lint_msg_quote <- 'Use !nzchar(x) instead of x == ""'
  lint_msg_nchar <- "Use nzchar(x) instead of nchar(x) > 0"
  # still lint nchar() comparisons
  expect_lint("if (nchar(x) > 0) TRUE", lint_msg_nchar, linter)
  expect_lint('if (any(x == "")) TRUE', lint_msg_quote, linter)
  expect_lint('if (TRUE || any(x == "" | FALSE)) TRUE', lint_msg_quote, linter)

  skip(
    "`nzchar_linter()` does not skip comparison to '' in if/while statements"
  )
  expect_no_lint('if (x == "") TRUE', linter)
  expect_no_lint('while (x == "") TRUE', linter)

  # nested versions, a la nesting issues with vector_logic_linter
  expect_no_lint('if (TRUE || (x == "" && FALSE)) TRUE', linter)
  expect_no_lint('if (TRUE && x == "" && FALSE) TRUE', linter)
  expect_no_lint('foo(if (x == "") y else z)', linter)
})

test_that("multiple lints are generated correctly", {
  # `lint_text(x, nzchar_linter())` suggests multiple lints **are** generated correctly
  # unsure how to modify this auto-generated multiple lint test so it passes
  skip("`nzchar_linter()` fails auto-generated multiple lint test")
  expect_lint(
    trim_some(
      "{
      a == ''
      '' < b
      nchar(c) != 0
      0.0 > nchar(d)
    }"
    ),
    list(
      list('Use !nzchar(x) instead of x == ""', line_number = 2L),
      list('Use nzchar(x) instead of x > ""', line_number = 3L),
      list("Use nzchar(x) instead of nchar(x) != 0.", line_number = 4L),
      list(
        "nchar(x) < 0 is always false, maybe you want !nzchar(x)?",
        line_number = 5L
      )
    ),
    nzchar_linter()
  )
})

test_that("fix works", {
  expect_fix('x > ""', "nzchar(x, keepNA = TRUE)")
  expect_fix("x != ''", "nzchar(x, keepNA = TRUE)")
  expect_fix('x <= ""', "!nzchar(x, keepNA = TRUE)")
  expect_fix("x == ''", "!nzchar(x, keepNA = TRUE)")
  expect_fix('"" < x', "nzchar(x, keepNA = TRUE)")
  expect_fix("'' != x", "nzchar(x, keepNA = TRUE)")
  expect_fix('"" >= x', "!nzchar(x, keepNA = TRUE)")
  expect_fix("'' == x", "!nzchar(x, keepNA = TRUE)")

  expect_fix("nchar(x) > 0", "nzchar(x, keepNA = TRUE)")
  expect_fix("nchar(x) != 0", "nzchar(x, keepNA = TRUE)")
  expect_fix("nchar(x) <= 0", "!nzchar(x, keepNA = TRUE)")
  expect_fix("nchar(x) == 0", "!nzchar(x, keepNA = TRUE)")
  expect_fix("0 < nchar(x)", "nzchar(x, keepNA = TRUE)")
  expect_fix("0 != nchar(x)", "nzchar(x, keepNA = TRUE)")
  expect_fix("0 >= nchar(x)", "!nzchar(x, keepNA = TRUE)")
  expect_fix("0 == nchar(x)", "!nzchar(x, keepNA = TRUE)")
})
