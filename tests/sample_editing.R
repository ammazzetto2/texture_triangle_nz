source("R/dependencies.R")
ensure_project_dependencies()
app_env <- new.env()
source("soil_triangle.R", local = app_env)

shiny::testServer(app_env$server, {
  session$setInputs(dataset = "New Zealand", undoDataBtn = 0, saveSampleBtn = 0)
  original <- data.frame(soil = c("Same name", "Same name", "<script>"),
                         sand = c(50, 90, 20), silt = c(25, 5, 20), clay = c(25, 5, 60))
  change_samples(original, "Imported 3 samples")
  session$flushReact()
  html <- output$resultsTable$html
  stopifnot(grepl("Edit sample 3 &lt;script&gt;", html, fixed = TRUE),
            !grepl("<script>", html, fixed = TRUE))
  target <- list(row = 2, revision = data_revision())
  session$setInputs(editSample = target)
  # Opening the editor and submitting invalid input do not change data or undo.
  previous <- undo_state()
  session$setInputs(editSampleName = "Corrected", editSand = 80, editSilt = 5,
                    editClay = 5, saveSampleBtn = 1)
  stopifnot(identical(soil_data(), original), identical(undo_state(), previous),
            grepl("total 100%", edit_error()))
  session$setInputs(editSampleName = "Same name", editSand = 50, editSilt = 25,
                    editClay = 25, saveSampleBtn = 2)
  stopifnot(identical(soil_data(), original), grepl("already exist", edit_error()))
  session$setInputs(editSampleName = "Corrected", editSand = 80, editSilt = 10,
                    editClay = 10, saveSampleBtn = 3)
  edited <- original
  edited[2, ] <- list("Corrected", 80, 10, 10)
  stopifnot(identical(soil_data(), edited), is.null(edit_target()),
            output$sampleFeedback == "Updated Corrected",
            identical(read.csv(output$downloadDataBtn)$soil, edited$soil))
  session$setInputs(undoDataBtn = 1)
  stopifnot(identical(soil_data(), original))

  # A stale row click cannot affect another sample after a table update.
  session$setInputs(deleteSample = target)
  stopifnot(identical(soil_data(), original))
  target <- list(row = 2, revision = data_revision())
  session$setInputs(deleteSample = target)
  stopifnot(identical(soil_data(), original[-2, ]))
  session$setInputs(deleteSample = target)
  stopifnot(identical(soil_data(), original[-2, ]))
  session$setInputs(undoDataBtn = 2)
  stopifnot(identical(soil_data(), original))

  # A no-op save keeps the existing undo; switching systems is safe while editing.
  previous <- undo_state()
  session$setInputs(editSample = list(row = 1, revision = data_revision()), dataset = "USDA")
  session$setInputs(editSampleName = "Same name", editSand = 50, editSilt = 25,
                    editClay = 25, saveSampleBtn = 4)
  stopifnot(identical(soil_data(), original), identical(undo_state(), previous))
  session$setInputs(editSample = list(row = 1, revision = data_revision()))
  session$setInputs(clearDataBtn = 1, saveSampleBtn = 5)
  stopifnot(nrow(soil_data()) == 0L, grepl("dataset changed", edit_error()))
  session$setInputs(undoDataBtn = 3)
  stopifnot(identical(soil_data(), original))
  for (row in c(0, -1, 4, 1.5, NA_real_)) {
    session$setInputs(deleteSample = list(row = row, revision = data_revision()))
    stopifnot(identical(soil_data(), original))
  }
  change_samples(original[1, , drop = FALSE], "Single sample")
  session$setInputs(deleteSample = list(row = 1, revision = data_revision()))
  stopifnot(nrow(soil_data()) == 0L, identical(names(soil_data()), names(original)))
  session$setInputs(undoDataBtn = 4)
  stopifnot(identical(soil_data(), original[1, , drop = FALSE]))
})
cat("Sample editing: validation, duplicates, row identity, stale actions, exports, and undo PASS\n")
