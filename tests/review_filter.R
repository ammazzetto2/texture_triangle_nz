source("R/dependencies.R")
ensure_project_dependencies()
app_env <- new.env()
source("soil_triangle.R", local = app_env)

shiny::testServer(app_env$server, {
  session$setInputs(dataset = "New Zealand", reviewSamplesBtn = 0,
                    reviewOnly = FALSE, undoDataBtn = 0, saveSampleBtn = 0,
                    allSamplesBtn = 0, showAllSamplesBtn = 0)
  samples <- data.frame(soil = c("Interior", "Shared boundary", "Outer corner"),
                        sand = c(90, 20, 0), silt = c(5, 20, 0), clay = c(5, 60, 100))
  change_samples(samples, "Loaded samples")
  session$flushReact()
  stopifnot(identical(visible_result_rows(), 1:3),
            grepl("Boundary (assigned)", output$resultsTable$html, fixed = TRUE))
  session$setInputs(reviewSamplesBtn = 1)
  stopifnot(review_only(), identical(visible_result_rows(), 2L),
            grepl('data-row="2"', output$resultsTable$html, fixed = TRUE),
            !grepl('data-row="1"', output$resultsTable$html, fixed = TRUE),
            grepl("Showing 1 of 3", output$resultsFilterSummary, fixed = TRUE),
            nrow(read.csv(output$downloadDataBtn)) == 3L)
  stopifnot(grepl("Show all samples", output$reviewFilterControl$html, fixed = TRUE))
  session$setInputs(reviewOnly = TRUE, showAllSamplesBtn = 1)
  stopifnot(!review_only(), identical(visible_result_rows(), 1:3),
            is.null(output$reviewFilterControl))
  # The toolbar shortcut also exits review after returning to the Triangle tab.
  session$setInputs(reviewOnly = FALSE, reviewSamplesBtn = 2)
  session$setInputs(reviewOnly = TRUE, workspaceView = "triangle", allSamplesBtn = 1)
  stopifnot(!review_only(), identical(visible_result_rows(), 1:3))
  session$setInputs(reviewOnly = FALSE, reviewSamplesBtn = 3)
  # Filtered row actions retain the underlying dataset index.
  session$setInputs(editSample = list(row = 2, revision = data_revision()))
  session$setInputs(editSampleName = "Corrected", editSand = 50, editSilt = 25,
                    editClay = 25, saveSampleBtn = 1)
  stopifnot(soil_data()$soil[2] == "Corrected", length(visible_result_rows()) == 0L,
            grepl("No samples need review", output$resultsTable$html, fixed = TRUE))
  session$setInputs(showAllSamplesBtn = 2)
  stopifnot(identical(visible_result_rows(), 1:3))
  session$setInputs(reviewSamplesBtn = 4)
  session$setInputs(undoDataBtn = 1)
  stopifnot(identical(soil_data(), samples), identical(visible_result_rows(), 2L))
  session$setInputs(deleteSample = list(row = 2, revision = data_revision()))
  stopifnot(identical(soil_data()$soil, c("Interior", "Outer corner")),
            length(visible_result_rows()) == 0L)
  session$setInputs(undoDataBtn = 2, reviewOnly = FALSE)
  stopifnot(identical(visible_result_rows(), 1:3))
  session$setInputs(reviewOnly = TRUE)
  session$setInputs(dataset = "Australian")
  change_samples(data.frame(soil = "Overlap", sand = 90.5, silt = 1.3, clay = 8.2), "Overlap")
  session$flushReact()
  stopifnot(identical(visible_result_rows(), 1L),
            grepl("inside overlapping", output$resultsTable$html, fixed = TRUE))
  session$setInputs(dataset = "USDA")
  stopifnot(length(visible_result_rows()) == 0L)
  session$setInputs(clearDataBtn = 1)
  stopifnot(grepl("Your samples will appear here", output$resultsTable$html, fixed = TRUE),
            grepl("Showing 0 of 0", output$resultsFilterSummary, fixed = TRUE))
})

# Unclassified explanation is reachable even though the current grids have coverage.
example <- data.frame(Sample = "Unmatched", Class = "—", Status = "unclassified")
html <- as.character(app_env$build_results_table(example))
stopifnot(grepl("No class region matches", html, fixed = TRUE))
cat("Review filtering: assigned boundaries, row identity, edits, deletes, undo, exports, and system switches PASS\n")
