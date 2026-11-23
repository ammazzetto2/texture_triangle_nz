source("R/dependencies.R")
ensure_project_dependencies()
app_env <- new.env()
source("soil_triangle.R", local = app_env)

samples <- data.frame(soil = c("001", "NA", "Łąka\nnorth", "001"),
  sand = c(50, 90, 33.3, 50), silt = c(25, 5, 33.3, 25), clay = c(25, 5, 33.4, 25))
path <- tempfile(fileext = ".json")
settings <- app_env$workspace_settings("USDA", FALSE, FALSE, 3L)
app_env$write_workspace(path, samples, settings)
saved <- app_env$read_workspace(path)
stopifnot(isTRUE(all.equal(saved$samples, samples)), identical(saved$settings, settings))
valid <- jsonlite::fromJSON(path, simplifyVector = FALSE)
expect_bad <- function(data) {
  jsonlite::write_json(data, path, auto_unbox = TRUE, null = "null", digits = NA)
  error <- tryCatch({ app_env$read_workspace(path); NULL }, error = conditionMessage)
  stopifnot(is.character(error), nzchar(error))
}
bad <- valid
bad$version <- 2
expect_bad(bad)
bad <- valid
bad$classification_system <- "Unknown system"
expect_bad(bad)
bad <- valid
bad$samples[[1]]$sand <- "50"
expect_bad(bad)
bad <- valid
bad$samples[[1]]$sand <- 49
expect_bad(bad)
bad <- valid
bad$chart$show_labels <- 1
expect_bad(bad)
bad <- valid
bad$chart$selected_row <- 5
expect_bad(bad)
bad$chart$selected_row <- 1.5
expect_bad(bad)
bad <- valid
bad$samples[[1]]$soil <- NULL
expect_bad(bad)
writeLines("{broken", path)
stopifnot(inherits(tryCatch(app_env$read_workspace(path), error = identity), "error"))
app_env$write_workspace(path, samples[FALSE, ], app_env$workspace_settings("New Zealand", TRUE, TRUE))
stopifnot(nrow(app_env$read_workspace(path)$samples) == 0L)

# Download through the server, then restore into another session.
shiny::testServer(app_env$server, {
  session$setInputs(dataset = "USDA", showSampleLabels = FALSE, avoidLabelOverlap = FALSE)
  change_samples(samples, "Loaded")
  selected_sample(3L)
  session$flushReact()
  file.copy(output$downloadWorkspace, path, overwrite = TRUE)
})
shiny::testServer(app_env$server, {
  session$setInputs(dataset = "New Zealand", showSampleLabels = TRUE, avoidLabelOverlap = TRUE,
    restoreWorkspace = 0, undoDataBtn = 0)
  original <- samples[1, ]
  change_samples(original, "Original")
  selected_sample(1L)
  previous_revision <- data_revision()
  messages <- list()
  session$sendInputMessage <- function(inputId, message) {
    messages[[inputId]] <<- message
  }
  session$setInputs(workspaceUpload = list(datapath = path))
  stopifnot(identical(soil_data(), original), grepl("4 sample(s)", output$workspacePreview$html, fixed = TRUE))
  session$setInputs(restoreWorkspace = 1)
  stopifnot(isTRUE(all.equal(soil_data(), samples)), selected_sample() == 3L,
    data_revision() == previous_revision + 1L,
    messages$dataset$value == "USDA", identical(messages$showSampleLabels$value, FALSE),
    identical(messages$avoidLabelOverlap$value, FALSE), is.null(pending_workspace()))
  # Mock sessions do not apply the browser's input updates automatically.
  session$setInputs(dataset = "USDA", showSampleLabels = FALSE, avoidLabelOverlap = FALSE)
  before <- undo_state()
  writeLines("{broken", path)
  session$setInputs(workspaceUpload = list(datapath = path))
  session$setInputs(restoreWorkspace = 2)
  stopifnot(isTRUE(all.equal(soil_data(), samples)), identical(undo_state(), before),
    nzchar(workspace_error()))
  session$setInputs(undoDataBtn = 1)
  stopifnot(identical(soil_data(), original), selected_sample() == 1L,
    messages$dataset$value == "New Zealand", identical(messages$showSampleLabels$value, TRUE),
    identical(messages$avoidLabelOverlap$value, TRUE))
})
unlink(path)
cat("Workspace files: typed validation, empty data, duplicates, text names, fresh-session restore and full undo PASS\n")
