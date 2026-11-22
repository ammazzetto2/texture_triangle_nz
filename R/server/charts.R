# Sample highlighting, shared positions, chart dialogs, rendering, and PNG exports.
# Loaded into the current server session by soil_triangle.R.

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
coincident_groups <- reactive(coincident_sample_groups(soil_data()))
output$coincidentControl <- renderUI({
  groups <- coincident_groups()
  if (!nrow(groups)) return(NULL)
  actionButton("coincidentBtn", paste("Shared positions", nrow(groups)), class = "btn-outline-primary")
})
observeEvent(input$coincidentBtn, {
  req(nrow(coincident_groups()))
  showModal(modalDialog(title = "Samples at shared positions",
    tags$p("Count labels show samples with identical sand, silt and clay percentages."),
    uiOutput("coincidentChoices"),
    tags$div(class = "coincident-table", tabindex = "0", role = "region",
      `aria-label` = "Samples at the selected position", uiOutput("coincidentSamples")),
    easyClose = TRUE, footer = modalButton("Close")))
})
output$coincidentChoices <- renderUI({
  groups <- coincident_groups()
  if (!nrow(groups)) return(tags$p("There are no shared positions."))
  labels <- sprintf("Sand %s%%, silt %s%%, clay %s%% (%d samples)",
    groups$sand, groups$silt, groups$clay, groups$count)
  selectInput("coincidentGroup", "Position", width = "100%", choices = stats::setNames(seq_len(nrow(groups)), labels),
    selectize = FALSE)
})
output$coincidentSamples <- renderUI({
  groups <- coincident_groups()
  index <- suppressWarnings(as.integer(input$coincidentGroup))
  req(length(index) == 1L, !is.na(index), index >= 1L, index <= nrow(groups))
  rows <- groups$rows[[index]]
  build_plain_table(data.frame(Row = rows, Sample = soil_data()$soil[rows]))
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
plot_description <- reactive({
  req(input$dataset)
  paste("Soil texture triangle for", classification_definition(input$dataset)$display,
    "with", nrow(soil_data()), "sample points. Axes show sand, silt and clay percentages.",
    "Open the Results tab for sample names, exact percentages, classifications and review status.",
    "The Class key lists region names. Count labels mark identical compositions. Use Shared positions to inspect their sample names. Nearby points and labels may overlap.")
})
output$enlargedPlot <- renderPlot({
  req(input$dataset)
  print(current_plot())
}, alt = plot_description)
output$ternaryPlot <- renderPlot({
  req(input$dataset)
  width <- session$clientData$output_ternaryPlot_width
  height <- session$clientData$output_ternaryPlot_height
  dimensions <- c(width, height)
  text_scale <- if (length(dimensions) != 2L || any(!is.finite(dimensions))) 1 else
    max(0.65, min(1, width / 750, height / 560))
  print(current_plot(text_scale))
}, alt = plot_description)
