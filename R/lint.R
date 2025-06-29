#' List all lints in a file or a directory
#'
#' `lint()`, `lint_text()`, `lint_package()`, and `lint_dir()` all produce a
#' data.frame containing the lints, their location, and potential fixes. The
#' only difference is in the input they take:
#' * `lint()` takes path to files or directories
#' * `lint_text()` takes some text input
#' * `lint_dir()` takes a path to one directory
#' * `lint_package()` takes a path to the root of a package and looks at the
#' following list of folders: `R`, `tests`, `inst`, `vignettes`, `data-raw`,
#' `demo`, `exec`.
#'
#' @param path A valid path to a file or a directory. Relative paths are
#'   accepted. If `NULL` (default), uses `"."`.
#' @param linters A character vector with the names of the rules to apply. See
#'   the entire list of rules with `list_linters()`. If you have set up the
#'   `flir` folder with `setup_flir()`, you can also list the linters to use
#'   in the `keep` field of `flir/config.yml`. See [setup_flir()] for more
#'   information.
#' @param exclude_path One or several paths that will be ignored from the `path`
#'   selection.
#' @param exclude_linters One or several linters that will not be checked.
#'   Values can be the names of linters (such as `"any_is_na"`) or its
#'   associated function, such as `any_is_na_linter()` (this is mostly for
#'   compatibility with `lintr`). If you have set up the `flir` folder with
#'   `setup_flir()`, you can also list the linters to exclude in the `exclude`
#'   field of `flir/config.yml`. See [setup_flir()] for more information.
#' @param open If `TRUE` (default) and if this is used in the RStudio IDE, lints
#'   will be shown with markers.
#' @param use_cache Do not re-parse files that haven't changed since the last
#'   time this function ran.
#' @param verbose Show messages.
#'
#' @section Ignoring lines:
#'
#'   `flir` supports ignoring single lines of code with `# flir-ignore`. For
#'   example, this will not warn:
#'
#' ```r
#' # flir-ignore
#' any(duplicated(x))
#' ```
#'
#'   However, this will warn for the second `any(duplicated())`:
#'
#' ```r
#' # flir-ignore
#' any(duplicated(x))
#' any(duplicated(y))
#' ```
#'
#'
#'   To ignore more than one line of code, use `# flir-ignore-start` and
#'   `# flir-ignore-end`:
#'
#' ```r
#' # flir-ignore-start
#' any(duplicated(x))
#' any(duplicated(y))
#' # flir-ignore-end
#' ```
#'
#'
#' @return A dataframe where each row is a lint. The columns show the text, its
#'   location (both the position in the text and the file in which it was found)
#'   and the severity.
#'
#' @export
#' @examples
#' # `lint_text()` is convenient to explore with a small example
#' lint_text("any(duplicated(rnorm(5)))")
#'
#' lint_text("any(duplicated(rnorm(5)))
#' any(is.na(x))
#' ")
#'
#' # Setup for the example with `lint()`
#' destfile <- tempfile()
#' cat("
#' x = c(1, 2, 3)
#' any(duplicated(x), na.rm = TRUE)
#'
#' any(duplicated(x))
#'
#' if (any(is.na(x))) {
#'   TRUE
#' }
#'
#' any(
#'   duplicated(x)
#' )", file = destfile)
#'
#' lint(destfile)
lint <- function(
  path = ".",
  linters = NULL,
  exclude_path = NULL,
  exclude_linters = NULL,
  open = TRUE,
  use_cache = TRUE,
  verbose = TRUE
) {
  if (isFALSE(verbose) | is_testing()) {
    withr::local_options(cli.default_handler = function(...) {})
  }

  if (is_testing()) {
    use_cache <- FALSE
  }

  rule_files <- resolve_linters(path, linters, exclude_linters)
  r_files <- resolve_path(path, exclude_path)
  lints <- list()
  hashes <- resolve_hashes(path, use_cache)

  cli::cli_alert_info("Going to check {length(r_files)} file{?s}.")
  i <- 0
  cli::cli_progress_bar(
    format = "{cli::pb_spin} Checking: {i}/{length(r_files)}"
  )

  for (i in seq_along(r_files)) {
    cli::cli_progress_update()

    file <- r_files[i]

    if (use_cache) {
      current_hash <- digest::digest(
        c(readLines(file, warn = FALSE), rule_files)
      )
      if (!is.null(names(hashes)) && file %in% names(hashes)) {
        stored_info <- hashes[[file]]
        if (current_hash == stored_info[["hash"]]) {
          lints[[file]] <- stored_info[["lints"]]
          next
        }
      }
    }

    lints_raw <- astgrepr::tree_new(
      file = file,
      ignore_tags = c("flir-ignore", "nolint")
    ) |>
      astgrepr::tree_root() |>
      astgrepr::node_find_all(files = rule_files)

    if (all(lengths(lints_raw) == 0)) {
      lints[[file]] <- data.table()
    } else {
      lints[[file]] <- clean_lints(lints_raw, file = file)
    }

    if (use_cache) {
      hashes[[file]][["hash"]] <- current_hash
      hashes[[file]][["lints"]] <- lints[[file]]
    }
  }

  cli::cli_progress_done()

  if (use_cache) {
    if (is_flir_package(path) || is_testing()) {
      saveRDS(hashes, file.path(getwd(), "inst/cache_file_state.rds"))
    } else if (uses_flir(path)) {
      saveRDS(hashes, file.path(getwd(), "flir/cache_file_state.rds"))
    }
  }
  lints <- data.table::rbindlist(lints, use.names = TRUE, fill = TRUE)

  if (nrow(lints) == 0) {
    cli::cli_alert_success("No lints detected.")
    return(invisible(data.table()))
  } else {
    cli::cli_alert_success(
      "Found {nrow(lints)} lint{?s} in {length(unique(lints$file))} file{?s}."
    )
    if ("fix" %in% names(lints)) {
      can_be_fixed <- lints[!is.na(fix)]
      cli::cli_alert_info(
        "{nrow(can_be_fixed)} of them can be fixed automatically."
      )
    } else {
      cli::cli_alert_info("None of them can be fixed automatically.")
    }
  }

  if (
    isTRUE(open) &&
      requireNamespace("rstudioapi", quietly = TRUE) &&
      interactive() &&
      rstudioapi::isAvailable() &&
      !is_positron()
  ) {
    rstudio_source_markers(lints)
    return(invisible(lints))
  } else if (in_github_actions() && !is_testing()) {
    github_actions_log_lints(lints)
  } else {
    if (Sys.getenv("FLIR_ERROR_ON_LINT") == "true" && nrow(lints) > 0) {
      cli::cli_abort("Some lints were found.")
    }
    lints
  }
}

#' @rdname lint
#' @export

lint_dir <- function(
  path = ".",
  linters = NULL,
  open = TRUE,
  exclude_path = NULL,
  exclude_linters = NULL,
  use_cache = TRUE,
  verbose = TRUE
) {
  if (!fs::is_dir(path)) {
    cli::cli_abort("`path` must be a directory.")
  }
  lint(
    path,
    linters = linters,
    open = open,
    exclude_path = exclude_path,
    exclude_linters = exclude_linters,
    use_cache = use_cache,
    verbose = verbose
  )
}

#' @rdname lint
#' @export

lint_package <- function(
  path = ".",
  linters = NULL,
  open = TRUE,
  exclude_path = NULL,
  exclude_linters = NULL,
  use_cache = TRUE,
  verbose = TRUE
) {
  if (!fs::is_dir(path)) {
    cli::cli_abort("`path` must be a directory.")
  }
  paths <- fs::path(
    path,
    c("R", "tests", "inst", "vignettes", "data-raw", "demo", "exec")
  )
  paths <- paths[fs::dir_exists(paths)]
  lint(
    paths,
    linters = linters,
    open = open,
    exclude_path = exclude_path,
    exclude_linters = exclude_linters,
    use_cache = use_cache,
    verbose = verbose
  )
}

#' @param text Text to analyze.
#'
#' @rdname lint
#' @export

lint_text <- function(text, linters = NULL, exclude_linters = NULL) {
  # If the folder "flir" exists, it's possible that there are custom rules.
  # Creating a proper tempfile in this case would make it impossible to
  # uses those rules since rules are accessed directly in the package's system
  # files. Therefore, in this case, the tempfile is created "manually" in the
  # "flir" folder.
  if (uses_flir(".")) {
    tmp <- paste0(
      paste(sample(letters, 30, replace = TRUE), collapse = ""),
      ".R"
    )
    on.exit({
      fs::file_delete(tmp)
    })
  } else {
    tmp <- tempfile(fileext = ".R")
  }

  text <- trimws(text)
  cat(text, file = tmp)

  out <- lint(
    tmp,
    linters = linters,
    exclude_linters = exclude_linters,
    open = FALSE,
    verbose = FALSE
  )
  if (length(out) == 0) {
    return(invisible())
  }

  class(out) <- c("flir_lint", class(out))
  out
}
