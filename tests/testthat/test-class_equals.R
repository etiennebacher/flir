test_that("class_equals_linter skips allowed usages", {
  linter <- class_equals_linter()

  expect_no_lint("class(x) <- 'character'", linter)
  expect_no_lint("class(x) = 'character'", linter)

  # proper way to test exact class
  expect_no_lint("identical(class(x), c('glue', 'character'))", linter)
  expect_no_lint("is_lm <- inherits(x, 'lm')", linter)
})

# https://github.com/vincentarelbundock/marginaleffects/pull/1171#issuecomment-2228497287
# inherits() returns TRUE if any of the classes match
test_that("all(inherits()) not the same as all(x %in% y)", {
  linter <- class_equals_linter()
  expect_no_lint("isTRUE(all(sup %in% class(model)))", linter)
})

test_that("class_equals_linter blocks simple disallowed usages", {
  linter <- class_equals_linter()
  lint_msg <- "use inherits"

  expect_lint("if (class(x) == 'character') stop('no')", lint_msg, linter)
  expect_lint("is_regression <- class(x) == 'lm'", lint_msg, linter)
  expect_lint("is_regression <- 'lm' == class(x)", lint_msg, linter)
})

test_that("using double quotes is the same", {
  linter <- class_equals_linter()
  lint_msg <- "use inherits"
  expect_lint("if (class(x) == \"character\") stop('no')", lint_msg, linter)
})

test_that("class_equals_linter blocks usage of %in% for checking class", {
  linter <- class_equals_linter()
  lint_msg <- "use inherits"

  expect_lint("if ('character' %in% class(x)) stop('no')", lint_msg, linter)
  expect_lint("if (class(x) %in% 'character') stop('no')", lint_msg, linter)
})

test_that("class_equals_linter blocks class(x) != 'klass'", {
  expect_lint(
    "if (class(x) != 'character') TRUE",
    "use !inherits",
    NULL
  )
})

# as seen, e.g. in base R
test_that("class_equals_linter skips usage for subsetting", {
  linter <- class_equals_linter()

  expect_no_lint("class(x)[class(x) == 'foo']", linter)

  # but not further nesting
  expect_lint(
    "x[if (class(x) == 'foo') 1 else 2]",
    "use inherits",
    linter
  )
})

test_that("!= detected", {
  linter <- class_equals_linter()
  expect_lint("class(x) != 'lm'", "use !inherits", linter)
})

test_that("fix works", {
  expect_snapshot(fix_text("class(x) == 'character'"))
  expect_snapshot(fix_text("\"class(x) == 'character'\""))
  expect_snapshot(fix_text("class(x) != 'character'"))
  expect_snapshot(fix_text("\"class(x) != 'character'\""))

  expect_snapshot(fix_text("'character' %in% class(x)"))
  expect_snapshot(fix_text("\"'character' %in% class(x)\""))
  expect_snapshot(fix_text("!'character' %in% class(x)"))
  expect_snapshot(fix_text("! 'character' %in% class(x)"))
  expect_snapshot(fix_text("!('character' %in% class(x))"))
})
