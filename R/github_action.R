#' Create a Github Actions workflow for `flir`
#'
#' @inheritParams setup_flir
#' @param overwrite Whether to overwrite `.github/workflows/flir.yaml` if it
#' already exists.
#'
#' @return Creates `.github/workflows/flir.yaml` but doesn't return any value.
#' @export
setup_flir_gha <- function(path = NULL, overwrite = FALSE) {
  # Required by CRAN review, 2025-06-19
  path <- path %||% "."

  src <- system.file("gha/flir.yaml", package = "flir")
  tar <- file.path(path, ".github/workflows/flir.yaml")
  if (!fs::dir_exists(dirname(tar))) {
    fs::dir_create(dirname(tar))
  }
  fs::file_copy(src, tar, overwrite = overwrite)
  if (!is_testing()) {
    cli::cli_inform("Created {.path .github/workflows/flir.yaml}.")
  }
}

### Taken from https://github.com/r-lib/lintr/blob/main/R/actions.R
### [MIT License]

in_github_actions <- function() {
  identical(Sys.getenv("GITHUB_ACTIONS"), "true")
}

# Output logging commands for any lints found
github_actions_log_lints <- function(x, project_dir = "") {
  if (nzchar(project_dir)) {
    x$filename <- file.path(project_dir, x$filename)
  }
  file_line_col <- sprintf(
    "file=%s,line=%s,col=%s",
    x$file,
    x$line_start,
    x$col_start
  )
  # Otherwise highlighting is only applied on the first part of the message
  x$message <- gsub("\\\n", " ", x$message)
  cat(
    sprintf(
      "::warning %s::%s,[%s] %s\n",
      file_line_col,
      file_line_col,
      x$text,
      x$message
    ),
    sep = ""
  )
}
