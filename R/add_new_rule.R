#' Create a custom rule
#'
#' @param name Name of the rule. Cannot contain white space.
#' @inheritParams setup_flir
#'
#' @return Creates a new file but doesn't return anything.
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
