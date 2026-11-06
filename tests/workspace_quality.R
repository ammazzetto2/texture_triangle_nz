source("R/dependencies.R")
ensure_project_dependencies()
app_env <- new.env()
source("soil_triangle.R", local = app_env)

# Dense, coincident samples and long names must remain complete in the table
# and export even when chart labels are suppressed.
shiny::testServer(app_env$server, {
  session$setInputs(dataset = "New Zealand", sampleSearch = "", resultsSort = "input",
    sortDescending = FALSE, resultsPageSize = "25", reviewOnly = FALSE,
    showSampleLabels = FALSE, avoidLabelOverlap = TRUE)
  samples <- data.frame(soil = sprintf("Sample %04d", 1:1000), sand = 50, silt = 25, clay = 25)
  samples$soil[1000] <- paste0("Long <script>name</script> ", strrep("paddock", 50))
  change_samples(samples, "Loaded quality fixture")
  stopifnot(length(visible_result_rows()) == 25L, results_page_count() == 40L,
    nrow(read.csv(output$downloadDataBtn)) == 1000L,
    grepl("1000 sample points", plot_description(), fixed = TRUE))
  session$setInputs(sampleSearch = "<script>")
  stopifnot(identical(visible_result_rows(), 1000L),
    !grepl("<script>", output$resultsTable$html, fixed = TRUE),
    grepl("&lt;script&gt;", output$resultsTable$html, fixed = TRUE))
  session$setInputs(viewSample = list(row = 1000, revision = data_revision()))
  built <- ggtern::ggplot_build(current_plot())
  stopifnot(nrow(built$data[[3]]) == 1000L, nrow(built$data[[4]]) == 0L,
    identical(built$data[[7]]$label, samples$soil[1000]))
})
cat("Workspace quality: 1000 coincident samples, long escaped names, complete export and chart description PASS\n")
