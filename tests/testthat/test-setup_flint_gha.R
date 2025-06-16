test_that("setup_flir_gha basic use works", {
  create_local_package()
  expect_no_error(suppressMessages(setup_flir_gha()))
  expect_true(file.exists(".github/workflows/flir.yaml"))

  expect_snapshot(
    setup_flir_gha(),
    error = TRUE
  )

  expect_no_error(setup_flir_gha(overwrite = TRUE))
})
