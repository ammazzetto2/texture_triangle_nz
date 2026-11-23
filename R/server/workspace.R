# Workspace downloads and staged restoration within the current session.
pending_workspace <- reactiveVal(NULL)
workspace_error <- reactiveVal("")

current_workspace_settings <- function() {
  workspace_settings(input$dataset, !identical(input$showSampleLabels, FALSE),
    !identical(input$avoidLabelOverlap, FALSE), selected_sample())
}

apply_workspace_settings <- function(settings) {
  freezeReactiveValue(input, "dataset")
  updateSelectInput(session, "dataset", selected = settings$classification_system)
  updateCheckboxInput(session, "showSampleLabels", value = settings$chart$show_labels)
  updateCheckboxInput(session, "avoidLabelOverlap", value = settings$chart$avoid_overlap)
  selected_sample(settings$chart$selected_row)
}

observeEvent(input$workspaceBtn, {
  pending_workspace(NULL)
  workspace_error("")
  showModal(modalDialog(title = "Save or restore workspace",
    tags$p("Save samples, the classification system, label settings and highlighted sample."),
    downloadButton("downloadWorkspace", "Save workspace", class = "btn-primary"),
    fileInput("workspaceUpload", "Choose a workspace JSON file", accept = ".json", width = "100%"),
    tags$p(class = "entry-error", role = "alert", textOutput("workspaceError", inline = TRUE)),
    uiOutput("workspacePreview"),
    easyClose = TRUE, footer = modalButton("Close")))
})
output$workspaceError <- renderText(workspace_error())
output$downloadWorkspace <- downloadHandler(
  filename = function() "soil_texture_workspace.json",
  contentType = "application/json",
  content = function(file) write_workspace(file, soil_data(), current_workspace_settings())
)
observeEvent(input$workspaceUpload, {
  req(input$workspaceUpload)
  pending_workspace(NULL)
  workspace_error("")
  tryCatch(
    pending_workspace(read_workspace(input$workspaceUpload$datapath)),
    error = function(e) workspace_error(conditionMessage(e))
  )
})
output$workspacePreview <- renderUI({
  saved <- pending_workspace()
  if (is.null(saved)) return(NULL)
  tagList(
    tags$p(paste(nrow(saved$samples), "sample(s) using",
      classification_definition(saved$settings$classification_system)$display)),
    tags$p("Restore replaces the current samples and chart settings. Undo restores the previous samples, system and chart settings."),
    actionButton("restoreWorkspace", "Restore workspace", class = "btn-primary"))
})
observeEvent(input$restoreWorkspace, {
  saved <- pending_workspace()
  req(saved)
  previous_settings <- current_workspace_settings()
  change_samples(saved$samples, "Restored workspace")
  previous <- undo_state()
  previous$workspace <- previous_settings
  undo_state(previous)
  apply_workspace_settings(saved$settings)
  pending_upload(NULL)
  upload_error("")
  manual_error("")
  edit_target(NULL)
  edit_error("")
  review_only(FALSE)
  results_page(1L)
  updateCheckboxInput(session, "reviewOnly", value = FALSE)
  updateTextInput(session, "sampleSearch", value = "")
  updateTabsetPanel(session, "workspaceView", selected = "triangle")
  pending_workspace(NULL)
  removeModal()
}, ignoreInit = TRUE)
