test_that("arg exclude_path works", {
  create_local_package()
  expect_no_error(setup_flir())

  dir.create("inst")
  cat("any(duplicated(x))", file = "inst/foo.R")
  cat("any(duplicated(x))", file = "R/foo.R")
  withr::with_envvar(
    new = c("TESTTHAT" = FALSE, "GITHUB_ACTIONS" = FALSE),
    {
      expect_equal(nrow(lint(exclude_path = "inst", verbose = FALSE)), 1)
      expect_equal(
        nrow(lint_dir("R", exclude_path = "inst", verbose = FALSE)),
        1
      )
      expect_equal(
        nrow(lint_package(exclude_path = "inst", verbose = FALSE)),
        1
      )
    }
  )
})
