#' Setup flir
#'
#' @description
#' This creates a `flir` folder that has multiple purposes. It contains:
#' - the file `config.yml` where you can define rules to keep or exclude, as
#'   well as rules defined in other packages. More on this below;
#' - the file `cache_file_state.rds`, which is used when `lint_*()` or `fix_*()`
#'   have `cache = TRUE`;
#' - an optional folder `rules/custom` where you can store your own rules.
#'
#' This folder must live at the root of the project and cannot be renamed.
#'
#' @param path Path to package or project root. If `NULL` (default), uses `"."`.
#'
#' @details
#' The file `flir/config.yml` can contain three fields: `keep`, `exclude`,
#' and `from-package`.
#'
#' `keep` and `exclude` are used to define the rules to keep or to exclude when
#' running `lint_*()` or `fix_*()`.
#'
#' It is possible for other packages to create their own list of rules, for
#' instance to detect or replace deprecated functions. In `from-package`, you
#' can list package names where `flir` should look for additional rules. By
#' default, if you list package `foobar`, then all rules defined in the package
#' `foobar` will be used. To ignore some of those rules, you can list
#' `from-foobar-<rulename>` in the `exclude` field.
#'
#' See the vignette [Sharing rules across packages](https://flir.etiennebacher.com/articles/sharing_rules.html) for more information.
#'
#' @return Imports files necessary for `flir` to work but doesn't return any
#' value in R.
#' @export

setup_flir <- function(path = NULL) {
  # Required by CRAN review, 2025-06-19
  path <- path %||% "."

  flir_dir <- file.path(path, "flir")

  ### Check dir
  if (
    fs::dir_exists(flir_dir) &&
      length(list.files(flir_dir, recursive = TRUE)) > 0
  ) {
    cli::cli_abort("Folder `flir` already exists and is not empty.")
  } else if (!fs::dir_exists(flir_dir)) {
    fs::dir_create(flir_dir)
  }

  ### Check buildignore
  if (fs::file_exists(".Rbuildignore")) {
    already_in <- any(grepl("flir", readLines(".Rbuildignore", warn = FALSE)))
  } else {
    already_in <- FALSE
  }
  if (!already_in) {
    cat(
      "\n\n# flir files
^flir$\n",
      file = ".Rbuildignore",
      append = TRUE
    )
  }

  ### Files
  if (!fs::file_exists(file.path(flir_dir, "cache_file_state.rds"))) {
    saveRDS(NULL, file.path(flir_dir, "cache_file_state.rds"))
  }
  config_content <- paste0(
    "keep:\n",
    paste("  -", list_linters(path), collapse = "\n")
  )
  writeLines(config_content, file.path(flir_dir, "config.yml"))

  cli::cli_alert_success("Created {.path {flir_dir}}.")
  cli::cli_alert_info("Use {.fn add_new_rule} to create a custom rule.")
}
