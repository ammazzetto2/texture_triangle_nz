# CSV mapping, validation previews, duplicate choices, and import downloads.
# Loaded into the current server session by soil_triangle.R.

pending_upload <- reactiveVal(NULL)
upload_error <- reactiveVal("")
output$uploadError <- renderText(upload_error())

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
  tagList(tags$p(class = "field-help", "Choose one column each for sample name, sand, silt and clay. Percentages must total 100. Rounded totals are used as supplied."),
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
upload_duplicates <- reactive({
  inspected <- upload_inspection()
  req(inspected, is.null(inspected$error))
  samples <- inspected$samples
  existing <- if (identical(input$importAction, "replace")) soil_data()[FALSE, ] else soil_data()
  tail(duplicated(rbind(existing, samples)), nrow(samples))
})
output$uploadDuplicateSummary <- renderText({
  inspected <- upload_inspection()
  req(inspected, is.null(inspected$error))
  count <- sum(upload_duplicates())
  kept <- if (identical(input$duplicateAction, "keep")) nrow(inspected$samples) else nrow(inspected$samples) - count
  sprintf("%d duplicate row(s). %d row(s) selected for import. Duplicates have the same name and all three percentages. Append also checks existing samples.", count, kept)
})
output$uploadStatus <- renderText({
  inspected <- upload_inspection()
  if (is.null(inspected)) return("")
  if (!is.null(inspected$error)) return(inspected$error)
  total <- nrow(inspected$samples)
  invalid <- length(unique(inspected$issues$row))
  if (invalid) {
    sprintf("Rows needing correction: %d of %d. Check the column mapping or update the CSV.", invalid, total)
  } else {
    sprintf("%d %s ready to import.", total, if (total == 1L) "row is" else "rows are")
  }
})
output$uploadPreview <- renderUI({
  inspected <- upload_inspection()
  if (is.null(inspected) || !is.null(inspected$error)) return(NULL)
  tagList(tags$h3("Preview before import"),
    tags$p(class = "field-help", "Preview shows up to 10 rows. Changing CSV contents clears the preview and requires selecting the file again."),
    if (length(inspected$ignored)) tags$p(class = "field-help", paste("Excluded columns:", paste(inspected$ignored, collapse = ", "))),
    tags$div(class = "upload-preview-table", tabindex = "0", role = "region", `aria-label` = "CSV preview; scroll for more columns", build_plain_table(head(inspected$preview, 10))),
    if (nrow(inspected$issues)) tagList(
      tags$p(class = "entry-error", "Errors use sample row numbers, excluding the header. Up to 25 issues are shown."),
      tags$div(class = "upload-preview-table", tabindex = "0", role = "region", `aria-label` = "CSV validation errors; scroll for more rows and columns", build_plain_table(head(inspected$issues, 25))),
      downloadButton("downloadUploadErrors", "Download all errors", class = "btn-outline-primary")),
    radioButtons("importAction", "Import into workspace", c("Append to current samples" = "append", "Replace all current samples" = "replace"), selected = "append"),
    tags$p(class = "field-help", "Append keeps existing samples and adds the CSV rows. Replace uses the CSV as the entire workspace. All rows must pass validation. Undo restores the previous samples."),
    radioButtons("duplicateAction", "Duplicate rows",
      c("Skip duplicates" = "skip", "Keep duplicates" = "keep"), selected = "skip"),
    tags$p(class = "field-help", role = "status", textOutput("uploadDuplicateSummary", inline = TRUE)),
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
  skipped <- 0L
  if (!identical(input$duplicateAction, "keep")) {
    duplicates <- upload_duplicates()
    skipped <- sum(duplicates)
    samples <- samples[!duplicates, , drop = FALSE]
  }
  if (!replace && !nrow(samples)) {
    sample_feedback(paste("Skipped", skipped, "duplicate row(s). No samples added."))
    pending_upload(NULL)
    return()
  }
  change_samples(if (replace) samples else rbind(soil_data(), samples),
    paste(if (replace) "Replaced dataset with" else "Imported", nrow(samples), "sample(s)"))
  if (skipped) sample_feedback(paste0(sample_feedback(), "; skipped ", skipped, " duplicate row(s)."))
  if (pending$format == "results") sample_feedback(paste0(sample_feedback(), "; classifications recalculated using ", input$dataset, "."))
  pending_upload(NULL)
}, ignoreInit = TRUE)


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
