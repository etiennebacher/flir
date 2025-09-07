test_that("other : expressions are fine", {
  linter <- seq_linter()
  expect_no_lint("1:10", linter)
  expect_no_lint("2:length(x)", linter)
  expect_no_lint("1:(length(x) || 1)", linter)
  expect_no_lint("2L:length(x)", linter)
})

test_that("seq_len(...) or seq_along(...) expressions are fine", {
  linter <- seq_linter()

  expect_no_lint("seq_len(x)", linter)
  expect_no_lint("seq_along(x)", linter)

  expect_no_lint("seq(2, length(x))", linter)
  expect_no_lint("seq(length(x), 2)", linter)
})

test_that("finds seq(...) expressions", {
  linter <- seq_linter()
  lint_msg <- function(want, got) {
    paste0(
      got,
      " is likely to be wrong in the empty edge case. Use ",
      want,
      " instead"
    )
  }

  expect_lint(
    "seq(length(x))",
    lint_msg("seq_along(...)", "seq(length(...))"),
    linter
  )

  expect_lint(
    "seq(nrow(x))",
    lint_msg("seq_len(nrow(...))", "seq(nrow(...))"),
    linter
  )

  expect_lint(
    "rev(seq(length(x)))",
    lint_msg("seq_along(...)", "seq(length(...))"),
    linter
  )

  expect_lint(
    "rev(seq(nrow(x)))",
    lint_msg("seq_len(nrow(...))", "seq(nrow(...))"),
    linter
  )
})

test_that("finds 1:length(...) expressions", {
  linter <- seq_linter()
  lint_msg <- function(want, got) {
    paste0(
      got,
      " is likely to be wrong in the empty edge case. Use ",
      want,
      " instead"
    )
  }

  expect_lint(
    "1:length(x)",
    lint_msg("seq_along(...)", "1:length(...)"),
    linter
  )

  expect_lint(
    "1:nrow(x)",
    lint_msg("seq_len(nrow(...))", "1:nrow(...)"),
    linter
  )
  expect_no_lint("2:nrow(x)", linter)

  expect_lint(
    "1:ncol(x)",
    lint_msg("seq_len(ncol(...))", "1:ncol(...)"),
    linter
  )
  expect_no_lint("2:ncol(x)", linter)

  expect_lint(
    "1:NROW(x)",
    lint_msg("seq_len(NROW(...))", "1:NROW(...)"),
    linter
  )
  expect_no_lint("2:NROW(x)", linter)

  expect_lint(
    "1:NCOL(x)",
    lint_msg("seq_len(NCOL(...))", "1:NCOL(...)"),
    linter
  )
  expect_no_lint("2:NCOL(x)", linter)

  # expect_lint(
  #   "1:dim(x)[1L]",
  #   lint_msg("seq_len(dim(...)[1L])", "1:dim(...)[1L]"),
  #   linter
  # )
  #
  # expect_lint(
  #   "1L:dim(x)[[1]]",
  #   rex::rex("Use seq_len", anything, "dim(...)"),
  #   linter
  # )

  expect_lint(
    "mutate(x, .id = 1:n())",
    lint_msg("seq_len(n())", "1:n()"),
    linter
  )

  # expect_lint(
  #   "x[, .id := 1:.N]",
  #   lint_msg("seq_len(.N)", "1:.N,"),
  #   linter
  # )
})

test_that("1L is also bad", {
  expect_lint(
    "1L:length(x)",
    "1:length(...) is likely to be wrong in the empty edge case. Use seq_along(...) instead.",
    seq_linter()
  )
})

# test_that("reverse seq is ok", {
#   linter <- seq_linter()
#   expect_lint("rev(seq_along(x))", NULL, linter)
#   expect_lint("rev(seq_len(nrow(x)))", NULL, linter)
#
#   expect_lint(
#     "length(x):1",
#     rex::rex("rev(seq_along(...))", anything, "length(...):1"),
#     linter
#   )
# })

# test_that("Message recommends rev() correctly", {
#   linter <- seq_linter()
#
#   expect_lint(".N:1", rex::rex("Use rev(seq_len(.N))"), linter)
#   expect_lint("n():1", rex::rex("Use rev(seq_len(n()))"), linter)
#   expect_lint("nrow(x):1", rex::rex("Use rev(seq_len(nrow(...)))"), linter)
#   expect_lint("length(x):1", rex::rex("Use rev(seq_along(...))"), linter)
# })

test_that("fix 1:length(...) expressions", {
  expect_snapshot(fix_text("1:length(x)"))
  expect_snapshot(fix_text("1:nrow(x)"))
  expect_snapshot(fix_text("1:ncol(x)"))
  expect_snapshot(fix_text("1:NROW(x)"))
  expect_snapshot(fix_text("1:NCOL(x)"))

  expect_snapshot(fix_text("2:length(x)"))
  expect_snapshot(fix_text("2:nrow(x)"))
  expect_snapshot(fix_text("2:ncol(x)"))
  expect_snapshot(fix_text("2:NROW(x)"))
  expect_snapshot(fix_text("2:NCOL(x)"))

  expect_snapshot(fix_text("2L:length(x)"))
  expect_snapshot(fix_text("2L:nrow(x)"))
  expect_snapshot(fix_text("2L:ncol(x)"))
  expect_snapshot(fix_text("2L:NROW(x)"))
  expect_snapshot(fix_text("2L:NCOL(x)"))

  # expect_lint(
  #   "1:dim(x)[1L]",
  #   lint_msg("seq_len(dim(...)[1L])", "1:dim(...)[1L]"),
  #   linter
  # )
  #
  # expect_lint(
  #   "1L:dim(x)[[1]]",
  #   rex::rex("Use seq_len", anything, "dim(...)"),
  #   linter
  # )

  expect_snapshot(fix_text("mutate(x, .id = 1:n())"))

  # expect_lint(
  #   "x[, .id := 1:.N]",
  #   lint_msg("seq_len(.N)", "1:.N,"),
  #   linter
  # )
})

test_that("fix seq(...) expressions", {
  expect_snapshot(fix_text("seq(length(x))"))
  expect_snapshot(fix_text("seq(nrow(x))"))
  expect_snapshot(fix_text("seq(1, 100)"))
  expect_snapshot(fix_text("rev(seq(length(x)))"))
  expect_snapshot(fix_text("rev(seq(nrow(x)))"))
})

test_that("seq(1, x) is blocked if x > 0", {
  linter <- seq_linter()
  msg <- "is more efficient"

  expect_no_lint("seq(1, NA)", linter)
  expect_no_lint("seq(1, -1)", linter)
  expect_no_lint("seq(1, 0)", linter)
  expect_no_lint("seq(2, 5)", linter)

  expect_lint("seq(1, 1)", msg, linter)
  expect_lint("seq(1, 1L)", msg, linter)
  expect_lint("seq(1, 10)", msg, linter)
})
