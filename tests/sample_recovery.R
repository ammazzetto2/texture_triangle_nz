# Exercise undo across successful changes, rejected input, and system switches.
source("R/dependencies.R")
ensure_project_dependencies()
app_env <- new.env()
source("soil_triangle.R", local = app_env)

shiny::testServer(app_env$server, {
  session$setInputs(dataset = "New Zealand", undoDataBtn = 0)
  session$setInputs(sampleName = "Sample A", sandValue = 50, siltValue = 25,
                    clayValue = 25, addManualDataBtn = 1)
  first <- soil_data()
  stopifnot(nrow(first) == 1L, output$sampleFeedback == "Added Sample A")
  # A second click arriving before the browser clears the name cannot duplicate it.
  session$setInputs(addManualDataBtn = 2)
  stopifnot(identical(first, soil_data()), grepl("already exist", output$sampleFeedback))
  session$setInputs(undoDataBtn = 1)
  stopifnot(nrow(soil_data()) == 0L, is.null(undo_state()))
  session$setInputs(addManualDataBtn = 3)
  stopifnot(identical(first, soil_data()))

  session$setInputs(fileUpload = list(datapath = normalizePath("examples/soil_samples.csv")))
  session$setInputs(confirmImportBtn = 1)
  stopifnot(nrow(soil_data()) == 4L)
  # Rejected entry must not overwrite the preceding successful operation's undo.
  session$setInputs(sandValue = 49, addManualDataBtn = 4)
  session$setInputs(dataset = "USDA", undoDataBtn = 2)
  stopifnot(identical(first, soil_data()), all(classified_data()$classification_system == "USDA"))

  session$setInputs(clearDataBtn = 1)
  stopifnot(nrow(soil_data()) == 0L)
  session$setInputs(clearDataBtn = 2)
  session$setInputs(undoDataBtn = 3)
  stopifnot(identical(first, soil_data()), is.null(undo_state()))
  session$setInputs(undoDataBtn = 4)
  stopifnot(identical(first, soil_data()))
})
cat("Sample recovery: duplicate clicks, add/import/clear undo, rejected input, and system switching PASS\n")
