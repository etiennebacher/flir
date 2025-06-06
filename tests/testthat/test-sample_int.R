test_that("sample_int_linter skips allowed usages", {
  linter <- sample_int_linter()

  expect_lint("sample(n, m)", NULL, linter)
  expect_lint("sample(n, m, TRUE)", NULL, linter)
  expect_lint("sample(n, m, prob = 1:n/n)", NULL, linter)
  expect_lint("sample(foo(x), m, TRUE)", NULL, linter)
  expect_lint("sample(n, replace = TRUE)", NULL, linter)

  expect_lint("sample(10:1, m)", NULL, linter)
})

test_that("sample_int_linter blocks simple disallowed usages", {
  linter <- sample_int_linter()
  lint_msg <- "sample.int(n, m, ...) is preferable to sample(1:n, m, ...)."

  expect_lint("sample(1:10, 2)", lint_msg, linter)
  # also matches literal integer
  expect_lint("sample(1L:10L, 2)", lint_msg, linter)
  expect_lint("sample(1:n, 2)", lint_msg, linter)
  expect_lint("sample(1:k, replace = TRUE)", lint_msg, linter)
  expect_lint("sample(1:foo(x), prob = bar(x))", lint_msg, linter)
})

test_that("sample_int_linter blocks sample(seq_len(n), ...) as well", {
  expect_lint(
    "sample(seq_len(10), 2)",
    "sample.int(n, m, ...) is preferable to sample(seq_len(n), m, ...).",
    sample_int_linter()
  )
})

test_that("sample_int_linter blocks sample(seq(n)) and sample(seq(1, ...))", {
  linter <- sample_int_linter()
  lint_msg <- "sample.int(n, m, ...) is preferable to sample(seq(n), m, ...)."

  expect_lint("sample(seq(n), 5)", lint_msg, linter)
  # TODO:
  # expect_lint("sample(seq(1, 10), 5)", lint_msg, linter)
  # expect_lint("sample(seq(1, 10, by = 1), 5)", lint_msg, linter)
  # expect_lint("sample(seq(1L, 10, by = 1L), 5)", lint_msg, linter)

  # lint doesn't apply when by= is used (except when set to literal 1)
  expect_lint("sample(seq(1, 10, by = 2), 5)", NULL, linter)
  expect_lint("sample(seq(1, 10, by = n), 5)", NULL, linter)
})

test_that("sample_int_linter catches literal integer/numeric in the first arg", {
  linter <- sample_int_linter()
  lint_msg <- "sample.int(n, m, ...) is preferable to sample(n, m, ...)."

  expect_lint("sample('a', 4)", NULL, linter)
  expect_lint("sample(10L, 4)", lint_msg, linter)
  expect_lint("sample(10, 5)", lint_msg, linter)
})

test_that("sample_int_linter skips TRUE or FALSE in the first argument", {
  linter <- sample_int_linter()

  expect_lint("sample(replace = TRUE, letters)", NULL, linter)
  expect_lint("sample(replace = FALSE, letters)", NULL, linter)
})

test_that("sample_int_linter skips x$sample() usage", {
  linter <- sample_int_linter()
  lint_msg <- "sample.int(n, m, ...) is preferable to sample(1:n, m, ...)."

  expect_lint("foo$sample(1L)", NULL, linter)
  expect_lint("foo$sample(1:10)", NULL, linter)
  expect_lint("foo$sample(seq_len(10L))", NULL, linter)
  # ditto for '@' slot extraction
  expect_lint("foo@sample(1L)", NULL, linter)

  # TODO
  # however, base::sample qualification is still caught
  # expect_lint("base::sample(10L)", lint_msg, linter)

  # but also, not everything "below" a $ extraction is skipped
  expect_lint("foo$bar(sample(1:10, 5))", lint_msg, linter)
})

test_that("fix works", {
  linter <- sample_int_linter()

  expect_snapshot(fix_text("sample(1:2, 3)", linters = linter))
  expect_snapshot(fix_text("sample(seq(2), 3)", linters = linter))
  expect_snapshot(fix_text("sample(seq_len(2), 3)", linters = linter))
  expect_snapshot(fix_text("sample(2:3, 3)", linters = linter))
})
