#' Setup flir
#'
#' This stores the default rules and internal files in `inst/flir`. It also
#' imports `sgconfig.yml` that is used by `ast-grep`. This file must live at the
#' root of the project and cannot be renamed.
#'
#' @param path Path to package or project root.
#'
#' @return Imports files necessary for `flir` to work but doesn't return any
#' value in R.
#' @export

setup_flir <- function(path = ".") {
  flir_dir <- file.path(path, "flir")

  ### Check dir
  if (
    fs::dir_exists(flir_dir) &&
      length(list.files(flir_dir, recursive = TRUE)) > 0
  ) {
    stop("Folder `flir` already exists and is not empty.")
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
  invisible(
    fs::dir_copy(
      system.file("rules/builtin", package = "flir"),
      fs::path(flir_dir, "rules/builtin")
    )
  )
  if (!fs::file_exists(file.path(flir_dir, "cache_file_state.rds"))) {
    saveRDS(NULL, file.path(flir_dir, "cache_file_state.rds"))
  }
  config_content <- paste0(
    "keep:\n",
    paste("  -", list_linters(), collapse = "\n")
  )
  writeLines(config_content, file.path(flir_dir, "config.yml"))
}

#' Update the `flir` setup
#'
#' @description
#'
#' When `flir` is updated, it can ship new built-in rules or update existing
#' ones. `update_flir()` will automatically add those new rules to the
#' `flir/rules/builtin` folder. Custom rules stored in `flir/rules/custom`
#' are not affected.
#'
#' @inheritParams setup_flir
#'
#' @return Can add new files in the `flir/rules` folder, doesn't return anything.
#' @export
#'
#' @examples
#' \dontrun{
#'   update_flir()
#' }
update_flir <- function(path = ".") {
  flir_dir <- file.path(path, "flir")
  built_in_rules <- list.files(
    fs::path(flir_dir, "rules/builtin"),
    pattern = "\\.yml$"
  )
  updated_built_in_rules <- system.file(
    list.files("rules/builtin", pattern = "\\.yml$"),
    package = "flir"
  )
  new_built_in_rules <- setdiff(updated_built_in_rules, built_in_rules)

  # Copy everything so that rules that already exist can also be updated.
  fs::file_copy(
    updated_built_in_rules,
    paste0(flir_dir, "/rules/builtin/", basename(updated_built_in_rules))
  )

  cli::cli_alert_success("Updated existing rules.")
  if (length(new_built_in_rules) > 0) {
    cli::cli_alert_success(
      "Added {length(new_built_in_rules)} rule{?s}: {gsub('\\.yml$', '', basename(new_built_in_rules))}."
    )
    cli::cli_alert_info(
      "Don't forget to add them in flir/config.yml to use them."
    )
  }
}
