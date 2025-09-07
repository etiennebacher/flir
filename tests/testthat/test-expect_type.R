test_that("expect_type_linter skips allowed usages", {
  linter <- expect_type_linter()

  # expect_type doesn't have an inverted version
  expect_no_lint("expect_true(!is.numeric(x))", linter)
  # NB: also applies to tinytest, but it's sufficient to test testthat
  expect_no_lint("testthat::expect_true(!is.numeric(x))", linter)

  # other is.<x> calls are not suitable for expect_type in particular
  expect_no_lint("expect_true(is.data.frame(x))", linter)

  # expect_type(x, ...) cannot be cleanly used here:
  expect_no_lint("expect_true(typeof(x) %in% c('builtin', 'closure'))", linter)

  # expect_type() doesn't have info= or label= arguments
  expect_no_lint("expect_equal(typeof(x), t, info = 'x should have type t')", linter)
  expect_no_lint("expect_equal(typeof(x), t, label = 'x type')", linter)
  expect_no_lint("expect_equal(typeof(x), t, expected.label = 'type')", linter)
  expect_no_lint("expect_true(is.double(x), info = 'x should be double')", linter)
})

test_that("expect_type_linter blocks simple disallowed usages", {
  linter <- expect_type_linter()

  expect_lint(
    "expect_equal(typeof(x), 'double')",
    "expect_type(x, t) is better than expect_equal(typeof(x), t)",
    linter
  )

  # expect_identical is treated the same as expect_equal
  expect_lint(
    "expect_identical(typeof(x), 'language')",
    "expect_type(x, t) is better than expect_identical(typeof(x), t)",
    linter
  )

  # different equivalent usage
  expect_lint(
    "expect_true(is.complex(foo(x)))",
    "expect_type(x, t) is better than expect_true(is.<t>(x))",
    linter
  )

  # yoda test with clear expect_type replacement
  expect_lint(
    "expect_equal('integer', typeof(x))",
    "expect_type(x, t) is better than expect_equal(typeof(x), t)",
    linter
  )
})

local({
  # test for lint errors appropriately raised for all is.<type> calls
  is_types <- c(
    "raw",
    "logical",
    "integer",
    "double",
    "complex",
    "character",
    "list",
    "numeric",
    "function",
    "primitive",
    "environment",
    "pairlist",
    "promise",
    "language",
    "call",
    "name",
    "symbol",
    "expression"
  )
  patrick::with_parameters_test_that(
    "expect_type_linter catches expect_true(is.<base type>)",
    expect_lint(
      sprintf("expect_true(is.%s(x))", is_type),
      "expect_type(x, t) is better than expect_true(is.<t>(x))",
      expect_type_linter()
    ),
    .test_name = is_types,
    is_type = is_types
  )
})

test_that("lints vectorize", {
  linter <- expect_type_linter()
  expect_equal(
    nrow(
      lint_text(
        "{
      expect_true(is.integer(x))
      expect_equal(typeof(x), 'double')
    }",
        linters = linter
      )
    ),
    2
  )
})

test_that("fix works", {
  linter <- expect_type_linter()

  expect_snapshot(
    fix_text("expect_equal(typeof(x), 'double')", linters = linter)
  )
  expect_snapshot(
    fix_text("expect_equal(typeof(x), \"double\")", linters = linter)
  )

  expect_snapshot(
    fix_text("expect_identical(typeof(x), 'double')", linters = linter)
  )
  expect_snapshot(
    fix_text("expect_identical(typeof(x), \"double\")", linters = linter)
  )

  expect_snapshot(
    fix_text("expect_equal('double', typeof(x))", linters = linter)
  )
  expect_snapshot(
    fix_text("expect_identical('double', typeof(x))", linters = linter)
  )

  # Don't fix for this
  expect_snapshot(fix_text("expect_true(is.complex(foo(x)))", linters = linter))
})

# Replacement could be mixed up to suggest both expect_type and expect_identical
test_that("no double replacement", {
  expect_snapshot(fix_text("expect_equal(typeof(x), 'double')"))
})
