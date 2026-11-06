# Run from the repository root: Rscript --vanilla tests/belgium.R
# Implementation/integration checks only. Package comparison is deferred.
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")
system <- "Belgium (BE.TT 1.5.3, 7 classes)"
cases <- read.csv("tests/fixtures/belgium.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status == "classified"),
          length(unique(cases$expected)) == 7L,
          setequal(unique(classification_definition(system)$data$Label), cases$expected))

# Short plot labels must retain an accessible full-name key, without adding
# one to systems whose text overrides only wrap their original class names.
key <- classification_label_key(system)
stopifnot(nrow(key) == 7L, !anyDuplicated(key$Label),
          setequal(key$Class, cases$expected),
          key$Class[key$Label == "P"] == "P · Limon sableux léger / Licht zandleem",
          nrow(classification_label_key("France (GEPPA 1963, 17 classes)")) == 0L,
          nrow(classification_label_key("UK (TIN037 2008, 11 classes)")) == 0L)
boundary <- data.frame(soil = "Sand limit", sand = 50, silt = 45, clay = 5)
result <- classify_soil_data(boundary, system)
stopifnot(is.na(result$classification), result$classification_status == "boundary",
          result$classification_candidates == "L · Limon sableux / Zandleem; P · Limon sableux léger / Licht zandleem")
sides <- data.frame(sand = c(50.001, 49.999), clay = 5)
stopifnot(identical(classify_points(sides, classification_polygons(system)),
                    c("P · Limon sableux léger / Licht zandleem", "L · Limon sableux / Zandleem")))
corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
stopifnot(identical(classify_points(corners, classification_polygons(system)),
                    c("Z · Sable / Zand", "U · Argile lourde / Zware klei", "A · Limon / Leem")))
example <- read.csv("examples/belgium_samples.csv")
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
            grepl("BE.TT", output$classificationReference$html, fixed = TRUE),
            grepl("0.05", output$classificationReference$html, fixed = TRUE),
            grepl("Class label key", output$classificationReference$html, fixed = TRUE),
            all(vapply(key$Class, function(label) grepl(label, output$classificationReference$html, fixed = TRUE), logical(1))),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("Belgium: seven reference interiors, bilingual key and CSV, published example, boundary, and integration PASS\n")
