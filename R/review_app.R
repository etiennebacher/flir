# Taken from testthat:::review_app()
# https://github.com/r-lib/testthat/blob/30f5b119875852005f2a02e6adf96276dbd1ef26/R/snapshot-manage.R#L45
# MIT License
review_app <- function(name, old_path, new_path) {
  stopifnot(
    length(name) == length(old_path),
    length(old_path) == length(new_path)
  )
  n <- length(name)
  case_index <- stats::setNames(seq_along(name), name)
  skipped <- FALSE
  handled <- rep(FALSE, n)
  ui <- shiny::fluidPage(
    style = "margin: 0.5em",
    shiny::fluidRow(
      style = "display: flex",
      shiny::div(
        style = "flex: 1 1",
        shiny::selectInput("cases", NULL, case_index, width = "100%")
      ),
      shiny::div(
        class = "btn-group",
        style = "margin-left: 1em; flex: 0 0 auto",
        shiny::actionButton("skip", "Skip"),
        shiny::actionButton("accept", "Accept", class = "btn-success"),
      )
    ),
    shiny::fluidRow(diffviewer::visual_diff_output("diff"))
  )
  server <- function(input, output, session) {
    i <- shiny::reactive(as.numeric(input$cases))
    output$diff <- diffviewer::visual_diff_render({
      diffviewer::visual_diff(old_path[[i()]], new_path[[i()]])
    })
    shiny::observeEvent(input$accept, {
      rlang::inform(paste0("Accepting snapshot: '", old_path[[i()]], "'"))
      file.rename(new_path[[i()]], old_path[[i()]])
      update_cases()
    })
    shiny::observeEvent(input$skip, {
      handled[[i()]] <<- TRUE
      skipped <<- TRUE
      i <- next_case()
      shiny::updateSelectInput(session, "cases", selected = i)
    })
    update_cases <- function() {
      handled[[i()]] <<- TRUE
      i <- next_case()
      shiny::updateSelectInput(
        session,
        "cases",
        choices = case_index[!handled],
        selected = i
      )
    }
    next_case <- function() {
      if (all(handled)) {
        rlang::inform("Review complete")
        shiny::stopApp()
        return()
      }
      remaining <- case_index[!handled]
      next_cases <- which(remaining > i())
      if (length(next_cases) == 0) remaining[[1]] else
        remaining[[next_cases[[1]]]]
    }
  }
  rlang::inform(c(
    "Starting Shiny app for snapshot review",
    i = "Use Escape to quit"
  ))
  shiny::runApp(
    shiny::shinyApp(ui, server),
    quiet = TRUE,
    launch.browser = shiny::paneViewer()
  )
  skipped
}
