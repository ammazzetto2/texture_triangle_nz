# Run from the repository root: Rscript --vanilla tests/poland_ptg2008.R
# Implementation/integration checks only. Package comparison is deferred.
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")
system <- "Poland (PTG 2008, PTG_2008.TT 1.5.3, 16 classes)"
cases <- read.csv("tests/fixtures/poland_ptg2008.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status == "classified"),
          length(unique(cases$expected)) == 16L,
          setequal(unique(classification_definition(system)$data$Label), cases$expected))

# Short plot labels must retain an accessible full-name key, without adding
# one to systems whose text overrides only wrap their original class names.
key <- classification_label_key(system)
stopifnot(nrow(key) == 16L, !anyDuplicated(key$Label),
          setequal(key$Class, cases$expected),
          key$Class[key$Label == "pl"] == "pl · Piasek luźny",
          nrow(classification_label_key("France (GEPPA 1963, 17 classes)")) == 0L,
          nrow(classification_label_key("UK (TIN037 2008, 11 classes)")) == 0L)
boundary <- data.frame(soil = "Clay limit", sand = 20, silt = 20, clay = 60)
result <- classify_soil_data(boundary, system)
stopifnot(is.na(result$classification), result$classification_status == "boundary",
          result$classification_candidates == "ic · Ił ciężki; iz · Ił zwykły")
sides <- data.frame(sand = 20, clay = c(59.999, 60.001))
stopifnot(identical(classify_points(sides, classification_polygons(system)),
                    c("iz · Ił zwykły", "ic · Ił ciężki")))
corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
stopifnot(identical(classify_points(corners, classification_polygons(system)),
                    c("pl · Piasek luźny", "ic · Ił ciężki", "pyz · Pył zwykły")))
example <- read.csv("examples/poland_samples.csv")
stopifnot(identical(classify_soil_data(example, system)$classification_status,
                    c("classified", "classified", "classified", "boundary")))

# The actual rendered gp label must lie in its concave region, not in gl.
source("R/plotting.R")
plot <- build_soil_plot(samples[FALSE, ], system)
labels <- plot$layers[[2]]$data
positions <- data.frame(sand = labels$Sand * 100, clay = labels$Clay * 100)
stopifnot(identical(classify_points(positions, classification_polygons(system)), labels$Label))

app_env <- new.env()
source("soil_triangle.R", local = app_env)
shiny::testServer(app_env$server, {
  soil_data(samples)
  session$setInputs(dataset = system)
  exported <- read.csv(output$downloadDataBtn)
  stopifnot(isTRUE(all.equal(exported, classify_soil_data(samples, system), check.attributes = FALSE)),
            all(exported$classification_system == system),
            identical(results_table()$Class, cases$expected),
            grepl("PTG_2008.TT", output$classificationReference$html, fixed = TRUE),
            grepl("0.05", output$classificationReference$html, fixed = TRUE),
            grepl("Class label key", output$classificationReference$html, fixed = TRUE),
            all(vapply(key$Class, function(label) grepl(label, output$classificationReference$html, fixed = TRUE), logical(1))),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("Poland PTG 2008: 16 classes, Polish key and CSV, boundary, examples, and integration PASS\n")
