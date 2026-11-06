# Run from the repository root: Rscript --vanilla tests/romania_srts2003.R
# Implementation/integration checks only. Package comparison is deferred.
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")
system <- "Romania (SRTS 2003, ROM.TT 1.5.3, 15 regions)"
cases <- read.csv("tests/fixtures/romania_srts2003.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status == "classified"),
          length(unique(cases$expected)) == 15L,
          setequal(unique(classification_definition(system)$data$Label), cases$expected))

# Short plot labels must retain an accessible full-name key, without adding
# one to systems whose text overrides only wrap their original class names.
key <- classification_label_key(system)
stopifnot(nrow(key) == 15L, !anyDuplicated(key$Label),
          setequal(key$Class, cases$expected),
          key$Class[key$Label == "AF"] == "AF · Argilă fină",
          all(c("SG+SM+SF", "UG+UM+UF", "NG+NM+NF") %in% key$Label),
          nrow(classification_label_key("France (GEPPA 1963, 17 classes)")) == 0L,
          nrow(classification_label_key("UK (TIN037 2008, 11 classes)")) == 0L)
boundary <- data.frame(soil = "Clay limit", sand = 15, silt = 15, clay = 70)
result <- classify_soil_data(boundary, system)
stopifnot(is.na(result$classification), result$classification_status == "boundary",
          result$classification_candidates == "AA · Argilă medie; AF · Argilă fină")
sides <- data.frame(sand = 15, clay = c(69.999, 70.001))
stopifnot(identical(classify_points(sides, classification_polygons(system)),
                    c("AA · Argilă medie", "AF · Argilă fină")))
corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
stopifnot(identical(classify_points(corners, classification_polygons(system)),
                    c("NG+NM+NF · Nisip", "AF · Argilă fină", "SP · Praf")))
example <- read.csv("examples/romania_samples.csv")
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
            grepl("ROM.TT", output$classificationReference$html, fixed = TRUE),
            grepl("0.02", output$classificationReference$html, fixed = TRUE),
            grepl("Class label key", output$classificationReference$html, fixed = TRUE),
            all(vapply(key$Class, function(label) grepl(label, output$classificationReference$html, fixed = TRUE), logical(1))),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("Romania SRTS 2003: 15 regions, grouped sand codes, Romanian key and CSV, boundary, and integration PASS\n")
