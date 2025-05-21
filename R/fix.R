#' Automatically replace lints
#'
#' @description
#' `fix()`, `fix_package()`, and `fix_dir()` all replace lints in files. The
#' only difference is in the input they take:
#' * `fix()` takes path to files or directories
#' * `fix_dir()` takes a path to one directory
#' * `fix_package()` takes a path to the root of a package and looks at the
#' following list of folders: `R`, `tests`, `inst`, `vignettes`, `data-raw`,
#' `demo`, `exec`.
#'
#' `fix_text()` takes some text input. Its main interest is to be able to
#' quickly experiment with some lints and fixes.
#'
#' @inheritParams lint
#' @param force Force the application of fixes on the files. This is used only
#' in the case where Git is not detected, several files will be modified, and
#' the code is run in a non-interactive setting.
#' @param rerun Run the function several times until there are no more fixes to
#' apply. This is useful in the case of nested lints. If `FALSE`, the function
#' runs only once, potentially ignoring nested fixes.
#' @param interactive Opens a Shiny app that shows a visual diff of each
#' modified file. This is particularly useful when you want to review the
#' potential fixes before accepting them. Setting this to `TRUE` will disable
#' the check on whether Git is used.
#'
#' @inheritSection lint Ignoring lines
#'
#' @export
#' @examples
#' # `fix_text()` is convenient to explore with a small example
#' fix_text("any(duplicated(rnorm(5)))")
#'
#' fix_text("any(duplicated(rnorm(5)))
#' any(is.na(x))
#' ")
#'
#' # Setup for the example with `fix()`
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
#' fix(destfile)
#' cat(paste(readLines(destfile), collapse = "\n"))
fix <- function(
  path = ".",
  linters = NULL,
  exclude_path = NULL,
  exclude_linters = NULL,
  force = FALSE,
  verbose = TRUE,
  rerun = TRUE,
  interactive = FALSE
) {
  if (isFALSE(verbose) | is_testing()) {
    withr::local_options(cli.default_handler = function(...) {
    })
  }

  if (isTRUE(interactive)) {
    rlang::check_installed(c("shiny", "diffviewer"))
  }

  rule_files <- resolve_linters(path, linters, exclude_linters)
  r_files <- resolve_path(path, exclude_path)
  fixes <- list()

  if (uses_git() && isFALSE(interactive)) {
    unstaged_files <- unlist(git2r::status()$unstaged)
    unstaged_files <- fs::path_abs(unstaged_files)
    if (any(r_files %in% unstaged_files)) {
      if (interactive()) {
        choice <- utils::menu(
          title = "It is recommended to commit or discard all modified files before running `fix()`. Do you want to apply fixes anyway?",
          choices = c("Yes", "No")
        )
        if (choice == 2) {
          cli::cli_inform(c(i = "No changes applied."))
          return(invisible())
        }
      } else if (isFALSE(force)) {
        stop(
          "It is recommended to commit or discard all modified files before running `fix()`. Therefore, this operation is not allowed by default in
        a non-interactive setting. Use `force = TRUE` to bypass this behavior."
        )
      }
    }
  }

  if (length(r_files) > 1 && !uses_git()) {
    if (interactive()) {
      choice <- utils::menu(
        title = "This will run `fix()` on several R files. It seems that you are not using Git, which will make it difficult to see the changes in code. Do you want to continue?",
        choices = c("Yes", "No")
      )
      if (choice == 2) {
        cli::cli_inform(c(i = "No changes applied."))
        return(invisible())
      }
    } else if (isFALSE(force)) {
      stop(
        "It seems that you are not using Git, but `fix()` will be applied on several R files. This will make it difficult to see the changes in code. Therefore, this operation is not allowed by default in a non-interactive setting. Use `force = TRUE` to bypass this behavior."
      )
    }
  }

  needed_fixing <- vector("list", length(r_files))
  n_fixes <- vector("list", length(r_files))

  cli::cli_alert_info("Going to check {length(r_files)} file{?s}.")
  i <- 0
  cli::cli_progress_bar(
    format = "{cli::pb_spin} Checking: {i}/{length(r_files)}"
  )

  for (i in seq_along(r_files)) {
    cli::cli_progress_update()
    file <- r_files[i]
    has_skipped_fixes <- TRUE
    repeat {
      if (!has_skipped_fixes) {
        break
      }
      res <- parse_and_rewrite_file(file, rule_files, interactive)
      needed_fixing[[file]] <- res[["needed_fixing"]]
      fixes[[file]] <- res[["fixes"]]
      n_fixes[[file]] <- res[["n_fixes"]]
      has_skipped_fixes <- res[["has_skipped_fixes"]]
    }
  }

  cli::cli_progress_done()

  if (!any(unlist(needed_fixing))) {
    cli::cli_alert_success("No fixes needed.")
  } else {
    cli::cli_alert_success(
      "Fixed {sum(unlist(n_fixes))} lint{?s} in {length(Filter(isTRUE, needed_fixing))} file{?s}."
    )
  }
  invisible(fixes)
}

#' @rdname fix
#' @export

fix_dir <- function(
  path = ".",
  linters = NULL,
  exclude_path = NULL,
  exclude_linters = NULL,
  force = FALSE,
  verbose = TRUE,
  rerun = TRUE,
  interactive = FALSE
) {
  if (!fs::is_dir(path)) {
    stop("`path` must be a directory.")
  }
  fix(
    path,
    linters = linters,
    exclude_path = exclude_path,
    exclude_linters = exclude_linters,
    force = force,
    verbose = verbose,
    rerun = rerun,
    interactive = interactive
  )
}

#' @rdname fix
#' @export

fix_package <- function(
  path = ".",
  linters = NULL,
  exclude_path = NULL,
  exclude_linters = NULL,
  force = FALSE,
  verbose = TRUE,
  rerun = TRUE,
  interactive = FALSE
) {
  if (!fs::is_dir(path)) {
    stop("`path` must be a directory.")
  }
  paths <- fs::path(
    path,
    c("R", "tests", "inst", "vignettes", "data-raw", "demo", "exec")
  )
  paths <- paths[fs::dir_exists(paths)]
  fix(
    paths,
    linters = linters,
    exclude_path = exclude_path,
    exclude_linters = exclude_linters,
    force = force,
    verbose = verbose,
    rerun = rerun,
    interactive = interactive
  )
}

#' @param text Text to analyze (and to fix if necessary).
#'
#' @rdname fix
#' @export
fix_text <- function(
  text,
  linters = NULL,
  exclude_linters = NULL,
  rerun = TRUE
) {
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
  out <- fix(
    tmp,
    linters = linters,
    exclude_linters = exclude_linters,
    verbose = FALSE,
    rerun = rerun
  )

  if (length(out[[1]]) == 0) {
    return(invisible())
  }
  class(out) <- c("flir_fix", class(out))
  attr(out, "original") <- text
  out
}

parse_and_rewrite_file <- function(file, rule_files, interactive) {
  needed_fixing <- TRUE

  file_to_parse <- file

  if (isTRUE(interactive)) {
    new_file <- tempfile(fileext = ".R")
    fs::file_copy(file, new_file)
    file_to_parse <- new_file
  }

  root <- astgrepr::tree_new(
    file = file_to_parse,
    ignore_tags = c("flir-ignore", "nolint")
  ) |>
    astgrepr::tree_root()

  lints_raw <- astgrepr::node_find_all(root, files = rule_files)

  lints <- Filter(Negate(is.null), lints_raw)
  lints <- Filter(function(x) length(attributes(x)$other_info$fix) > 0, lints)
  n_fixes <- length(lints)

  if (length(lints) == 0) {
    return(
      list(
        needed_fixing = FALSE,
        fixes = character(0),
        n_fixes = 0,
        has_skipped_fixes = FALSE
      )
    )
  }
  args <- append(
    list(x = astgrepr:::add_rulelist_class(lints)),
    vapply(
      lints,
      function(x) as.character(attributes(x)$other_info$fix),
      character(1)
    )
  )
  names(args)[2:length(args)] <- names(lints)
  replacement2 <- as.call(append(astgrepr::node_replace_all, args)) |> eval()

  fixes <- astgrepr::tree_rewrite(root, replacement2)

  if (isTRUE(interactive)) {
    writeLines(text = fixes, new_file)
    review_app(name = file, old_path = file, new_path = file_to_parse)
  } else {
    writeLines(text = fixes, file)
  }
  list(
    needed_fixing = needed_fixing,
    fixes = fixes,
    n_fixes = n_fixes,
    has_skipped_fixes = attr(fixes, "has_skipped_fixes")
  )
}
