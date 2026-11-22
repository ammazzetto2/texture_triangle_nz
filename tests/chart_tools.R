source("R/dependencies.R")
ensure_project_dependencies()
app_env <- new.env()
source("soil_triangle.R", local = app_env)
samples <- data.frame(soil = c("Same", "Same", "Boundary"), sand = c(50, 90, 20),
                      silt = c(25, 5, 20), clay = c(25, 5, 60))
shiny::testServer(app_env$server, {
  session$setInputs(dataset = "New Zealand", showSampleLabels = FALSE,
                    avoidLabelOverlap = TRUE, clearPlotSelection = 0, undoDataBtn = 0)
  change_samples(samples, "Loaded samples")
  target <- list(row = 2, revision = data_revision())
  session$setInputs(viewSample = target)
  stopifnot(selected_sample() == 2L, grepl("sand 90%", output$plotSelection$html, fixed = TRUE))
  built <- ggtern::ggplot_build(current_plot())
  stopifnot(nrow(built$data[[3]]) == 3L, nrow(built$data[[4]]) == 0L,
            nrow(built$data[[6]]) == 1L, built$data[[7]]$label == "Same",
            built$data[[6]]$x == 0.9)
  session$setInputs(showSampleLabels = TRUE)
  stopifnot(nrow(ggtern::ggplot_build(current_plot())$data[[4]]) == 2L,
            isTRUE(current_plot()$layers[[4]]$geom_params$check_overlap))
  session$setInputs(avoidLabelOverlap = FALSE)
  stopifnot(identical(current_plot()$layers[[4]]$geom_params$check_overlap, FALSE))
  session$setInputs(dataset = "USDA")
  stopifnot(selected_sample() == 2L, !is.null(output$enlargedPlot))
  png <- output$downloadPlotBtn
  signature <- readBin(png, "raw", n = 8)
  stopifnot(identical(signature, as.raw(c(137,80,78,71,13,10,26,10))), file.info(png)$size > 10000)
  session$setInputs(clearPlotSelection = 1)
  stopifnot(is.null(selected_sample()))
  session$setInputs(viewSample = target)
  session$setInputs(deleteSample = list(row = 1, revision = data_revision()))
  stopifnot(is.null(selected_sample()))
  session$setInputs(viewSample = target)
  stopifnot(is.null(selected_sample()))
  session$setInputs(undoDataBtn = 1, reviewOnly = TRUE)
  session$setInputs(dataset = "New Zealand")
  stopifnot(grepl("View sample 3 Boundary", output$resultsTable$html, fixed = TRUE))
  session$setInputs(viewSample = list(row = 3, revision = data_revision()))
  stopifnot(selected_sample() == 3L)
  session$setInputs(clearDataBtn = 1)
  stopifnot(is.null(selected_sample()), !is.null(output$ternaryPlot))
})
cat("Chart tools: row identity, highlighting, labels, PNG export, enlarged plot, stale clicks and undo PASS\n")

shared <- data.frame(soil = c("First", "<Second>", "Other", "First"),
  sand = c(50, 50, 90, 50), silt = c(25, 25, 5, 25), clay = c(25, 25, 5, 25))
groups <- app_env$coincident_sample_groups(shared)
stopifnot(nrow(groups) == 1L, groups$count == 3L, identical(groups$rows[[1]], c(1L, 2L, 4L)))
for (labels in c(TRUE, FALSE)) {
  plot <- app_env$build_soil_plot(shared, "New Zealand", show_labels = labels, selected_row = 2)
  built <- ggtern::ggplot_build(plot)
  stopifnot(nrow(built$data[[3]]) == 4L, built$data[[8]]$label == "3 samples",
    built$data[[8]]$x == 0.5, built$data[[8]]$y == 0.25,
    built$data[[7]]$label == "<Second>")
  ggtern::ggplotGrob(plot)
}
nearby <- shared[1:2, ]
nearby$sand[2] <- nearby$sand[2] + 1e-6
nearby$silt[2] <- nearby$silt[2] - 1e-6
stopifnot(nrow(app_env$coincident_sample_groups(nearby)) == 0L)
shiny::testServer(app_env$server, {
  session$setInputs(dataset = "New Zealand", coincidentGroup = "1", undoDataBtn = 0)
  change_samples(shared, "Shared samples")
  session$flushReact()
  stopifnot(grepl("Shared positions 1", output$coincidentControl$html, fixed = TRUE),
    grepl("&lt;Second&gt;", output$coincidentSamples$html, fixed = TRUE))
  session$setInputs(deleteSample = list(row = 2, revision = data_revision()))
  stopifnot(coincident_groups()$count == 2L)
  session$setInputs(undoDataBtn = 1)
  stopifnot(coincident_groups()$count == 3L)
  session$setInputs(clearDataBtn = 1)
  stopifnot(is.null(output$coincidentControl), nrow(coincident_groups()) == 0L)
})
cat("Shared positions: exact counts, unchanged coordinates, hidden labels, escaped names, delete and undo PASS\n")
