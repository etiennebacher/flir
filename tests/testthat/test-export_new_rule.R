test_that("export_new_rule() only works in packages", {
  create_local_project()
  expect_error(
    export_new_rule("foobar"),
    "only works when the project is an R package"
  )
})

test_that("export_new_rule() can create files", {
  create_local_package()
  export_new_rule("foobar")
  export_new_rule("foobar2")
  expect_true(fs::file_exists("inst/flir/rules/foobar.yml"))
  expect_true(fs::file_exists("inst/flir/rules/foobar2.yml"))
})

test_that("export_new_rule() cannot overwrite files", {
  create_local_package()
  export_new_rule("foobar")
  expect_error(
    export_new_rule("foobar"),
    "`./inst/flir/rules/foobar.yml` already exists.",
    fixed = TRUE
  )
})

test_that("export_new_rule() cannot create file with whitespace", {
  create_local_package()
  expect_error(
    export_new_rule("hi there"),
    "`name` must not contain white space"
  )
})

test_that("export_new_rule() cannot create multiple files at once", {
  create_local_package()
  expect_error(
    export_new_rule(c("a", "b")),
    "`name` must be a character vector of length 1"
  )
})
