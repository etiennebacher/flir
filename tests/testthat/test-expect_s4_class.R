test_that("expect_s4_class_linter skips allowed usages", {
  linter <- expect_s4_class_linter()

  # expect_s4_class doesn't have an inverted version
  expect_no_lint("expect_true(!is(x, 'class'))", linter)
  # NB: also applies to tinytest, but it's sufficient to test testthat
  expect_no_lint("testthat::expect_s3_class(!is(x, 'class'))", linter)

  # expect_s4_class() doesn't have info= or label= arguments
  expect_no_lint(
    "expect_true(is(x, 'SpatialPoly'), info = 'x should be SpatialPoly')",
    linter
  )
  expect_no_lint(
    "expect_true(is(x, 'SpatialPoly'), label = 'x inheritance')",
    linter
  )
})

test_that("expect_s4_class blocks simple disallowed usages", {
  linter <- expect_s4_class_linter()
  lint_msg <- "expect_s4_class(x, k) is better than expect_true(is(x, k))"

  expect_lint("expect_true(is(x, 'data.frame'))", lint_msg, linter)
  expect_lint(
    "expect_true(is(object = x, class2 = 'data.frame'))",
    lint_msg,
    linter
  )
  expect_lint(
    "expect_true(is(class2 = 'data.frame', object = x))",
    lint_msg,
    linter
  )
  # namespace qualification is irrelevant
  expect_lint(
    "testthat::expect_true(methods::is(x, 'SpatialPolygonsDataFrame'))",
    lint_msg,
    linter
  )
})

test_that("fix works", {
  linter <- expect_s4_class_linter()

  expect_snapshot(fix_text("expect_true(is(x, 's4class'))", linters = linter))
  expect_snapshot(fix_text(
    "expect_true(methods::is(x, 's4class'))",
    linters = linter
  ))
  expect_snapshot(fix_text(
    "testthat::expect_true(is(x, 's4class'))",
    linters = linter
  ))
  expect_snapshot(fix_text(
    "testthat::expect_true(methods::is(x, 's4class'))",
    linters = linter
  ))
  expect_snapshot(fix_text(
    "testthat::expect_true(is(object = x, class2 = 's4class'))",
    linters = linter
  ))
  expect_snapshot(fix_text(
    "testthat::expect_true(is(class2 = 's4class', object = x))",
    linters = linter
  ))
  expect_snapshot(fix_text(
    "testthat::expect_true(is(class2 = 's4class', object = x))",
    linters = linter
  ))
})
