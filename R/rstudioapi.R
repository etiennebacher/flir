# Taken from lintr: R/lint.R

rstudio_source_markers <- function(lints) {
  if (nrow(lints) == 0) {
    return(invisible())
  }
  if (any(startsWith(lints$file, "./"))) {
    lints$file <- normalizePath(lints$file)
  }

  lints$severity[lints$severity == "hint"] <- "usage"
  lints$severity[lints$severity == "info"] <- "info"

  # generate the markers
  markers <- lints[,
    c("severity", "file", "line_start", "col_start", "message")
  ]
  names(markers) <- c("type", "file", "line", "column", "message")
  markers <- split(markers, seq_len(nrow(markers)))
  markers <- lapply(markers, as.list)
  markers <- unname(markers)

  # request source markers
  out <- rstudioapi::callFun(
    "sourceMarkers",
    name = "flir",
    markers = markers,
    basePath = getwd(),
    autoSelect = "first"
  )

  # workaround to avoid focusing an empty Markers pane
  # when possible, better solution is to delete the "lintr" source marker list
  # https://github.com/rstudio/rstudioapi/issues/209
  if (length(lints) == 0L) {
    Sys.sleep(0.1)
    rstudioapi::executeCommand("activateConsole")
  }

  out
}
