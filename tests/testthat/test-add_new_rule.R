test_that("add_new_rule() errors", {
  expect_error(
    add_new_rule("foo bar"),
    "must not contain white space"
  )
  expect_error(
    add_new_rule(1),
    "must be a character vector of length 1"
  )
  expect_error(
    add_new_rule(c("a", "b")),
    "must be a character vector of length 1"
  )
})

test_that("export_new_rule() cannot overwrite files", {
  create_local_package()
  setup_flir()
  add_new_rule("foobar")
  expect_error(
    add_new_rule("foobar"),
    "`./flir/rules/custom/foobar.yml` already exists.",
    fixed = TRUE
  )
})

test_that("create template for new custom rule", {
  create_local_project()
  expect_error(
    add_new_rule("foobar"),
    "Create it with `setup_flir()`",
    fixed = TRUE
  )
  setup_flir()
  expect_message(
    add_new_rule("foobar"),
    r"(Add "foobar" to 'flir/config.yml')"
  )

  expect_snapshot(fs::dir_tree("flir"))
})
