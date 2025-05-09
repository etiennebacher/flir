test_that("expect_identical_linter skips allowed usages", {
  linter <- expect_identical_linter()

  # expect_type doesn't have an inverted version
  expect_lint("expect_true(identical(x, y) || identical(y, z))", NULL, linter)
  # NB: also applies to tinytest, but it's sufficient to test testthat
  expect_lint(
    "testthat::expect_true(identical(x, y) || identical(y, z))",
    NULL,
    linter
  )

  # expect_equal calls with explicit tolerance= are OK
  expect_lint("expect_equal(x, y, tolerance = 1e-6)", NULL, linter)
  # ditto if the argument is passed quoted
  expect_lint("expect_equal(x, y, 'tolerance' = 1e-6)", NULL, linter)

  # ditto for check.attributes = FALSE
  expect_lint("expect_equal(x, y, check.attributes = FALSE)", NULL, linter)
})

test_that("expect_identical_linter blocks simple disallowed usages", {
  linter <- expect_identical_linter()
  lint_msg <- "Use expect_identical"

  expect_lint("expect_equal(x, y)", lint_msg, linter)

  # different usage to redirect to expect_identical
  expect_lint("expect_true(identical(x, y))", lint_msg, linter)
})

test_that("expect_identical_linter skips cases likely testing numeric equality", {
  linter <- expect_identical_linter()
  lint_msg <- "Use expect_identical(x, y) by default; resort to expect_equal()"

  expect_lint("expect_equal(x, 1.034)", NULL, linter)
  expect_lint("expect_equal(x, -1.034)", NULL, linter)
  expect_lint("expect_equal(x, c(-1.034))", NULL, linter)
  expect_lint("expect_equal(x, -c(1.034))", NULL, linter)

  expect_lint("expect_equal(x, c(1.01, 1.02))", NULL, linter)
  # whole numbers with explicit decimals are OK, even in mixed scenarios
  expect_lint("expect_equal(x, c(1.0, 2))", NULL, linter)
  # plain numbers are still caught, however
  expect_lint("expect_equal(x, 1L)", lint_msg, linter)
  expect_lint("expect_equal(x, 1)", lint_msg, linter)
  # NB: TRUE is a NUM_CONST so we want test matching it, even though this test is
  #   also a violation of expect_true_false_linter()
  expect_lint("expect_equal(x, TRUE)", lint_msg, linter)

  # TODO
  # expect_lint("expect_equal(x, 1.01 - y)", lint_msg, linter)
  # expect_lint("expect_equal(x, foo() - 0.01)", lint_msg, linter)
})

test_that("expect_identical_linter skips 3e cases needing expect_equal", {
  expect_lint(
    "expect_equal(x, y, ignore_attr = 'names')",
    NULL,
    expect_identical_linter()
  )
})

# this arose where a helper function was wrapping expect_equal() and
#   some of the "allowed" arguments were being passed --> false positive
test_that("expect_identical_linter skips calls using ...", {
  expect_lint("expect_equal(x, y, ...)", NULL, expect_identical_linter())
})

test_that("fix works", {
  linter <- expect_identical_linter()

  expect_snapshot(
    fix_text("expect_true(identical(x + 1, y))", linters = linter)
  )
  expect_snapshot(fix_text("expect_equal(x + 1, y)", linters = linter))
  expect_snapshot(fix_text("expect_equal(x + 1.1, y)", linters = linter))
})
