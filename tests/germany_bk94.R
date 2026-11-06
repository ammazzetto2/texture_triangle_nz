# Run from the repository root: Rscript --vanilla tests/germany_bk94.R
# Implementation/integration checks only. Package comparison is deferred.
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")
system <- "Germany (BK94 1994, 31 classes)"
cases <- read.csv("tests/fixtures/germany_bk94.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status == "classified"),
          length(unique(cases$expected)) == 31L,
          setequal(unique(classification_definition(system)$data$Label), cases$expected))

# Short plot labels must retain an accessible full-name key, without adding
# one to systems whose text overrides only wrap their original class names.
key <- classification_label_key(system)
stopifnot(nrow(key) == 31L, !anyDuplicated(key$Label),
          setequal(key$Class, cases$expected),
          key$Class[key$Label == "Tt"] == "Tt · Reiner Ton",
          nrow(classification_label_key("France (GEPPA 1963, 17 classes)")) == 0L,
          nrow(classification_label_key("UK (TIN037 2008, 11 classes)")) == 0L)
boundary <- data.frame(soil = "Clay limit", sand = 25, silt = 10, clay = 65)
result <- classify_soil_data(boundary, system)
stopifnot(is.na(result$classification), result$classification_status == "boundary",
          result$classification_candidates == "Ts2 · Schwach sandiger Ton; Tt · Reiner Ton")
sides <- data.frame(sand = c(25.001, 24.999), clay = c(64.999, 65.001))
stopifnot(identical(classify_points(sides, classification_polygons(system)),
                    c("Ts2 · Schwach sandiger Ton", "Tt · Reiner Ton")))
corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
stopifnot(identical(classify_points(corners, classification_polygons(system)),
                    c("Ss · Reiner Sand", "Tt · Reiner Ton", "Uu · Reiner Schluff")))
example <- read.csv("examples/germany_samples.csv")
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
            grepl("BK94", output$classificationReference$html, fixed = TRUE),
            grepl("0.063", output$classificationReference$html, fixed = TRUE),
            grepl("Class label key", output$classificationReference$html, fixed = TRUE),
            all(vapply(key$Class, function(label) grepl(label, output$classificationReference$html, fixed = TRUE), logical(1))),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("Germany BK94: 31 reference interiors, class-label key, boundary, metadata, and exports PASS\n")
