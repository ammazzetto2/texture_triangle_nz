# Manual entry, sample editing, deletion, and single-step undo.
# Loaded into the current server session by soil_triangle.R.

edit_target <- reactiveVal(NULL)
edit_error <- reactiveVal("")
manual_error <- reactiveVal("")

output$manualError <- renderText(manual_error())

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
  if (!is.null(previous$workspace)) apply_workspace_settings(previous$workspace)
  undo_state(NULL)
  sample_feedback(paste("Undone:", previous$description))
}, ignoreInit = TRUE)


output$editSampleError <- renderText(edit_error())

observeEvent(input$editSample, {
  row <- current_row(input$editSample)
  req(row)
  sample <- soil_data()[row, ]
  edit_target(input$editSample)
  edit_error("")
  showModal(modalDialog(
    title = tags$span(id = "edit-sample-title", `data-row` = row, "Edit sample"), easyClose = FALSE,
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


observeEvent(input$clearDataBtn, {
  if (!nrow(soil_data())) return()
  change_samples(soil_data()[FALSE, ], "Cleared all samples")
})
