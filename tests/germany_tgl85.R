# Run from the repository root: Rscript --vanilla tests/germany_tgl85.R
# Implementation/integration checks only. Package comparison is deferred.
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")
system <- "Germany (TGL85 1985, DE.TGL85.TT 1.5.3, 14 classes)"
cases <- read.csv("tests/fixtures/germany_tgl85.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status == "classified"),
          length(unique(cases$expected)) == 14L,
          setequal(unique(classification_definition(system)$data$Label), cases$expected))

# Short plot labels must retain an accessible full-name key, without adding
# one to systems whose text overrides only wrap their original class names.
key <- classification_label_key(system)
stopifnot(nrow(key) == 14L, !anyDuplicated(key$Label),
          setequal(key$Class, cases$expected),
          key$Class[key$Label == "T"] == "T · Ton",
          nrow(classification_label_key("France (GEPPA 1963, 17 classes)")) == 0L,
          nrow(classification_label_key("UK (TIN037 2008, 11 classes)")) == 0L)
# Straight apostrophes distinguish two classes and must survive CSV and UI.
stopifnot(all(c("l''S", "l'S") %in% key$Label),
          cases$expected[2] != cases$expected[3])
boundary <- data.frame(soil = "Clay limit", sand = 25, silt = 25, clay = 50)
result <- classify_soil_data(boundary, system)
stopifnot(is.na(result$classification), result$classification_status == "boundary",
          result$classification_candidates == "lT · Lehmiger Ton; T · Ton")
sides <- data.frame(sand = 25, clay = c(49.999, 50.001))
stopifnot(identical(classify_points(sides, classification_polygons(system)),
                    c("lT · Lehmiger Ton", "T · Ton")))
corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
stopifnot(identical(classify_points(corners, classification_polygons(system)),
                    c("rS · Reiner Sand", "T · Ton", "U · Schluff")))
example <- read.csv("examples/germany_tgl85_samples.csv")
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
            grepl("DE.TGL85.TT", output$classificationReference$html, fixed = TRUE),
            grepl("0.063", output$classificationReference$html, fixed = TRUE),
            grepl("Class label key", output$classificationReference$html, fixed = TRUE),
            all(vapply(key$Class, function(label) grepl(htmltools::htmlEscape(label), output$classificationReference$html, fixed = TRUE), logical(1))),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("Germany TGL85 1985: 14 classes, code key, CSV, boundary, examples, and integration PASS\n")
