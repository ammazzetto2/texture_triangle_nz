#------------------------------------------------- Required Libraries

source("R/dependencies.R", local = TRUE)
ensure_project_dependencies()

library(shiny)

source("R/validation.R", local = TRUE)
source("R/import.R", local = TRUE)

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
  review_only <- reactiveVal(FALSE)
  selected_sample <- reactiveVal(NULL)
  results_page <- reactiveVal(1L)
  manual_error <- reactiveVal("")
  pending_upload <- reactiveVal(NULL)
  upload_error <- reactiveVal("")
  output$manualError <- renderText(manual_error())
  output$uploadError <- renderText(upload_error())
  observeEvent(list(input$sampleName, input$sandValue, input$siltValue, input$clayValue), {
    manual_error("")
  }, priority = 10)
  observeEvent(input$calculateRemainderBtn, {
    tryCatch({
      values <- c(sand = input$sandValue, silt = input$siltValue, clay = input$clayValue)
      value <- remaining_percentage(values, input$remainderComponent)
      updateNumericInput(session, paste0(input$remainderComponent, "Value"), value = value)
      manual_error("")
    }, error = function(e) manual_error(conditionMessage(e)))
  })
  observeEvent(input$openResults, {
    updateTabsetPanel(session, "workspaceView", selected = "results")
  })

  observeEvent(input$reviewOnly, {
    review_only(isTRUE(input$reviewOnly))
  })
  observeEvent(input$reviewSamplesBtn, {
    review_only(TRUE)
    updateTextInput(session, "sampleSearch", value = "")
    updateCheckboxInput(session, "reviewOnly", value = TRUE)
    updateTabsetPanel(session, "workspaceView", selected = "results")
  }, ignoreInit = TRUE)

  change_samples <- function(samples, description) {
    undo_state(list(data = soil_data(), description = description))
    soil_data(samples)
    selected_sample(NULL)
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
    selected_sample(NULL)
    data_revision(data_revision() + 1L)
    undo_state(NULL)
    sample_feedback(paste("Undone:", previous$description))
  }, ignoreInit = TRUE)

  # The on-screen table and shared download use the same calculated results.
  classified_data <- reactive({
    req(input$dataset)
    classify_soil_data(soil_data(), input$dataset)
  })

  output$systemRequirements <- renderUI({
    req(input$dataset)
    build_system_requirements(classification_definition(input$dataset))
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

  matching_result_rows <- reactive({
    results <- classified_data()
    rows <- if (review_only()) which(is.na(results$classification)) else seq_len(nrow(results))
    search <- if (is.null(input$sampleSearch)) "" else trimws(input$sampleSearch)
    if (nzchar(search)) rows <- rows[grepl(tolower(search), tolower(results$soil[rows]), fixed = TRUE)]
    column <- input$resultsSort
    allowed <- c("soil", "sand", "silt", "clay", "classification", "classification_status", "classification_candidates")
    if (length(column) == 1L && column %in% allowed) {
      values <- results[[column]][rows]
      if (is.character(values)) values <- tolower(values)
      rows <- rows[order(values, decreasing = isTRUE(input$sortDescending), na.last = TRUE, method = "radix")]
    } else if (isTRUE(input$sortDescending)) {
      rows <- rev(rows)
    }
    rows
  })
  results_page_size <- reactive({
    size <- suppressWarnings(as.integer(input$resultsPageSize))
    if (length(size) != 1L || is.na(size) || !size %in% c(25L, 50L, 100L)) 25L else size
  })
  results_page_count <- reactive(max(1L, ceiling(length(matching_result_rows()) / results_page_size())))
  current_results_page <- reactive(min(results_page(), results_page_count()))
  observeEvent(list(input$sampleSearch, input$resultsSort, input$sortDescending,
                    input$resultsPageSize, review_only(), input$dataset), {
    results_page(1L)
  }, priority = 10)
  observeEvent(input$previousResultsPage, {
    results_page(max(1L, current_results_page() - 1L))
  }, ignoreInit = TRUE)
  observeEvent(input$nextResultsPage, {
    results_page(min(results_page_count(), current_results_page() + 1L))
  }, ignoreInit = TRUE)
  visible_result_rows <- reactive({
    rows <- matching_result_rows()
    start <- (current_results_page() - 1L) * results_page_size() + 1L
    head(rows[seq_along(rows) >= start], results_page_size())
  })
  output$resultsPagination <- renderUI({
    if (length(matching_result_rows()) <= results_page_size()) return(NULL)
    tagList(
      actionButton("previousResultsPage", "Previous", class = "btn-outline-primary",
                   disabled = current_results_page() == 1L),
      tags$span(role = "status", paste("Page", current_results_page(), "of", results_page_count())),
      actionButton("nextResultsPage", "Next", class = "btn-outline-primary",
                   disabled = current_results_page() == results_page_count()))
  })
  output$resultsFilterSummary <- renderText({
    paste0("Showing ", length(visible_result_rows()), " of ", nrow(soil_data()),
           " samples (", length(matching_result_rows()), " match filters). CSV downloads include all samples.")
  })
  output$resultsTable <- renderUI({
    rows <- visible_result_rows()
    if (nrow(soil_data()) && !length(rows)) {
      has_search <- !is.null(input$sampleSearch) && nzchar(trimws(input$sampleSearch))
      return(tags$div(class = "empty-state",
        tags$h3(if (has_search) "No matching samples" else "No samples need review"),
        tags$p(if (has_search) "Try another sample name or turn off the review filter." else
          "Every sample has a single assigned class in this system. Turn off the filter to view all samples.")))
    }
    build_results_table(results_table()[rows, , drop = FALSE],
                        revision = data_revision(), row_indices = rows)
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
  observeEvent(input$viewSample, {
    row <- current_row(input$viewSample)
    req(row)
    selected_sample(row)
    updateTabsetPanel(session, "workspaceView", selected = "triangle")
  })
  observeEvent(input$clearPlotSelection, selected_sample(NULL), ignoreInit = TRUE)
  output$plotSelection <- renderUI({
    row <- selected_sample()
    if (is.null(row)) return(tags$p("Use View beside a sample in Results to highlight it. Hidden labels do not remove points."))
    sample <- classified_data()[row, ]
    tagList(tags$p(role = "status", tags$strong(sample$soil),
      paste0(": sand ", sample$sand, "%, silt ", sample$silt, "%, clay ", sample$clay, "%. "),
      if (is.na(sample$classification)) paste("Candidates:", sample$classification_candidates) else sample$classification),
      actionButton("clearPlotSelection", "Clear highlight", class = "btn-outline-primary"))
  })
  observeEvent(input$classKeyBtn, {
    definition <- classification_definition(input$dataset)
    labels <- unique(definition$data$Label)
    key <- lapply(labels, function(label) {
      short <- definition$label_overrides[[canonical_texture_label(label)]]$text
      tags$tr(tags$td(if (is.null(short)) label else short), tags$td(canonical_texture_label(label)))
    })
    showModal(modalDialog(title = "Class key", tags$p(definition$display),
      tags$table(class = "table", tags$thead(tags$tr(tags$th(scope = "col", "Plot label"), tags$th(scope = "col", "Class"))),
                 tags$tbody(key)), easyClose = TRUE, footer = modalButton("Close")))
  })
  observeEvent(input$enlargePlotBtn, {
    showModal(modalDialog(title = "Enlarged triangle", size = "l",
      tags$div(class = "enlarged-plot", plotOutput("enlargedPlot", height = "100%")),
      tags$p(class = "field-help", "Uses the same labels and highlighted sample as the main chart. Close to change chart controls."),
      easyClose = TRUE, footer = modalButton("Close")))
  })
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
      actionButton("reviewSamplesBtn",
        tagList(tags$strong(sum(is.na(results$classification))), " need review"),
        class = "stat-chip review-count",
        `aria-label` = paste("Review", sum(is.na(results$classification)), "samples without a single class"))
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
      tags$small(if (!valid) paste0("Must total 100%. Difference: ", format(100 - total, digits = 10),
        " percentage points. Check rounding; values are not normalized.") else if (
        is.null(input$sampleName) || !nzchar(trimws(input$sampleName))
      ) "Enter a sample name to continue" else "Ready to add")
    )
  })

  # Keep the existing dataset intact when validation fails.
  add_samples <- function(read_samples, manual = FALSE) {
    samples <- tryCatch(
      read_samples(),
      error = function(e) {
        manual_error(conditionMessage(e))
        NULL
      }
    )
    if (!is.null(samples)) {
      if (manual && any(vapply(seq_len(nrow(soil_data())), function(i) {
        all(soil_data()[i, ] == samples[1, ])
      }, logical(1)))) {
        sample_feedback("This sample name and composition already exist. Use a different name for a replicate.")
        manual_error("This sample name and composition already exist. Use a different name for a replicate.")
        return(invisible(FALSE))
      }
      description <- if (manual) paste("Added", samples$soil) else
        paste("Imported", nrow(samples), "sample(s)")
      change_samples(rbind(soil_data(), samples), description)
      if (manual) {
        manual_error("")
        updateTextInput(session, "sampleName", value = "")
      }
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

  observeEvent(input$csvFormat, {
    pending_upload(NULL)
    upload_error("")
  }, priority = 10, ignoreInit = TRUE)
  observeEvent(input$fileUpload, {
    req(input$fileUpload)
    pending_upload(NULL)
    upload_error("")
    format <- if (is.null(input$csvFormat)) "samples" else input$csvFormat
    tryCatch({
      raw <- read_upload_table(input$fileUpload$datapath, format)
      pending_upload(list(data = raw, format = format))
    }, error = function(e) upload_error(conditionMessage(e)))
  })
  output$uploadMapping <- renderUI({
    pending <- pending_upload()
    if (is.null(pending) || pending$format == "results") return(NULL)
    defaults <- default_upload_mapping(pending$data)
    tagList(tags$p(class = "field-help", "Map four different columns. Unselected columns will not be imported."),
      lapply(names(defaults), function(column) selectInput(paste0("map_", column), paste("Column for", column),
        choices = c("Choose a column" = "", stats::setNames(names(pending$data), names(pending$data))),
        selected = defaults[[column]], selectize = FALSE)))
  })
  upload_inspection <- reactive({
    pending <- pending_upload()
    if (is.null(pending)) return(NULL)
    defaults <- default_upload_mapping(pending$data)
    mapping <- if (pending$format == "results") stats::setNames(names(defaults), names(defaults)) else
      stats::setNames(vapply(names(defaults), function(column) {
        value <- input[[paste0("map_", column)]]
        if (is.null(value)) defaults[[column]] else value
      }, character(1)), names(defaults))
    tryCatch(inspect_upload(pending$data, mapping), error = function(e) list(error = conditionMessage(e)))
  })
  output$uploadPreview <- renderUI({
    inspected <- upload_inspection()
    if (is.null(inspected)) return(NULL)
    if (!is.null(inspected$error)) return(tags$p(class = "entry-error", role = "alert", inspected$error))
    tagList(tags$h3("Preview before import"),
      tags$p(class = "field-help", paste(nrow(inspected$samples), "rows;", length(unique(inspected$issues$row)), "rows need correction. Preview shows the first 10 rows.")),
      if (length(inspected$ignored)) tags$p(class = "field-help", paste("Excluded columns:", paste(inspected$ignored, collapse = ", "))),
      tags$div(class = "upload-preview-table", build_plain_table(head(inspected$preview, 10))),
      if (nrow(inspected$issues)) tagList(
        tags$p(class = "entry-error", "Fix the source CSV and select it again. Nothing has been imported. Errors below show sample row numbers, excluding the header; first 25 issues shown."),
        tags$div(class = "upload-preview-table", build_plain_table(head(inspected$issues, 25))),
        downloadButton("downloadUploadErrors", "Download all errors", class = "btn-outline-primary")),
      radioButtons("importAction", "Import into workspace", c("Append to current samples" = "append", "Replace all current samples" = "replace"), selected = "append"),
      tags$p(class = "field-help", "Import applies to every row; invalid files are never partially imported. Undo restores the dataset before this import."),
      actionButton("confirmImportBtn", "Import reviewed samples", class = "btn-primary",
                   disabled = nrow(inspected$issues) > 0L))
  })
  output$downloadUploadErrors <- downloadHandler(filename = function() "soil_import_errors.csv",
    content = function(file) { inspected <- upload_inspection(); req(inspected$issues); write.csv(inspected$issues, file, row.names = FALSE) })
  observeEvent(input$confirmImportBtn, {
    pending <- pending_upload()
    inspected <- upload_inspection()
    req(pending, inspected, is.null(inspected$error), nrow(inspected$issues) == 0L)
    samples <- validate_soil_data(inspected$samples)
    replace <- identical(input$importAction, "replace")
    change_samples(if (replace) samples else rbind(soil_data(), samples),
      paste(if (replace) "Replaced dataset with" else "Imported", nrow(samples), "sample(s)"))
    if (pending$format == "results") sample_feedback(paste0(sample_feedback(), "; classifications recalculated using ", input$dataset, "."))
    pending_upload(NULL)
  }, ignoreInit = TRUE)

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

  current_plot <- function(text_scale = 1) {
    build_soil_plot(soil_data(), input$dataset, text_scale = text_scale,
      show_labels = !identical(input$showSampleLabels, FALSE), selected_row = selected_sample(),
      avoid_overlap = !identical(input$avoidLabelOverlap, FALSE))
  }
  output$downloadPlotBtn <- downloadHandler(
    filename = function() paste0("soil_texture_", gsub("[^a-z0-9]+", "_", tolower(input$dataset)), ".png"),
    contentType = "image/png",
    content = function(file) {
      plot <- current_plot() + ggplot2::labs(title = classification_definition(input$dataset)$display,
        caption = "All sample points shown. Labels follow the current chart controls.")
      ggplot2::ggsave(file, plot = plot, device = "png", width = 10, height = 9, units = "in", dpi = 300, bg = "white")
    }
  )
  output$enlargedPlot <- renderPlot({
    req(input$dataset)
    print(current_plot())
  })
  output$ternaryPlot <- renderPlot({
    req(input$dataset)
    width <- session$clientData$output_ternaryPlot_width
    height <- session$clientData$output_ternaryPlot_height
    dimensions <- c(width, height)
    text_scale <- if (length(dimensions) != 2L || any(!is.finite(dimensions))) 1 else
      max(0.65, min(1, width / 750, height / 560))
    print(current_plot(text_scale))
  })

  
}
  
# Run the application
shinyApp(ui = ui, server = server)
