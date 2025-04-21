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
  if (!fs::file_exists(file.path(flir_dir, "cache_file_state.rds"))) {
    saveRDS(NULL, file.path(flir_dir, "cache_file_state.rds"))
  }
  config_content <- paste0(
    "keep:\n",
    paste("  -", list_linters(), collapse = "\n")
  )
  writeLines(config_content, file.path(flir_dir, "config.yml"))
}
