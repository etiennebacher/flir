get_config_file <- function(path) {
  if (fs::is_file(path)) {
    path <- tryCatch(
      rprojroot::find_root(
        rprojroot::is_rstudio_project | rprojroot::is_r_package,
        path = path
      ),
      error = function(e) fs::path_dir(path)
    )
  }
  if (is_flir_package(path)) {
    config_file <- "inst/config.yml"
  } else {
    config_file <- "flir/config.yml"
  }
  config_file
}

check_config <- function(path) {
  config_file <- get_config_file(path)
  if (!fs::file_exists(config_file)) {
    return(invisible())
  }
  nms <- names(yaml::read_yaml(config_file, readLines.warn = FALSE))
  nms_unexpected <- setdiff(nms, c("keep", "exclude", "from-package"))
  if (length(nms_unexpected) > 0) {
    stop(sprintf(
      "Unknown field in `flir/config.yml`: %s",
      toString(nms_unexpected)
    ))
  }
}

get_linters_from_config <- function(path) {
  config_file <- get_config_file(path)
  if (!fs::file_exists(config_file)) {
    return(invisible())
  }
  linters <- yaml::read_yaml(config_file, readLines.warn = FALSE)[["keep"]]
  from_package <- yaml::read_yaml(config_file, readLines.warn = FALSE)[[
    "from-package"
  ]]
  if (length(linters) == 0 && length(from_package) == 0) {
    stop("`", config_file, "` exists but doesn't contain any rule.")
  }
  if (anyDuplicated(linters) > 0) {
    stop(
      "In `",
      config_file,
      "`, the following linters are duplicated: ",
      toString(linters[duplicated(linters)])
    )
  }
  linters
}

get_excluded_linters_from_config <- function(path) {
  config_file <- get_config_file(path)
  if (!fs::file_exists(config_file)) {
    return(invisible())
  }

  linters <- yaml::read_yaml(config_file, readLines.warn = FALSE)[["exclude"]]
  if (length(linters) == 0) {
    return(NULL)
  }
  if (anyDuplicated(linters) > 0) {
    stop(
      "In `",
      config_file,
      "`, the following excluded linters are duplicated: ",
      toString(linters[duplicated(linters)])
    )
  }
  linters
}

get_external_linters_from_config <- function(path) {
  config_file <- get_config_file(path)
  if (!fs::file_exists(config_file)) {
    return(invisible())
  }

  pkgs <- yaml::read_yaml(config_file, readLines.warn = FALSE)[["from-package"]]
  if (length(pkgs) == 0) {
    return(NULL)
  }
  if (anyDuplicated(pkgs) > 0) {
    stop(
      "In `",
      config_file,
      "`, the following packages are duplicated: ",
      toString(pkgs[duplicated(pkgs)])
    )
  }

  installed <- pkgs[pkgs == basename(pkgs)]
  remote <- pkgs[grep("/", pkgs)]
  linters <- NULL

  if (length(installed) > 0) {
    rlang::check_installed(installed)
    for (i in installed) {
      pkg_linters <- list.files(
        system.file("flir/rules", package = i),
        pattern = "\\.(yml|yaml)",
        full.names = TRUE
      )

      ### Some packages may contain rules with the same name, so we want the
      ### id to be differentiated by adding a prefix with the package name.
      ### Problem: IDs are parsed in astgrepr, so I need to modify the yaml files
      ### while not modifying the files in the other package, which is why I
      ### copy the external rules to a tempdir first.
      new_pkg_linters <- fs::file_copy(
        pkg_linters,
        fs::path_temp(paste0("from-", i, "-", basename(pkg_linters))),
        overwrite = TRUE
      )
      for (file in new_pkg_linters) {
        yaml <- yaml::read_yaml(file)
        # I could have a rule named "dplyr-superseded" that doesn't come from
        # dplyr, so I add "from" too.
        yaml[["id"]] <- paste0("from-", i, yaml[["id"]])
        yaml::write_yaml(yaml, file)
      }

      linters <- append(linters, new_pkg_linters)
    }
  }

  if (length(remote) > 0) {
    # TODO: finish handling of remote
    stop("In config, `from-package` doesn't support remote packages yet.")
    path_to_rules <- vector("character", length = length(remote))
    for (i in remote) {
      path_to_rules[i] <- sprintf(
        "https://raw.githubusercontent.com/%s/refs/heads/main/inst/flir/rules",
        i
      )
    }
  }

  pkgs_short <- basename(pkgs)
  linters
}
