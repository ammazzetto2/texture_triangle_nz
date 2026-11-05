#------------------------------------------------- Required Libraries

source("R/dependencies.R", local = TRUE)
ensure_project_dependencies()

library(shiny)

source("R/validation.R", local = TRUE)

source("R/classification_data.R", local = TRUE)
source("R/classification.R", local = TRUE)

source("R/plotting.R", local = TRUE)

source("R/ui.R", local = TRUE)
ui <- build_app_ui()

# Define server logic
server <- function(input, output, session) {
  
  # Initialize empty dataframe to hold soil data
  soil_data <- reactiveVal(data.frame(
    soil = character(),
    sand = numeric(),
    silt = numeric(),
    clay = numeric()
  ))

  # The on-screen table and shared download use the same calculated results.
  classified_data <- reactive({
    req(input$dataset)
    classify_soil_data(soil_data(), input$dataset)
  })

  output$resultsSummary <- renderText({
    results <- classified_data()
    if (nrow(results) == 0L) return("No samples yet. Add a sample or upload a CSV.")
    unresolved <- sum(is.na(results$classification))
    paste0(input$dataset, ": ", nrow(results), " sample(s), ",
           unresolved, " without a single class")
  })

  results_table <- reactive({
    results <- classified_data()
    clean_label <- function(x) gsub("[[:space:]]+", " ", x)
    data.frame(
      Sample = results$soil,
      `Sand (%)` = results$sand,
      `Silt (%)` = results$silt,
      `Clay (%)` = results$clay,
      Class = ifelse(is.na(results$classification), "—", clean_label(results$classification)),
      Status = results$classification_status,
      `Candidate classes` = clean_label(results$classification_candidates),
      check.names = FALSE
    )
  })

  output$resultsTable <- renderUI({
    build_results_table(results_table())
  })

  output$workspaceStats <- renderUI({
    results <- classified_data()
    tagList(
      tags$span(class = "stat-chip", tags$strong(nrow(results)),
                if (nrow(results) == 1L) " sample" else " samples"),
      tags$span(class = "stat-chip", tags$strong(sum(is.na(results$classification))),
                " need review")
    )
  })

  output$compositionTotal <- renderUI({
    values <- c(input$sandValue, input$siltValue, input$clayValue)
    if (length(values) != 3L || any(!is.finite(values))) {
      return(tags$div(class = "composition-total", "Enter all three percentages."))
    }
    total <- sum(values)
    valid <- all(values >= 0 & values <= 100) && abs(total - 100) <= 1e-8
    tags$div(class = paste("composition-total", if (valid) "total-valid" else "total-invalid"),
      tags$span("Composition total"),
      tags$strong(paste0(format(round(total, 6), trim = TRUE), "%")),
      tags$small(if (valid) "Ready to add" else "Must total 100%")
    )
  })

  # Keep the existing dataset intact when validation fails.
  add_samples <- function(read_samples) {
    samples <- tryCatch(
      read_samples(),
      error = function(e) {
        showModal(modalDialog(
          title = "Check sample data",
          conditionMessage(e),
          easyClose = TRUE
        ))
        NULL
      }
    )
    if (!is.null(samples)) {
      soil_data(rbind(soil_data(), samples))
    }
  }

  observeEvent(input$addManualDataBtn, {
    add_samples(function() {
      values <- list(input$sampleName, input$sandValue,
                     input$siltValue, input$clayValue)
      if (any(lengths(values) != 1L)) {
        stop("Enter a sample name and all three percentages.", call. = FALSE)
      }
      validate_soil_data(data.frame(
        soil = input$sampleName,
        sand = input$sandValue,
        silt = input$siltValue,
        clay = input$clayValue
      ))
    })
  })

  observeEvent(input$fileUpload, {
    req(input$fileUpload)
    add_samples(function() read_soil_csv(input$fileUpload$datapath))
  })

  observeEvent(input$clearDataBtn, {
    soil_data(data.frame(soil = character(), sand = numeric(),
                         silt = numeric(), clay = numeric()))
  })

  # Download template CSV
  output$downloadTemplateBtn <- downloadHandler(
    filename = function() {
      "template_soil_data.csv"
    },
    content = function(file) {
      template <- data.frame(
        soil = character(),
        sand = numeric(),
        silt = numeric(),
        clay = numeric()
      )
      write.csv(template, file, row.names = FALSE)
    }
  )
  
  output$downloadDataBtn <- downloadHandler(
    filename = function() "soil_texture_results.csv",
    content = function(file) {
      write.csv(classified_data(), file, row.names = FALSE)
    }
  )

  output$ternaryPlot <- renderPlot({
    req(input$dataset)
    width <- session$clientData$output_ternaryPlot_width
    height <- session$clientData$output_ternaryPlot_height
    dimensions <- c(width, height)
    text_scale <- if (length(dimensions) != 2L || any(!is.finite(dimensions))) 1 else
      max(0.65, min(1, width / 750, height / 560))
    print(build_soil_plot(soil_data(), input$dataset, text_scale = text_scale,
                          show_labels = !identical(input$showSampleLabels, FALSE)))
  })

  
}
  
# Run the application
shinyApp(ui = ui, server = server)
