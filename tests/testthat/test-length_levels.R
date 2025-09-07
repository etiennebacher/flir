test_that("length_levels_linter skips allowed usages", {
  expect_no_lint("length(c(levels(x), 'a'))", length_levels_linter())
})

test_that("length_levels_linter blocks simple disallowed usages", {
  expect_lint(
    "2:length(levels(x))",
    "nlevels(x) is better than length(levels(x)).",
    length_levels_linter()
  )
})

test_that("fix works", {
  expect_fix("2:length(levels(x))", "2:nlevels(x)")
  expect_snapshot(fix_text("{\n  length(levels(x))\n  length(levels(y))\n}"))
})
