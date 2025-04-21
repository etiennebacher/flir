test_that("config.yml is taken into account", {
  create_local_package()
  setup_flir()
  fs::dir_create("tests/testthat")

  cat("a = 1", file = "R/foo.R")
  cat("a = 1", file = "tests/testthat/foo.R")
  expect_equal(nrow(lint()), 2)

  # Only keep one linter, not the one about assignment symbols
  cat("keep:\n  - class_equals", file = "flir/config.yml")
  expect_equal(nrow(lint()), 0)
  expect_equal(nrow(lint_dir("R")), 0)
  expect_equal(nrow(lint_package()), 0)

  # commented out linter not taken into account
  cat(
    "keep:\n  - class_equals\n#  - equal_assignment",
    file = "flir/config.yml"
  )
  expect_equal(nrow(lint()), 0)
  expect_equal(nrow(lint_dir("R")), 0)
  expect_equal(nrow(lint_package()), 0)

  # "exclude" field works
  cat(
    "keep:\n  - class_equals\nexclude:\n  - equal_assignment",
    file = "flir/config.yml"
  )
  expect_equal(nrow(lint()), 0)
  expect_equal(nrow(lint_dir("R")), 0)
  expect_equal(nrow(lint_package()), 0)
})

test_that("config.yml errors when it doesn't contain any rule", {
  create_local_package()
  setup_flir()

  # Only keep one linter, not the one about assignment symbols
  cat("keep:", file = "flir/config.yml")
  expect_error(lint(), "doesn't contain any rule")

  # commented out linter not taken into account
  cat("keep:\n#  - equal_assignment", file = "flir/config.yml")
  expect_error(lint(), "doesn't contain any rule")
})

test_that("config.yml errors when it contains unknown rules", {
  create_local_package()
  setup_flir()

  cat(
    "keep:\n  - equal_assignment\n  - foo\n  - bar",
    file = "flir/config.yml"
  )
  expect_error(lint(), "Unknown linters: foo, bar")
})

test_that("config.yml errors when it contains duplicated rules", {
  create_local_package()
  setup_flir()

  cat(
    "keep:\n  - equal_assignment\n  - class_equals\n  - equal_assignment",
    file = "flir/config.yml"
  )
  expect_error(lint(), "the following linters are duplicated: equal_assignment")
})
