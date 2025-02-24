test_that("setup_flir works for packages", {
  create_local_package()
  expect_no_error(setup_flir())

  expect_true(fs::file_exists("flir/cache_file_state.rds"))
  expect_true(fs::file_exists("flir/config.yml"))
  expect_true(fs::dir_exists("flir/rules/builtin"))

  # lint
  cat("any(duplicated(x))", file = "R/foo.R")
  withr::with_envvar(
    new = c("TESTTHAT" = FALSE, "GITHUB_ACTIONS" = FALSE),
    expect_equal(nrow(lint(verbose = FALSE)), 1)
  )

  # fix
  fix(verbose = FALSE)
  expect_equal(
    readLines("R/foo.R", warn = FALSE),
    "anyDuplicated(x) > 0"
  )
})

test_that("setup_flir works for projects", {
  create_local_project()
  expect_no_error(setup_flir())

  expect_true(fs::file_exists("flir/cache_file_state.rds"))
  expect_true(fs::file_exists("flir/config.yml"))
  expect_true(fs::dir_exists("flir/rules"))

  # lint
  cat("any(duplicated(x))", file = "R/foo.R")
  withr::with_envvar(
    new = c("TESTTHAT" = FALSE, "GITHUB_ACTIONS" = FALSE),
    expect_equal(nrow(lint(verbose = FALSE)), 1)
  )

  # fix
  fix(verbose = FALSE)
  expect_equal(
    readLines("R/foo.R", warn = FALSE),
    "anyDuplicated(x) > 0"
  )
})

test_that("flir can work without setup", {
  create_local_package()
  expect_no_error(lint())
  expect_no_error(fix())
})
