# Classification context, Results filters and pagination, and CSV exports.
# Loaded into the current server session by soil_triangle.R.

review_only <- reactiveVal(FALSE)
results_page <- reactiveVal(1L)

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
show_all_results <- function() {
  review_only(FALSE)
  updateTextInput(session, "sampleSearch", value = "")
  updateCheckboxInput(session, "reviewOnly", value = FALSE)
  updateTabsetPanel(session, "workspaceView", selected = "results")
}
observeEvent(input$allSamplesBtn, {
  req(input$allSamplesBtn > 0)
  show_all_results()
})
observeEvent(input$showAllSamplesBtn, {
  req(input$showAllSamplesBtn > 0)
  show_all_results()
})
output$reviewFilterControl <- renderUI({
  if (!review_only()) return(NULL)
  tagList(
    tags$p(role = "status", "Showing only samples needing review."),
    actionButton("showAllSamplesBtn", "Show all samples", class = "btn-outline-primary"))
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


output$workspaceStats <- renderUI({
  results <- classified_data()
  tagList(
    actionButton("allSamplesBtn",
      tagList(tags$strong(nrow(results)), if (nrow(results) == 1L) " sample" else " samples"),
      class = "stat-chip review-count", `aria-label` = paste("Show all", nrow(results), "samples")),
    actionButton("reviewSamplesBtn",
      tagList(tags$strong(sum(is.na(results$classification))), " need review"),
      class = "stat-chip review-count",
      `aria-label` = paste("Review", sum(is.na(results$classification)), "samples without a single class"))
  )
})


output$downloadDataBtn <- downloadHandler(
  filename = function() "soil_texture_results.csv",
  content = function(file) {
    write.csv(classified_data(), file, row.names = FALSE)
  }
)
