test_that("browser() call detected", {
  linter <- undesirable_function_linter()
  expect_lint("browser()", "Function \"browser()\" is undesirable", linter)
  expect_lint("#browser()", NULL, linter)
})

test_that("browser() has no fix", {
  expect_snapshot(fix_text("browser()"))
})

test_that("debugonce() call detected", {
  linter <- undesirable_function_linter()
  expect_lint("debugonce()", "Function \"debugonce()\" is undesirable", linter)
  expect_lint("#debugonce()", NULL, linter)
})

test_that("those names can be used as argument names, not as values", {
  linter <- undesirable_function_linter()
  expect_lint("foo(browser = TRUE)", NULL, linter)
  expect_lint(
    "foo(x = browser())",
    "Function \"browser()\" is undesirable",
    linter
  )
})
