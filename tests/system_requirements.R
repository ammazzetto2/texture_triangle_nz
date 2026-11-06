source("R/dependencies.R")
ensure_project_dependencies()
app_env <- new.env()
source("soil_triangle.R", local = app_env)

shiny::testServer(app_env$server, {
  session$setInputs(dataset = "New Zealand")
  original <- data.frame(soil = "Unchanged", sand = 50, silt = 25, clay = 25)
  change_samples(original, "Loaded sample")
  for (system in names(app_env$classification_systems)) {
    session$setInputs(dataset = system)
    html <- output$systemRequirements$html
    definition <- app_env$classification_definition(system)
    stopifnot(grepl("does not convert", html, fixed = TRUE),
              identical(soil_data(), original))
    if (is.null(definition$fractions)) {
      stopifnot(grepl("not yet documented", html, fixed = TRUE),
                grepl("Source verification pending", html, fixed = TRUE))
    } else {
      sentence <- strsplit(definition$fractions, ". ", fixed = TRUE)[[1]][1]
      stopifnot(grepl(as.character(htmltools::htmlEscape(sentence)), html, fixed = TRUE),
                !grepl("Source verification pending", html, fixed = TRUE))
    }
    stopifnot(identical(grepl("Known Sand / Sandy Loam overlap", html, fixed = TRUE),
                        identical(system, "Australian")))
  }
  session$setInputs(dataset = "USDA 1911 (Whitney, USDA1911 1.5.3, 8 classes)")
  stopifnot(grepl("0.005", output$systemRequirements$html, fixed = TRUE))
})
cat("System requirements: all definitions, missing metadata, historical fractions, overlap notice, and unchanged measurements PASS\n")
