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

test_that("config.yml errors with unknown fields", {
  create_local_package()
  setup_flir()

  cat(
    "keep:\n  - equal_assignment\nsome_field: hello",
    file = "flir/config.yml"
  )
  expect_error(
    lint(),
    "Unknown field in `flir/config.yml`: some_field"
  )
})

test_that("config.yml errors with duplicated fields", {
  create_local_package()
  setup_flir()

  cat(
    "keep:\n  - equal_assignment\nkeep:\n  - foo",
    file = "flir/config.yml"
  )
  expect_error(lint(), "Duplicate map key: 'keep'")
})

test_that("config: `from-package` checks duplicated package name", {
  create_local_package()
  setup_flir()

  cat(
    "from-package:\n  - foo\n  - foo",
    file = "flir/config.yml"
  )
  expect_error(
    lint(),
    "the following packages are duplicated: foo"
  )
})

test_that("config: `from-package` checks that package is installed", {
  create_local_package()
  setup_flir()

  cat(
    "from-package:\n  - foo",
    file = "flir/config.yml"
  )
  expect_error(lint(), "The package \"foo\" is required.")
})

test_that("config: `from-package` gets rules from other packages", {
  ### Step 1: create a package that contains some rules
  pkg_with_rules <- fs::file_temp(pattern = "testpkg")
  pkg_with_rules_nm <- basename(pkg_with_rules)
  create_local_package(pkg_with_rules)
  fs::dir_create("inst/flir/rules")
  cat(
    "id: foobar
language: r
severity: warning
rule:
  pattern: unique(length($VAR))
fix: length(unique(~~VAR~~))
message: Most likely an error
",
    file = "inst/flir/rules/foo.yml"
  )

  ### The package needs to be installed
  suppressMessages(install.packages(
    ".",
    repos = NULL,
    type = "source",
    quiet = TRUE
  ))
  withr::defer(suppressMessages(remove.packages(pkg_with_rules_nm)))

  ### Step 2: create a package that uses rules from the first package
  create_local_package()
  setup_flir()
  cat(
    paste0("from-package:\n  - ", pkg_with_rules_nm),
    file = "flir/config.yml"
  )
  cat("x <- function() { \nunique(length(x))\n}", file = "foo.R")
  expect_equal(nrow(lint("foo.R", open = FALSE)), 1)
})

test_that("config: `from-package` works with multiple packages having rules with same names", {
  ### Step 1: create a package that contains some rules
  pkg_with_rules <- fs::file_temp(pattern = "testpkg")
  pkg_with_rules_nm <- basename(pkg_with_rules)
  create_local_package(pkg_with_rules)
  fs::dir_create("inst/flir/rules")
  cat(
    "id: foobar
language: r
severity: warning
rule:
  pattern: unique(length($VAR))
fix: length(unique(~~VAR~~))
message: Most likely an error
",
    file = "inst/flir/rules/foo.yml"
  )

  ### The package needs to be installed
  suppressMessages(install.packages(
    ".",
    repos = NULL,
    type = "source",
    quiet = TRUE
  ))
  withr::defer(suppressMessages(remove.packages(pkg_with_rules_nm)))

  ### Step 2: create another package that contains some rules
  pkg_with_rules_2 <- fs::file_temp(pattern = "testpkg")
  pkg_with_rules_nm_2 <- basename(pkg_with_rules_2)
  create_local_package(pkg_with_rules_2)
  fs::dir_create("inst/flir/rules")
  cat(
    "id: foobar
language: r
severity: warning
rule:
  pattern: is.na(any($VAR))
fix: any(is.na(~~VAR~~))
message: Most likely an error
",
    file = "inst/flir/rules/foo.yml"
  )

  ### The package needs to be installed
  suppressMessages(install.packages(
    ".",
    repos = NULL,
    type = "source",
    quiet = TRUE
  ))
  withr::defer(suppressMessages(remove.packages(pkg_with_rules_nm_2)))

  ### Step 3: create a package that uses rules from the first two packages
  create_local_package()
  setup_flir()
  cat(
    paste0(
      "from-package:\n  - ",
      pkg_with_rules_nm,
      "\n  - ",
      pkg_with_rules_nm_2
    ),
    file = "flir/config.yml"
  )
  cat("x <- function() { \nunique(length(x))\nis.na(any(x))\n}", file = "foo.R")
  lints <- lint("foo.R", open = FALSE)

  expect_true(all(startsWith(lints$id, "from-")))
  expect_equal(nrow(lints), 2)
})

test_that("config: `from-package` works when it has rules with same names as builtin rules", {
  ### Step 1: create a package that contains some rules
  pkg_with_rules <- fs::file_temp(pattern = "testpkg")
  pkg_with_rules_nm <- basename(pkg_with_rules)
  create_local_package(pkg_with_rules)
  fs::dir_create("inst/flir/rules")
  cat(
    "id: class_equals-1 # <------------ same id as builtin rule
language: r
severity: warning
rule:
  pattern: unique(length($VAR))
fix: length(unique(~~VAR~~))
message: Most likely an error
",
    file = "inst/flir/rules/foo.yml"
  )

  ### The package needs to be installed
  suppressMessages(install.packages(
    ".",
    repos = NULL,
    type = "source",
    quiet = TRUE
  ))
  withr::defer(suppressMessages(remove.packages(pkg_with_rules_nm)))

  ### Step 2: create a package that uses rules from the first two packages
  create_local_package()
  setup_flir()
  cat(
    paste0("from-package:\n  - ", pkg_with_rules_nm),
    file = "flir/config.yml",
    append = TRUE
  )
  cat(
    "x <- function() { \nunique(length(x))\nclass(x) == 'a'\n}",
    file = "foo.R"
  )
  lints <- lint("foo.R", open = FALSE)

  expect_equal(nrow(lints), 2)
})

test_that("config: the user can exclude rules from external packages", {
  ### Step 1: create a package that contains some rules
  pkg_with_rules <- fs::file_temp(pattern = "testpkg")
  pkg_with_rules_nm <- basename(pkg_with_rules)
  create_local_package(pkg_with_rules)
  fs::dir_create("inst/flir/rules")
  cat(
    "id: foo
language: r
severity: warning
rule:
  pattern: unique(length($VAR))
fix: length(unique(~~VAR~~))
message: Most likely an error
",
    file = "inst/flir/rules/foo.yml"
  )

  ### The package needs to be installed
  suppressMessages(install.packages(
    ".",
    repos = NULL,
    type = "source",
    quiet = TRUE
  ))
  withr::defer(suppressMessages(remove.packages(pkg_with_rules_nm)))

  ### Step 2: create a package that uses rules from the first two packages
  create_local_package()
  setup_flir()
  cat(
    paste0(
      "from-package:\n  - ",
      pkg_with_rules_nm,
      "\nexclude:\n  - ",
      paste0("from-", pkg_with_rules_nm, "-foo")
    ),
    file = "flir/config.yml",
    append = TRUE
  )
  cat(
    "x <- function() { \nunique(length(x))\nclass(x) == 'a'\n}",
    file = "foo.R"
  )
  lints <- lint("foo.R", open = FALSE)

  expect_equal(nrow(lints), 1)
})
