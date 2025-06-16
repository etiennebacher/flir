clean_lints <- function(lints_raw, file) {
  locs <- astgrepr::node_range_all(lints_raw)
  txts <- astgrepr::node_text_all(lints_raw)

  # for data.table NOTE on undefined objects
  line_start <- NULL

  locs_reorg <- lapply(seq_along(locs), function(x) {
    dat <- locs[[x]]
    res <- data.table::rbindlist(
      lapply(dat, function(y) {
        # locations are 0-indexed
        list(
          line_start = y$start[1] + 1,
          col_start = y$start[2] + 1,
          line_end = y$end[1] + 1,
          col_end = y$end[2] + 1
        )
      }),
      use.names = TRUE
    )
    if (nrow(res) > 0) {
      res[["id"]] <- names(locs)[x]
    }
    res
  })
  locs_reorg <- Filter(function(x) length(x) > 0, locs_reorg)

  locs2 <- data.table::rbindlist(locs_reorg, use.names = TRUE)
  txts2 <- data.table::data.table(
    text = unlist(txts, recursive = TRUE, use.names = FALSE)
  )

  other_info <- lapply(seq_along(lints_raw), function(x) {
    res <- attributes(lints_raw[[x]])[["other_info"]]
    res[["language"]] <- NULL
    # If there are several constraints, then the output (including the message)
    # will be duplicated. Constraints are not actually needed in the output.
    res[["constraints"]] <- NULL
    res[["id"]] <- names(lints_raw)[x]
    res
  })

  other_info <- data.table::rbindlist(other_info, fill = TRUE, use.names = TRUE)

  lints <- cbind(txts2, locs2)
  lints <- merge(lints, other_info, by = "id", all.x = TRUE)
  lints[["file"]] <- file
  lints <- unique(lints)

  lints[order(line_start)]
}

get_tests_from_lintr <- function(name) {
  url <- paste0(
    "https://raw.githubusercontent.com/r-lib/lintr/main/tests/testthat/test-",
    name,
    "_linter.R"
  )
  dest <- paste0("tests/testthat/test-", name, ".R")
  utils::download.file(url, destfile = dest)
  if (rlang::is_interactive()) {
    utils::file.edit(dest)
  }
}

resolve_linters <- function(path, linters, exclude_linters) {
  if (is_flir_package(path)) {
    path_to_rules <- fs::path("inst/rules/builtin")
  } else {
    path_to_rules <- fs::path(system.file(package = "flir"), "rules", "builtin")
  }

  rules <- list.files(path_to_rules, pattern = "\\.yml$", full.names = TRUE)
  custom_rules <- get_custom_linters(path)
  rules <- c(rules, custom_rules)

  rules_basename <- basename(rules)
  rules_basename_noext <- gsub("\\.yml$", "", rules_basename)

  if (anyDuplicated(rules_basename) > 0) {
    cli::cli_abort(
      paste0(
        "Some rule files are duplicated: ",
        toString(rules_basename[duplicated(rules_basename)])
      ),
      call = rlang::caller_env()
    )
  }

  path_common <- if (length(path) > 1) {
    if (all(fs::path_has_parent(path, "."))) {
      "."
    } else {
      fs::path_common(path)
    }
  } else {
    path
  }

  # All linters passed to lint() / fix()
  if (is.null(exclude_linters) && uses_flir(path_common)) {
    exclude_linters <- get_excluded_linters_from_config(path_common)
  }

  if (is.null(linters)) {
    if (uses_flir(path_common)) {
      check_config(path_common)
      linters <- get_linters_from_config(path_common)
      linters <- c(linters, get_external_linters_from_config(path_common))
    } else {
      linters <- rules_basename_noext
    }
  } else {
    if (is.list(linters)) {
      # for compat with lintr
      linters <- unlist(linters)
    }
  }

  linters <- setdiff(linters, exclude_linters)
  if (any(fs::is_absolute_path(linters))) {
    regex <- paste0(
      "/(",
      paste(exclude_linters, collapse = "|"),
      ")\\.(yml|yaml)$"
    )
    linters <- grep(regex, linters, invert = TRUE, value = TRUE)
  }
  linters <- keep_or_exclude_testthat_rules(path, linters)

  # Ignore unreachable_code in tests
  if (is_flir_package(path)) {
    linters <- linters[grep(
      "unreachable_code",
      linters,
      fixed = TRUE,
      invert = TRUE
    )]
  }

  if (
    !all(linters %in% rules_basename_noext | linter_is_path_to_yml(linters))
  ) {
    cli::cli_abort(
      paste0(
        "Unknown linters: ",
        toString(
          linters[
            !linters %in% rules_basename_noext & !linter_is_path_to_yml(linters)
          ]
        )
      ),
      call = rlang::caller_env()
    )
  }

  paths_to_yaml <- Filter(function(x) linter_is_path_to_yml(x), linters)
  if (length(paths_to_yaml) > 0) {
    paths_to_yaml <- fs::path_abs(paths_to_yaml)
  }

  res <- rules[match(linters, rules_basename_noext)]
  res <- res[!is.na(res)]
  c(res, paths_to_yaml)
}

linter_is_path_to_yml <- function(x) {
  vapply(x, function(y) grepl("\\.(yaml|yml)$", y), FUN.VALUE = logical(1L))
}


resolve_path <- function(path, exclude_path) {
  paths <- lapply(path, function(x) {
    if (fs::is_dir(x)) {
      list.files(x, pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
    } else {
      x
    }
  }) |>
    unlist() |>
    unique() |>
    fs::path_abs()

  excluded <- lapply(exclude_path, function(x) {
    if (fs::is_dir(x)) {
      list.files(x, pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
    } else {
      x
    }
  }) |>
    unlist() |>
    unique() |>
    fs::path_abs()

  setdiff(paths, excluded)
}

resolve_hashes <- function(path, use_cache) {
  if (!use_cache || !uses_flir(path)) {
    NULL
  } else if (is_flir_package(path) || is_testing()) {
    readRDS(file.path("inst/cache_file_state.rds"))
  } else {
    readRDS(file.path("flir/cache_file_state.rds"))
  }
}

is_flir_package <- function(path) {
  if (length(path) > 1) {
    path <- fs::path_common(path)
  }
  if (fs::is_file(path)) {
    path <- fs::path_dir(path)
  }
  path <- file.path(path, "DESCRIPTION")
  if (!fs::file_exists(path)) {
    return(FALSE)
  }
  read.dcf(path)[, "Package"] == "flir"
}

uses_flir <- function(path = ".") {
  if (length(path) > 1) {
    if (all(fs::path_has_parent(path, "."))) {
      path <- "."
    } else {
      path <- fs::path_common(path)
    }
  }
  tryCatch(
    path <- rprojroot::find_root(
      rprojroot::is_rstudio_project | rprojroot::is_r_package,
      path = path
    ),
    error = function(e) return(FALSE)
  )
  flir_dir <- fs::path(path, "flir")
  fs::dir_exists(flir_dir) && length(list.files(flir_dir)) > 0
}

get_custom_linters <- function(path = ".") {
  if (length(path) > 1) {
    if (all(fs::path_has_parent(path, "."))) {
      path <- "."
    } else {
      path <- fs::path_common(path)
    }
  }
  tryCatch(
    path <- rprojroot::find_root(
      rprojroot::is_rstudio_project | rprojroot::is_r_package,
      path = path
    ),
    error = function(e) return(FALSE)
  )
  flir_dir <- fs::path(path, "flir")
  if (
    uses_flir(path) && fs::dir_exists(fs::path(flir_dir, "rules", "custom"))
  ) {
    list.files(
      fs::path(flir_dir, "rules", "custom"),
      pattern = "\\.yml$",
      full.names = TRUE
    )
  }
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

is_r_package <- function(path = ".") {
  tr <- try(
    rprojroot::find_root(rprojroot::is_r_package, path = path),
    silent = TRUE
  )
  !inherits(tr, "try-error")
}

new_rule <- function(name) {
  dest <- paste0("inst/rules/builtin/", name, ".yml")
  cat(
    "id: ...
language: r
severity: warning
rule:
  pattern: ...
fix: ...
message: ...
",
    file = dest
  )
  if (rlang::is_interactive()) {
    utils::file.edit(dest)
  }
}

uses_git <- function() {
  fs::dir_exists(".git")
}

# By default, we want this to be TRUE if we're not inside a package (e.g.
# testing on temp files).
uses_testthat <- function(path = ".") {
  out <- TRUE
  testthat_folder_exists <- unname(fs::dir_exists(fs::path(
    path,
    "tests",
    "testthat"
  )))
  if (is_r_package(path) && !testthat_folder_exists) {
    out <- FALSE
  }
  out
}

is_positron <- function() {
  identical(Sys.getenv("POSITRON"), "1")
}

keep_or_exclude_testthat_rules <- function(path, linters) {
  if (length(path) > 1) {
    path <- fs::path_common(fs::path_abs(path))
  }
  if (fs::is_file(path)) {
    path <- fs::path_dir(path)
  }
  if (!uses_testthat(path)) {
    exclude <- c(
      "expect_comparison",
      "expect_identical",
      "expect_length",
      "expect_named",
      "expect_not",
      "expect_null",
      "expect_true_false",
      "expect_type"
    )
    linters <- setdiff(linters, exclude)
  }
  linters
}
