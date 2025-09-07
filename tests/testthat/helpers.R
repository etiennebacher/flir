library(fs)
library(usethis)
library(withr)

# Just because it's annoying to remove them
trim_some <- function(x) x

expect_lint <- function(x, message, linter, ...) {
  if (is.null(linter)) {
    linter <- list_linters()
  }
  out <- lint_text(x, linters = linter, ...)
  if (is.null(message)) {
    testthat::expect_true(length(out) == 0)
  } else {
    testthat::expect_true(
      nrow(out) > 0 &&
        any(message == out$message | grepl(message, out$message, fixed = TRUE))
    )
  }
}

expect_no_lint <- function(x, linter, ...) {
  expect_lint(x, message = NULL, linter, ...)
}

expect_fix <- function(x, replacement, ...) {
  out <- fix_text(x, ...)
  testthat::expect_equal(as.character(out), replacement)
}

skip_if_not_r_version <- function(min_version) {
  if (getRversion() < min_version) {
    testthat::skip(paste("R version at least", min_version, "is required"))
  }
}

single_quote <- function(x) paste0("'", x, "'")
double_quote <- function(x) paste0('"', x, '"')

### Taken from {usethis} (file "R/project.R")

proj <- new.env(parent = emptyenv())

proj_get_ <- function() proj$cur

proj_set_ <- function(path) {
  old <- proj$cur
  proj$cur <- path
  invisible(old)
}

### Taken from {usethis} (file "tests/testthat/helper.R")

create_local_package <- function(
  dir = fs::file_temp(pattern = "testpkg"),
  env = parent.frame(),
  rstudio = TRUE
) {
  create_local_thing(dir, env, rstudio, "package")
}

create_local_project <- function(
  dir = fs::file_temp(pattern = "testproj"),
  env = parent.frame(),
  rstudio = FALSE
) {
  create_local_thing(dir, env, rstudio, "project")
}

create_local_thing <- function(
  dir = fs::file_temp(pattern = pattern),
  env = parent.frame(),
  rstudio = FALSE,
  thing = c("package", "project")
) {
  thing <- match.arg(thing)
  if (fs::dir_exists(dir)) {
    ui_stop("Target {ui_code('dir')} {.file {dir}} already exists.")
  }

  old_project <- proj_get_() # this could be `NULL`, i.e. no active project
  old_wd <- getwd() # not necessarily same as `old_project`

  withr::defer(
    {
      fs::dir_delete(dir)
    },
    envir = env
  )
  usethis::ui_silence(
    switch(
      thing,
      package = usethis::create_package(
        dir,
        rstudio = rstudio,
        open = FALSE,
        check_name = FALSE
      ),
      project = usethis::create_project(dir, rstudio = rstudio, open = FALSE)
    )
  )

  usethis::ui_silence({
    withr::defer(
      usethis::ui_silence(usethis::proj_set(old_project, force = TRUE)),
      envir = env
    )
    usethis::proj_set(dir)
  })

  withr::defer(
    {
      setwd(old_wd)
    },
    envir = env
  )
  setwd(usethis::proj_get())

  usethis::proj_get()
}

expect_proj_file <- function(...) expect_true(fs::file_exists(proj_path(...)))
