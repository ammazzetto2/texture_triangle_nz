# Run from the repository root: Rscript --vanilla tests/uk_tin037.R
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")
system <- "UK (TIN037 2008, 11 classes)"
cases <- read.csv("tests/fixtures/uk_tin037.csv", stringsAsFactors = FALSE)
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status == "classified"),
          length(unique(cases$expected)) == 11L,
          setequal(unique(classification_definition(system)$data$Label), cases$expected))

# Independent analytical interpretation of Figure 1's labelled straight limits.
# In particular, the short Sandy Clay/Clay Loam edge has constant 20% silt.
reference_uk <- function(p) {
  sand <- p$sand; silt <- p$silt; clay <- p$clay
  ifelse(clay < 18,
    ifelse(silt + 1.5 * clay < 15, "Sand",
      ifelse(silt + 2 * clay < 30, "Loamy Sand",
        ifelse(sand > 50, "Sandy Loam", ifelse(sand > 20, "Sandy Silt Loam", "Silt Loam")))),
    ifelse(clay < 35,
      ifelse(sand < 20, "Silty Clay Loam",
        ifelse(clay < 30 & sand > 50, "Sandy Clay Loam",
          ifelse(clay > 30 & (sand > 50 | silt < 20), "Sandy Clay", "Clay Loam"))),
      ifelse(sand > 45, "Sandy Clay", ifelse(silt > 45, "Silty Clay", "Clay"))))
}
set.seed(2008)
random <- matrix(rexp(30000), ncol = 3)
random <- random / rowSums(random) * 100
points <- data.frame(sand = random[, 1], silt = random[, 2], clay = random[, 3])
details <- classification_details(points, classification_polygons(system))
stopifnot(all(details$classification_status == "classified"),
          identical(details$classification, reference_uk(points)))

# Midpoints and perturbations across every internal edge, including the short
# sloping shoulder. Coordinates below are sand/clay percentage pairs.
edges <- data.frame(
  sand = c(87.5, 77.5, 50, 20, 60, 35, 10, 60, 50, 47.5, 20, 35, 45, 10, 10),
  clay = c(5, 7.5, 10, 10, 18, 18, 18, 30, 24, 32.5, 25, 35, 45, 45, 35),
  ds = c(0, 0, 0.001, 0.001, 0, 0, 0, 0, 0.001, 0.001, 0.001, 0, 0.001, 0.001, 0),
  dc = c(0.001, 0.001, 0, 0, 0.001, 0.001, 0.001, 0.001, 0, 0, 0, 0.001, 0, 0, 0.001),
  candidates = c("Loamy Sand; Sand", "Loamy Sand; Sandy Loam", "Sandy Loam; Sandy Silt Loam",
    "Sandy Silt Loam; Silt Loam", "Sandy Clay Loam; Sandy Loam", "Clay Loam; Sandy Silt Loam",
    "Silt Loam; Silty Clay Loam", "Sandy Clay; Sandy Clay Loam", "Clay Loam; Sandy Clay Loam",
    "Clay Loam; Sandy Clay", "Clay Loam; Silty Clay Loam", "Clay; Clay Loam", "Clay; Sandy Clay",
    "Clay; Silty Clay", "Silty Clay; Silty Clay Loam"))
boundary <- classification_details(edges, classification_polygons(system))
stopifnot(all(is.na(boundary$classification)), all(boundary$classification_status == "boundary"),
          identical(boundary$classification_candidates, edges$candidates))
for (direction in c(-1, 1)) {
  side <- data.frame(sand = edges$sand + direction * edges$ds, clay = edges$clay + direction * edges$dc)
  side$silt <- 100 - side$sand - side$clay
  actual <- classification_details(side, classification_polygons(system))
  stopifnot(all(actual$classification_status == "classified"),
            identical(actual$classification, reference_uk(side)))
}
corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
stopifnot(identical(classify_points(corners, classification_polygons(system)), c("Sand", "Clay", "Silt Loam")))
example <- read.csv("examples/uk_samples.csv")
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
            grepl("TIN037", output$classificationReference$html, fixed = TRUE),
            grepl("0.06", output$classificationReference$html, fixed = TRUE),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("UK: 11 classes, 10,000 analytical comparisons, 15 internal edges, metadata, and exports PASS\n")
