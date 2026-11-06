# Run from the repository root: Rscript --vanilla tests/europe_hypres.R
# Implementation/integration checks only. Package comparison is deferred.
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")
system <- "Europe (HYPRES.TT 1.5.3, 5 classes)"
cases <- read.csv("tests/fixtures/europe_hypres.csv", stringsAsFactors = FALSE)
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status == "classified"),
          length(unique(cases$expected)) == 5L,
          setequal(unique(classification_definition(system)$data$Label), cases$expected),
          nrow(classification_label_key(system)) == 0L)

# Each internal boundary, including the two parts of the coarse/medium step.
boundaries <- data.frame(
  sand = c(20, 30, 10, 15, 65, 70, 15),
  clay = c(60, 35, 35, 20, 10, 18, 35),
  candidates = c("Fine; Very fine", "Fine; Medium", "Fine; Medium fine", "Medium; Medium fine",
                 "Coarse; Medium", "Coarse; Medium", "Fine; Medium; Medium fine"))
details <- classification_details(boundaries, classification_polygons(system))
stopifnot(all(is.na(details$classification)), all(details$classification_status == "boundary"),
          identical(details$classification_candidates, boundaries$candidates))
sides <- data.frame(sand = c(20, 20, 30, 30, 10, 10, 14.999, 15.001, 64.999, 65.001, 70, 70),
                    clay = c(59.999, 60.001, 34.999, 35.001, 34.999, 35.001, 20, 20, 10, 10, 17.999, 18.001))
stopifnot(identical(classify_points(sides, classification_polygons(system)),
                    c("Fine", "Very fine", "Medium", "Fine", "Medium fine", "Fine",
                      "Medium fine", "Medium", "Medium", "Coarse", "Coarse", "Medium")))
corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
stopifnot(identical(classify_points(corners, classification_polygons(system)),
                    c("Coarse", "Very fine", "Medium fine")))
example <- read.csv("examples/europe_hypres_samples.csv")
stopifnot(identical(classify_soil_data(example, system)$classification_status,
                    c("classified", "classified", "classified", "classified", "boundary")))

app_env <- new.env()
source("soil_triangle.R", local = app_env)
shiny::testServer(app_env$server, {
  soil_data(samples)
  session$setInputs(dataset = system)
  exported <- read.csv(output$downloadDataBtn)
  stopifnot(isTRUE(all.equal(exported, classify_soil_data(samples, system), check.attributes = FALSE)),
            all(exported$classification_system == system),
            identical(results_table()$Class, cases$expected),
            grepl("HYPRES", output$classificationReference$html, fixed = TRUE),
            grepl("0.05", output$classificationReference$html, fixed = TRUE),
            !grepl("Class label key", output$classificationReference$html, fixed = TRUE),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("European HYPRES: five classes, all internal boundaries, metadata, examples, and exports PASS\n")
