#' Create a custom rule for internal use
#'
#' @description
#' This function creates a YAML file with the placeholder text to define a new
#' rule. The file is stored in `flir/rules/custom`. You need to create the
#' `flir` folder with `setup_flir()` if it doesn't exist.
#'
#' If you want to create a rule that users of your package will be able to
#' access, use `export_new_rule()` instead.
#'
#' @param name Name of the rule. Cannot contain white space.
#' @inheritParams setup_flir
#'
#' @export
add_new_rule <- function(name, path = ".") {
  if (!rlang::is_string(name)) {
    rlang::abort("`name` must be a character vector of length 1.")
  }
  if (grepl("\\s", name)) {
    rlang::abort("`name` must not contain white space.")
  }
  name_with_yml <- paste0(name, ".yml")
  if (!fs::dir_exists(fs::path(path, "flir"))) {
    rlang::abort(c(
      "Folder `flir` doesn't exist.",
      "i" = "Create it with `setup_flir()` first."
    ))
  }

  dest <- fs::path(path, "flir", "rules", "custom", name_with_yml)
  fs::dir_create(fs::path_dir(dest))
  fs::file_create(dest)
  cat(
    sprintf(
      "id: %s
language: r
severity: warning
rule:
  pattern: ...
fix: ...
message: ...
",
      name
    ),
    file = dest
  )
  if (rstudioapi::isAvailable() && !is_positron()) {
    rstudioapi::documentOpen(dest)
  }
  cli::cli_alert_success("Created {.path {dest}}.")
  cli::cli_alert_info(
    "Add {.val {name}} to {.path flir/config.yml} to be able to use it."
  )
}

#' Create a custom rule for external use
#'
#' @description
#' This function creates a YAML file with the placeholder text to define a new
#' rule. The file is stored in `inst/flir/rules` and will be available to users
#' of your package if they use `flir`.
#'
#' To create a new rule that you can use in the current project, use
#' `add_new_rule()` instead.
#'
#' @param name Name of the rule. Cannot contain white space.
#' @inheritParams setup_flir
#'
#' @export
export_new_rule <- function(name, path = ".") {
  if (!rlang::is_string(name)) {
    rlang::abort("`name` must be a character vector of length 1.")
  }
  if (grepl("\\s", name)) {
    rlang::abort("`name` must not contain white space.")
  }
  name_with_yml <- paste0(name, ".yml")
  if (!is_r_package(path)) {
    rlang::abort("`export_new_rule()` only works when the project is an R package.")
  }
  fs::dir_create(fs::path(path, "inst/flir/rules"))
  fs::file_create(dest)
  cat(
    sprintf(
      "id: %s
language: r
severity: warning
rule:
  pattern: ...
fix: ...
message: ...
",
      name
    ),
    file = dest
  )
  if (rstudioapi::isAvailable() && !is_positron()) {
    rstudioapi::documentOpen(dest)
  }
  cli::cli_alert_success("Created {.path {dest}}.")
}
