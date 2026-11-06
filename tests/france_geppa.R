# Run from the repository root: Rscript --vanilla tests/france_geppa.R
# Implementation/integration checks only. Package comparison is deferred.
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")
system <- "France (GEPPA 1963, 17 classes)"
cases <- read.csv("tests/fixtures/france_geppa.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status == "classified"),
          length(unique(cases$expected)) == 17L,
          setequal(unique(classification_definition(system)$data$Label), cases$expected))

# Codes As and AS must remain distinct rather than case-folding identity.
stopifnot(result$classification[3] != result$classification[6])
boundary <- data.frame(soil = "Silt limit", sand = 60, silt = 25, clay = 15)
result <- classify_soil_data(boundary, system)
stopifnot(is.na(result$classification), result$classification_status == "boundary",
          result$classification_candidates == "Sa · Sable argileux; Sal · Sable argilo-limoneux")
sides <- data.frame(sand = c(60.001, 59.999), clay = 15)
stopifnot(identical(classify_points(sides, classification_polygons(system)),
                    c("Sa · Sable argileux", "Sal · Sable argilo-limoneux")))
corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
stopifnot(identical(classify_points(corners, classification_polygons(system)),
                    c("SS · Sable", "AA · Argile lourde", "LL · Limon pur")))
example <- read.csv("examples/france_samples.csv")
stopifnot(identical(classify_soil_data(example, system)$classification_status,
                    c("classified", "classified", "classified", "boundary")))

app_env <- new.env()
source("soil_triangle.R", local = app_env)
shiny::testServer(app_env$server, {
  soil_data(samples)
  session$setInputs(dataset = system)
  exported <- read.csv(output$downloadDataBtn)
  stopifnot(isTRUE(all.equal(exported, classify_soil_data(samples, system), check.attributes = FALSE)),
            all(exported$classification_system == system),
            identical(results_table()$Class, cases$expected),
            grepl("GEPPA", output$classificationReference$html, fixed = TRUE),
            grepl("0.05", output$classificationReference$html, fixed = TRUE),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("France GEPPA: 17 reference interiors, boundary, case-sensitive codes, metadata, and exports PASS\n")
