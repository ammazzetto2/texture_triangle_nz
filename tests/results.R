# Run from the repository root: Rscript --vanilla tests/results.R
source("R/dependencies.R")
ensure_project_dependencies()
app_env <- new.env()
source("soil_triangle.R", local = app_env)

shiny::testServer(app_env$server, {
  session$setInputs(dataset = "New Zealand", dataset_upload = "New Zealand")
  stopifnot(grepl("No samples yet", output$resultsSummary, fixed = TRUE),
            nrow(results_table()) == 0L)
  soil_data(data.frame(soil = c("<script>alert(1)</script>", "Boundary"),
                       sand = c(90, 20), silt = c(5, 20), clay = c(5, 60)))
  session$flushReact()
  stopifnot(grepl("2 sample(s), 1 without a single class", output$resultsSummary, fixed = TRUE),
            results_table()$Class[2] == "—",
            results_table()$Status[2] == "boundary",
            results_table()$`Candidate classes`[2] == "Clay; Loamy Clay")
  html <- output$resultsTable
  stopifnot(grepl("&lt;script&gt;", html, fixed = TRUE),
            !grepl("<script>", html, fixed = TRUE))
  for (system in c("New Zealand", "USDA", "Australian")) {
    session$setInputs(dataset = system, dataset_upload = system)
    exported <- read.csv(output$downloadDataBtn_manual)
    stopifnot(identical(exported, read.csv(output$downloadDataBtn_upload)),
              identical(exported$classification_status, results_table()$Status),
              all(exported$classification_system == system),
              grepl(system, output$resultsSummary, fixed = TRUE))
  }
  soil_data(data.frame(soil = "Overlap", sand = 90.5, silt = 1.3, clay = 8.2))
  session$flushReact()
  stopifnot(results_table()$Status == "overlap",
            results_table()$`Candidate classes` == "Sand; Sandy Loam")
  template <- read.csv(output$downloadTemplateBtn)
  stopifnot(identical(names(template), c("soil", "sand", "silt", "clay")), nrow(template) == 0L)
  session$setInputs(clearDataBtn_upload = 1)
  stopifnot(nrow(results_table()) == 0L,
            grepl("No samples yet", output$resultsSummary, fixed = TRUE))
})
cat("Results and template integration checks: PASS\n")
