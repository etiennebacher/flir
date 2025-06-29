test_that("users can define custom linters", {
  create_local_package()
  setup_flir()
  fs::dir_create("flir/rules/custom")
  fs::dir_create("dir1/dir2")

  cat(
    "id: foobar
language: r
severity: warning
rule:
  pattern: unique(length($VAR))
fix: length(unique(~~VAR~~))
message: Most likely an error
",
    file = "flir/rules/custom/AAAAAAAAA.yml"
  )

  cat("x <- function() { \nunique(length(x))\n}", file = "dir1/dir2/foo.R")

  config <- yaml::read_yaml("flir/config.yml")
  config$keep <- c(config$keep, "AAAAAAAAA")
  yaml::write_yaml(config, "flir/config.yml")
  withr::with_envvar(
    new = c("TESTTHAT" = FALSE, "GITHUB_ACTIONS" = FALSE),
    {
      expect_equal(nrow(lint(use_cache = FALSE, verbose = FALSE)), 1)
      # Passing a specific file path works with custom linters, #54
      expect_equal(
        nrow(lint("dir1/dir2/foo.R", use_cache = FALSE, verbose = FALSE)),
        1
      )

      expect_equal(
        nrow(
          lint(
            use_cache = FALSE,
            linters = list_linters(path = "."),
            verbose = FALSE
          )
        ),
        0
      )
      fix(path = ".", verbose = FALSE)
    }
  )
  expect_true(
    any(
      grepl(
        "length(unique(x))",
        readLines("dir1/dir2/foo.R", warn = FALSE),
        fixed = TRUE
      )
    )
  )
})

test_that("fix() and lint() work on relative path to a rule", {
  create_local_project()
  cat(
    "id: foobar
language: r
severity: warning
rule:
  pattern: unique(length(a))
fix: length(unique(a))
message: foobar
",
    file = "foo.yml"
  )

  cat("unique(length(a))", file = "foo.R")
  expect_equal(nrow(lint(linters = "foo.yml")), 1)

  # Works on both extensions
  fs::file_move("foo.yml", "foo.yaml")
  expect_equal(nrow(lint(linters = "foo.yaml")), 1)

  # Nested path
  fs::dir_create("foobar")
  fs::file_move("foo.yaml", "foobar/foo.yaml")
  expect_equal(nrow(lint(linters = "foobar/foo.yaml")), 1)
})
