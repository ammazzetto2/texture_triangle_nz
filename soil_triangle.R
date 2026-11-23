#------------------------------------------------- Required Libraries

source("R/dependencies.R", local = TRUE)
ensure_project_dependencies()

library(shiny)

source("R/validation.R", local = TRUE)
source("R/import.R", local = TRUE)

source("R/classification_systems.R", local = TRUE)
source("R/classification.R", local = TRUE)

source("R/plotting.R", local = TRUE)
source("R/workspace.R", local = TRUE)

source("R/ui.R", local = TRUE)
ui <- build_app_ui()

# Shared workspace state belongs to each session. Feature files use this same
# environment so sample changes, table revisions, and chart selection stay aligned.
server <- function(input, output, session) {
  # Initialize empty dataframe to hold soil data
  soil_data <- reactiveVal(data.frame(
    soil = character(),
    sand = numeric(),
    silt = numeric(),
    clay = numeric()
  ))
  undo_state <- reactiveVal(NULL)
  sample_feedback <- reactiveVal("")
  data_revision <- reactiveVal(0L)
  selected_sample <- reactiveVal(NULL)

  change_samples <- function(samples, description) {
    undo_state(list(data = soil_data(), description = description))
    soil_data(samples)
    selected_sample(NULL)
    data_revision(data_revision() + 1L)
    sample_feedback(description)
  }

  # The on-screen table and shared download use the same calculated results.
  classified_data <- reactive({
    req(input$dataset)
    classify_soil_data(soil_data(), input$dataset)
  })

  # Reject clicks from an older table so a shifted row can never be changed.
  current_row <- function(target) {
    if (!is.list(target) || length(target$row) != 1L ||
        length(target$revision) != 1L || !is.numeric(target$row) ||
        !is.numeric(target$revision) || !is.finite(target$row) ||
        !is.finite(target$revision) || target$revision != data_revision() ||
        target$row != floor(target$row) || target$row < 1L ||
        target$row > nrow(soil_data())) return(NULL)
    as.integer(target$row)
  }

  source("R/server/samples.R", local = TRUE)
  source("R/server/imports.R", local = TRUE)
  source("R/server/results.R", local = TRUE)
  source("R/server/charts.R", local = TRUE)
  source("R/server/workspace.R", local = TRUE)
}

shinyApp(ui = ui, server = server)
