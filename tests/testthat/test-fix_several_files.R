test_that("Ask permission to use fix() on several files if Git is not used", {
  create_local_package()
  cat("x = 1", file = "R/test.R")
  cat("x = 2", file = "R/test2.R")
  expect_snapshot(
    fix_dir("R"),
    error = TRUE
  )
})
