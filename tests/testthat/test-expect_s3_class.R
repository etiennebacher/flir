test_that("expect_s3_class_linter skips allowed usages", {
  linter <- expect_s3_class_linter()

  # expect_s3_class doesn't have an inverted version
  expect_no_lint("expect_true(!inherits(x, 'class'))", linter)
  # NB: also applies to tinytest, but it's sufficient to test testthat
  expect_no_lint("testthat::expect_true(!inherits(x, 'class'))", linter)

  # other is.<x> calls are not suitable for expect_s3_class in particular
  expect_no_lint("expect_true(is.na(x))", linter)

  # case where expect_s3_class() *could* be used but we don't enforce
  expect_no_lint("expect_true(is.data.table(x))", linter)

  # expect_s3_class() doesn't have info= or label= arguments
  expect_no_lint(
    "expect_equal(class(x), k, info = 'x should have class k')",
    linter
  )
  expect_no_lint("expect_equal(class(x), k, label = 'x class')", linter)
  expect_no_lint(
    "expect_equal(class(x), k, expected.label = 'target class')",
    linter
  )
  expect_no_lint(
    "expect_true(is.data.frame(x), info = 'x should be a data.frame')",
    linter
  )
})

test_that("expect_s3_class_linter blocks simple disallowed usages", {
  linter <- expect_s3_class_linter()

  expect_lint(
    "expect_equal(class(x), 'data.frame')",
    "expect_s3_class(x, k) is better than expect_equal(class(x), k)",
    linter
  )

  # works when testing against a sequence of classes too
  expect_lint(
    "expect_equal(class(x), c('data.table', 'data.frame'))",
    "expect_s3_class(x, k) is better than expect_equal(class(x), k)",
    linter
  )

  # expect_identical is treated the same as expect_equal
  expect_lint(
    "testthat::expect_identical(class(x), 'lm')",
    "expect_s3_class(x, k) is better than expect_identical(class(x), k)",
    linter
  )

  # yoda test with string literal in first arg also caught
  expect_lint(
    "expect_equal('data.frame', class(x))",
    "expect_s3_class(x, k) is better than expect_equal(class(x), k)",
    linter
  )

  # different equivalent usages
  expect_lint(
    "expect_true(is.table(foo(x)))",
    "expect_s3_class(x, k) is better than expect_true(is.<k>(x))",
    linter
  )
  expect_lint(
    "expect_true(inherits(x, 'table'))",
    "expect_s3_class(x, k) is better than expect_true(inherits(x, k))",
    linter
  )
})

local({
  # test for lint errors appropriately raised for all is.<class> calls
  is_classes <- c(
    "data.frame",
    "factor",
    "grob",
    "mts",
    "numeric_version",
    "ordered",
    "package_version",
    "qr",
    "raster",
    "relistable",
    "stepfun",
    "table",
    "tclObj",
    "tkwin",
    "ts",
    "tskernel",
    "unit"
  )
  patrick::with_parameters_test_that(
    "expect_true(is.<base class>) is caught",
    expect_lint(
      sprintf("expect_true(is.%s(x))", is_class),
      "expect_s3_class(x, k) is better than expect_true(is.<k>(x))",
      expect_s3_class_linter()
    ),
    .test_name = is_classes,
    is_class = is_classes
  )

  is_classes <- c(
    "grDevices::is.raster",
    "grid::is.grob",
    "grid::is.unit",
    "stats::is.mts",
    "stats::is.stepfun",
    "stats::is.ts",
    "stats::is.tskernel",
    "tcltk::is.tclObj",
    "tcltk::is.tkwin",
    "utils::is.relistable"
  )
  patrick::with_parameters_test_that(
    "expect_true(is.<base class>) is caught",
    expect_lint(
      sprintf("expect_true(%s(x))", is_class),
      "expect_s3_class(x, k) is better than expect_true(is.<k>(x))",
      expect_s3_class_linter()
    ),
    .test_name = is_classes,
    is_class = is_classes
  )
})

test_that("fix works", {
  expect_fix(
    'expect_true(inherits(x, "data.frame"))',
    'expect_s3_class(x, "data.frame")'
  )
  expect_fix(
    'expect_true(inherits(x, what = "data.frame"))',
    'expect_s3_class(x, "data.frame")'
  )
  expect_fix(
    'expect_true(inherits(what = "data.frame", x = x))',
    'expect_s3_class(x, "data.frame")'
  )

  # TODO: https://github.com/etiennebacher/astgrepr/issues/17
  # expect_fix(
  #   'expect_true(is.data.frame(x))',
  #   'expect_s3_class(x, "data.frame")'
  # )
  # expect_fix(
  #   'expect_true(grid::is.grob(x))',
  #   'expect_s3_class(x, "grob")'
  # )
})
