#------------------------------------------------- Required Libraries

source("R/dependencies.R", local = TRUE)
ensure_project_dependencies()

library(shiny)

source("R/validation.R", local = TRUE)

source("R/classification_systems.R", local = TRUE)
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
  undo_state <- reactiveVal(NULL)
  sample_feedback <- reactiveVal("")
  data_revision <- reactiveVal(0L)
  edit_target <- reactiveVal(NULL)
  edit_error <- reactiveVal("")

  change_samples <- function(samples, description) {
    undo_state(list(data = soil_data(), description = description))
    soil_data(samples)
    data_revision(data_revision() + 1L)
    sample_feedback(description)
  }

  output$sampleFeedback <- renderText(sample_feedback())
  output$undoControl <- renderUI({
    previous <- undo_state()
    if (is.null(previous)) return(NULL)
    actionButton("undoDataBtn", paste("Undo:", previous$description),
                 class = "btn-outline-primary undo-samples")
  })

  observeEvent(input$undoDataBtn, {
    previous <- undo_state()
    req(previous)
    soil_data(previous$data)
    data_revision(data_revision() + 1L)
    undo_state(NULL)
    sample_feedback(paste("Undone:", previous$description))
  }, ignoreInit = TRUE)

  # The on-screen table and shared download use the same calculated results.
  classified_data <- reactive({
    req(input$dataset)
    classify_soil_data(soil_data(), input$dataset)
  })

  output$classificationReference <- renderUI({
    req(input$dataset)
    definition <- classification_definition(input$dataset)
    if (is.null(definition$source)) {
      return(tags$p("The selected system uses the original project polygons; their source provenance remains under review."))
    }
    key <- classification_label_key(input$dataset)
    label_key <- if (nrow(key)) tags$details(
      tags$summary("Class label key"),
      tags$table(class = "table table-sm",
        tags$thead(tags$tr(tags$th("Plot label"), tags$th("Class"))),
        tags$tbody(lapply(seq_len(nrow(key)), function(i) {
          tags$tr(tags$td(key$Label[i]), tags$td(key$Class[i]))
        })))
    )
    tagList(
      label_key,
      tags$p(tags$strong(definition$source)),
      tags$p(definition$fractions, " Enter percentages for the fine-earth fraction. Changing the system does not convert laboratory particle-size measurements."),
      tags$p(tags$a("View source publication", href = definition$source_url, target = "_blank", rel = "noopener"))
    )
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
    build_results_table(results_table(), revision = data_revision())
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

  output$editSampleError <- renderText(edit_error())
  observeEvent(input$editSample, {
    row <- current_row(input$editSample)
    req(row)
    sample <- soil_data()[row, ]
    edit_target(input$editSample)
    edit_error("")
    showModal(modalDialog(
      title = "Edit sample", easyClose = FALSE,
      textInput("editSampleName", "Sample name", value = sample$soil),
      tags$div(class = "composition-inputs",
        numericInput("editSand", "Sand (%)", sample$sand, min = 0, max = 100),
        numericInput("editSilt", "Silt (%)", sample$silt, min = 0, max = 100),
        numericInput("editClay", "Clay (%)", sample$clay, min = 0, max = 100)),
      tags$p(class = "field-help", "Percentages must total 100%. Changes update the triangle and results."),
      tags$p(class = "edit-sample-error", role = "alert", textOutput("editSampleError", inline = TRUE)),
      footer = tagList(modalButton("Cancel"),
                       actionButton("saveSampleBtn", "Save changes", class = "btn-primary"))
    ))
  })

  observeEvent(input$saveSampleBtn, {
    req(edit_target())
    row <- current_row(edit_target())
    if (is.null(row)) {
      edit_error("The dataset changed while this editor was open. Cancel and reopen the sample from Results.")
      return()
    }
    sample <- tryCatch({
      values <- list(input$editSampleName, input$editSand, input$editSilt, input$editClay)
      if (any(lengths(values) != 1L)) stop("Enter a sample name and all three percentages.", call. = FALSE)
      validate_soil_data(data.frame(soil = input$editSampleName, sand = input$editSand,
                                   silt = input$editSilt, clay = input$editClay))
    }, error = function(e) { edit_error(conditionMessage(e)); NULL })
    if (is.null(sample)) return()
    samples <- soil_data()
    if (!all(samples[row, ] == sample[1, ])) {
      others <- setdiff(seq_len(nrow(samples)), row)
      if (any(vapply(others, function(i) all(samples[i, ] == sample[1, ]), logical(1)))) {
        edit_error("This sample name and composition already exist. Use a different name for a replicate.")
        return()
      }
      samples[row, ] <- sample[1, ]
      change_samples(samples, paste("Updated", sample$soil))
    }
    edit_target(NULL)
    removeModal()
  }, ignoreInit = TRUE)

  observeEvent(input$deleteSample, {
    row <- current_row(input$deleteSample)
    req(row)
    samples <- soil_data()
    change_samples(samples[-row, , drop = FALSE], paste("Removed", samples$soil[row]))
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
      tags$small(if (!valid) "Must total 100%" else if (
        is.null(input$sampleName) || !nzchar(trimws(input$sampleName))
      ) "Enter a sample name to continue" else "Ready to add")
    )
  })

  # Keep the existing dataset intact when validation fails.
  add_samples <- function(read_samples, manual = FALSE) {
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
      if (manual && any(vapply(seq_len(nrow(soil_data())), function(i) {
        all(soil_data()[i, ] == samples[1, ])
      }, logical(1)))) {
        sample_feedback("This sample name and composition already exist. Use a different name for a replicate.")
        return(invisible(FALSE))
      }
      description <- if (manual) paste("Added", samples$soil) else
        paste("Imported", nrow(samples), "sample(s)")
      change_samples(rbind(soil_data(), samples), description)
      if (manual) updateTextInput(session, "sampleName", value = "")
      return(invisible(TRUE))
    }
    invisible(FALSE)
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
    }, manual = TRUE)
  })

  observeEvent(input$fileUpload, {
    req(input$fileUpload)
    format <- if (is.null(input$csvFormat)) "samples" else input$csvFormat
    added <- add_samples(function() read_soil_csv(input$fileUpload$datapath, format = format))
    if (added && identical(format, "results")) {
      sample_feedback(paste0(sample_feedback(), "; classifications recalculated using ", input$dataset, "."))
    }
  })

  observeEvent(input$clearDataBtn, {
    if (!nrow(soil_data())) return()
    change_samples(soil_data()[FALSE, ], "Cleared all samples")
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
