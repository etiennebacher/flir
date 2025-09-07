test_that("redundant_ifelse_linter skips allowed usages", {
  linter <- redundant_ifelse_linter()

  expect_no_lint("ifelse(x > 5, 0, 2)", linter)
  expect_no_lint("ifelse(x > 5, TRUE, NA)", linter)
  expect_no_lint("ifelse(x > 5, FALSE, NA)", linter)
  expect_no_lint("ifelse(x > 5, TRUE, TRUE)", linter)

  expect_no_lint("ifelse(x > 5, 0L, 2L)", linter)
  expect_no_lint("ifelse(x > 5, 0L, 10L)", linter)
})

test_that("redundant_ifelse_linter blocks simple disallowed usages", {
  linter <- redundant_ifelse_linter()

  expect_lint(
    "ifelse(x > 5, TRUE, FALSE)",
    "Use x > 5",
    linter
  )
  expect_lint(
    "ifelse(x > 5, FALSE, TRUE)",
    "!(x > 5)",
    linter
  )

  # other ifelse equivalents from common packages
  expect_lint(
    "if_else(x > 5, TRUE, FALSE)",
    "Use x > 5 directly instead of calling if_else(x > 5, TRUE, FALSE).",
    linter
  )
  expect_lint(
    "fifelse(x > 5, FALSE, TRUE)",
    "Use !(x > 5) directly instead of calling fifelse(x > 5, FALSE, TRUE).",
    linter
  )
})

test_that("redundant_ifelse_linter blocks usages equivalent to as.numeric, optionally", {
  linter <- redundant_ifelse_linter()

  expect_lint(
    "ifelse(x > 5, 1L, 0L)",
    "Prefer as.integer(x > 5) to ifelse(x > 5, 1L, 0L)",
    linter
  )
  expect_lint(
    "ifelse(x > 5, 0L, 1L)",
    "Prefer as.integer(!(x > 5)) to ifelse(x > 5, 0L, 1L)",
    linter
  )

  # expect_lint(
  #   "ifelse(x > 5, 1, 0)",
  #   "Prefer as.numeric(x) to ifelse(x, 1, 0)",
  #   linter
  # )
  # expect_lint(
  #   "ifelse(x > 5, 0, 1)",
  #   "Prefer as.numeric(!x) to ifelse(x, 0, 1)",
  #   linter
  # )

  # mixing int and num
  expect_lint(
    "ifelse(x > 5, 0, 1L)",
    "Prefer as.integer(!(x > 5)) to ifelse(x > 5, 0, 1L)",
    linter
  )
  expect_lint(
    "ifelse(x > 5, 0L, 1)",
    "Prefer as.integer(!(x > 5)) to ifelse(x > 5, 0L, 1)",
    linter
  )
  expect_lint(
    "ifelse(x > 5, 1, 0L)",
    "Prefer as.integer(x > 5) to ifelse(x > 5, 1, 0L)",
    linter
  )
  expect_lint(
    "ifelse(x > 5, 1L, 0)",
    "Prefer as.integer(x > 5) to ifelse(x > 5, 1L, 0)",
    linter
  )

  # data.table/dplyr equivalents
  # expect_lint(
  #   "dplyr::if_else(x > 5, 1L, 0L)",
  #   "Prefer as.integer(x) to if_else(x, 1L, 0L)",
  #   linter
  # )
  # expect_lint(
  #   "data.table::fifelse(x > 5, 0L, 1L)",
  #   "Prefer as.integer(!x) to fifelse(x, 0L, 1L)",
  #   linter
  # )
  #
  # expect_lint(
  #   "if_else(x > 5, 1, 0)",
  #   "Prefer as.numeric(x) to if_else(x, 1, 0)",
  #   linter
  # )
  # expect_lint(
  #   "fifelse(x > 5, 0, 1)",
  #   "Prefer as.numeric(!x) to fifelse(x, 0, 1)",
  #   linter
  # )
})

test_that("fix works", {
  expect_snapshot(fix_text("ifelse(x > 5, TRUE, FALSE)"))
  expect_snapshot(fix_text("if_else(x > 5, TRUE, FALSE)"))
  expect_snapshot(fix_text("fifelse(x > 5, TRUE, FALSE)"))

  expect_snapshot(fix_text("ifelse(x > 5, FALSE, TRUE)"))
  expect_snapshot(fix_text("if_else(x > 5, FALSE, TRUE)"))
  expect_snapshot(fix_text("fifelse(x > 5, FALSE, TRUE)"))

  expect_snapshot(fix_text("ifelse(x > 5, 0, 1L)"))
  expect_snapshot(fix_text("if_else(x > 5, 0, 1L)"))
  expect_snapshot(fix_text("fifelse(x > 5, 0, 1L)"))

  expect_snapshot(fix_text("ifelse(x > 5, 1L, 0L)"))
  expect_snapshot(fix_text("if_else(x > 5, 1L, 0L)"))
  expect_snapshot(fix_text("fifelse(x > 5, 1L, 0L)"))
})
