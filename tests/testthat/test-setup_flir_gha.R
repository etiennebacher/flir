test_that("setup_flir_gha basic use works", {
  create_local_package()
  expect_no_error(suppressMessages(setup_flir_gha()))
  expect_true(file.exists(".github/workflows/flir.yaml"))

  # Do not use snapshot here since error message includes path to installed
  # "flir"
  expect_error(setup_flir_gha(), "file already exists")
  expect_no_error(setup_flir_gha(overwrite = TRUE))
})
