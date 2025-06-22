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
#' @param name Name(s) of the rule. Cannot contain white space.
#' @inheritParams setup_flir
#'
#' @return Create new file(s) but doesn't return anything
#'
#' @export
add_new_rule <- function(name, path = NULL) {
  # Required by CRAN review, 2025-06-19
  path <- path %||% "."

  check_name(name)
  name_with_yml <- paste0(name, ".yml")

  if (!fs::dir_exists(fs::path(path, "flir"))) {
    cli::cli_abort(c(
      "Folder `flir` doesn't exist.",
      "i" = "Create it with `setup_flir()` first."
    ))
  }

  fs::dir_create(fs::path(path, "flir/rules/custom"))
  dest <- fs::path(path, "flir/rules/custom", name_with_yml)
  if (any(fs::file_exists(dest))) {
    cli::cli_abort("{.path {dest[fs::file_exists(dest)]}} already exists.", )
  }
  fs::file_create(dest)

  for (i in seq_along(dest)) {
    cat(
      sprintf(
        "# Details on how to fill this template: https://flir.etiennebacher.com/articles/adding_rules
# More advanced: https://ast-grep.github.io/guide/rule-config/atomic-rule.html

id: %s
language: r
severity: warning
rule:
  pattern: ...
fix: ...
message: ...
",
        name[i]
      ),
      file = dest[i]
    )
  }

  if (rlang::is_interactive()) {
    utils::file.edit(dest)
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
#' To create a new rule that you can use in the current project only, use
#' `add_new_rule()` instead.
#'
#' @inheritParams add_new_rule
#' @inheritParams setup_flir
#'
#' @inherit add_new_rule return
#'
#' @export
export_new_rule <- function(name, path = NULL) {
  # Required by CRAN review, 2025-06-19
  path <- path %||% "."

  check_name(name)
  name_with_yml <- paste0(name, ".yml")

  if (!is_r_package(path)) {
    cli::cli_abort(
      "`export_new_rule()` only works when the project is an R package."
    )
  }
  fs::dir_create(fs::path(path, "inst/flir/rules"))
  dest <- fs::path(path, "inst/flir/rules", name_with_yml)

  if (any(fs::file_exists(dest))) {
    cli::cli_abort("{.path {dest[fs::file_exists(dest)]}} already exists.", )
  }
  fs::file_create(dest)

  for (i in seq_along(dest)) {
    cat(
      sprintf(
        "# Details on how to fill this template: https://flir.etiennebacher.com/articles/adding_rules
# More advanced: https://ast-grep.github.io/guide/rule-config/atomic-rule.html

id: %s
language: r
severity: warning
rule:
  pattern: ...
fix: ...
message: ...
",
        name[i]
      ),
      file = dest[i]
    )
  }

  if (rlang::is_interactive()) {
    utils::file.edit(dest)
  }
  cli::cli_alert_success("Created {.path {dest}}.")
}

check_name <- function(name) {
  if (!rlang::is_character(name)) {
    cli::cli_abort(
      "`name` must be a character vector.",
      call = rlang::caller_env()
    )
  }
  if (any(grepl("\\s", name))) {
    cli::cli_abort(
      "`name` must not contain white space.",
      call = rlang::caller_env()
    )
  }
}
