# Run from the repository root: Rscript --vanilla tests/germany_sea74.R
# Implementation/integration checks only. Package comparison is deferred.
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")
system <- "Germany (SEA74 1974, DE.SEA74.TT 1.5.3, 13 classes)"
cases <- read.csv("tests/fixtures/germany_sea74.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status == "classified"),
          length(unique(cases$expected)) == 13L,
          setequal(unique(classification_definition(system)$data$Label), cases$expected))

# Short plot labels must retain an accessible full-name key, without adding
# one to systems whose text overrides only wrap their original class names.
key <- classification_label_key(system)
stopifnot(nrow(key) == 13L, !anyDuplicated(key$Label),
          setequal(key$Class, cases$expected),
          key$Class[key$Label == "T"] == "T · Ton",
          nrow(classification_label_key("France (GEPPA 1963, 17 classes)")) == 0L,
          nrow(classification_label_key("UK (TIN037 2008, 11 classes)")) == 0L)
boundary <- data.frame(soil = "Clay limit", sand = 30, silt = 25, clay = 45)
result <- classify_soil_data(boundary, system)
stopifnot(is.na(result$classification), result$classification_status == "boundary",
          result$classification_candidates == "lT · Lehmiger Ton; T · Ton")
sides <- data.frame(sand = 30, clay = c(44.999, 45.001))
stopifnot(identical(classify_points(sides, classification_polygons(system)),
                    c("lT · Lehmiger Ton", "T · Ton")))
corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
stopifnot(identical(classify_points(corners, classification_polygons(system)),
                    c("S · Sand", "T · Ton", "U · Schluff")))
example <- read.csv("examples/germany_sea74_samples.csv")
stopifnot(identical(classify_soil_data(example, system)$classification_status,
                    c("classified", "classified", "classified", "boundary")))

# The historical schemes must remain distinct at a composition between their
# upper clay limits: 47% clay is Ton in SEA74 and lehmiger Ton in TGL85.
probe <- data.frame(soil = "Historical distinction", sand = 25, silt = 28, clay = 47)
stopifnot(classify_soil_data(probe, system)$classification == "T · Ton",
          classify_soil_data(probe, "Germany (TGL85 1985, DE.TGL85.TT 1.5.3, 14 classes)")$classification == "lT · Lehmiger Ton")

app_env <- new.env()
source("soil_triangle.R", local = app_env)
shiny::testServer(app_env$server, {
  soil_data(samples)
  session$setInputs(dataset = system)
  exported <- read.csv(output$downloadDataBtn)
  stopifnot(isTRUE(all.equal(exported, classify_soil_data(samples, system), check.attributes = FALSE)),
            all(exported$classification_system == system),
            identical(results_table()$Class, cases$expected),
            grepl("DE.SEA74.TT", output$classificationReference$html, fixed = TRUE),
            grepl("0.063", output$classificationReference$html, fixed = TRUE),
            grepl("Class label key", output$classificationReference$html, fixed = TRUE),
            all(vapply(key$Class, function(label) grepl(htmltools::htmlEscape(label), output$classificationReference$html, fixed = TRUE), logical(1))),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("Germany SEA74 1974: 13 classes, code key, CSV, boundary, examples, and integration PASS\n")
