# Run from the repository root: Rscript --vanilla tests/brazil.R
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_data.R")
source("R/brazil_data.R")
source("R/classification_systems.R")
source("R/classification.R")

detailed <- "Brazil (SiBCS 2025, 13 classes)"
grouped <- "Brazil (SiBCS 2025, 5 groups)"
samples <- data.frame(
  soil = paste("Reference", 1:13),
  sand = c(10, 25, 5, 50, 30, 10, 60, 40, 65, 15, 5, 85, 95),
  clay = c(75, 50, 50, 45, 33, 33, 25, 20, 10, 20, 5, 5, 3)
)
samples$silt <- 100 - samples$sand - samples$clay
samples <- samples[c("soil", "sand", "silt", "clay")]
expected <- c("Muito argilosa", "Argila", "Argilossiltosa", "Argiloarenosa",
  "Francoargilosa", "Franco-argilossiltosa", "Franco-argiloarenosa", "Franca",
  "Francoarenosa", "Francossiltosa", "Silte", "Areia franca", "Areia")
stopifnot(identical(classify_soil_data(samples, detailed)$classification, expected))

# Independent inequalities from the 2017 USDA text referenced by SiBCS 2025,
# with the Brazilian >60% clay class. This checks polygon implementation against
# analytical definitions rather than using the polygons themselves as an oracle.
reference_classes <- function(p) {
  s <- p$sand; z <- p$silt; c <- p$clay
  result <- rep(NA_character_, nrow(p))
  put <- function(condition, label) result[condition] <<- label
  put(z + 1.5 * c < 15, "Areia")
  put(z + 1.5 * c >= 15 & z + 2 * c < 30, "Areia franca")
  put((c >= 7 & c < 20 & s > 52 & z + 2 * c >= 30) |
        (c < 7 & z < 50 & z + 2 * c >= 30), "Francoarenosa")
  put(c >= 7 & c < 27 & z >= 28 & z < 50 & s <= 52, "Franca")
  put((z >= 50 & c >= 12 & c < 27) | (z >= 50 & z < 80 & c < 12), "Francossiltosa")
  put(z >= 80 & c < 12, "Silte")
  put(c >= 20 & c < 35 & z < 28 & s > 45, "Franco-argiloarenosa")
  put(c >= 27 & c < 40 & s > 20 & s <= 45, "Francoargilosa")
  put(c >= 27 & c < 40 & s <= 20, "Franco-argilossiltosa")
  put(c >= 35 & s > 45, "Argiloarenosa")
  put(c >= 40 & z >= 40, "Argilossiltosa")
  put(c >= 40 & s <= 45 & z < 40, "Argila")
  put(c > 60, "Muito argilosa")
  result
}

reference_groups <- function(p) {
  ifelse(p$clay > 60, "Muito argilosa",
    ifelse(p$clay >= 35, "Argilosa",
      ifelse(p$sand - p$clay > 70, "Arenosa",
        ifelse(p$sand <= 15, "Siltosa", "Média"))))
}

grid <- expand.grid(sand = 0:100, clay = 0:100)
grid <- grid[grid$sand + grid$clay <= 100, ]
grid$silt <- 100 - grid$sand - grid$clay
set.seed(2025)
random <- matrix(rexp(30000), ncol = 3)
random <- random / rowSums(random) * 100
points <- rbind(grid, data.frame(sand = random[, 1], clay = random[, 2], silt = random[, 3]))
for (system in c(detailed, grouped)) {
  polygons <- classification_polygons(system)
  stopifnot(length(polygons) == if (system == detailed) 13L else 5L)
  vertices <- do.call(rbind, polygons)
  stopifnot(all(is.finite(as.matrix(vertices))), all(as.matrix(vertices) >= -1e-12),
            all(as.matrix(vertices) <= 1), all(abs(rowSums(vertices) - 1) < 1e-12))
  area <- sum(vapply(polygons, function(p) {
    j <- c(2:nrow(p), 1)
    abs(sum(p$Sand * p$Clay[j] - p$Clay * p$Sand[j])) / 2
  }, numeric(1)))
  stopifnot(abs(area - 0.5) < 1e-12)
  result <- classification_details(points, polygons)
  stopifnot(!any(result$classification_status %in% c("unclassified", "overlap")),
            identical(result, classification_details(points, rev(polygons))))
  interior <- result$classification_status == "classified"
  reference <- if (system == detailed) reference_classes(points) else reference_groups(points)
  stopifnot(identical(result$classification[interior], reference[interior]))
  corners <- classification_details(data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0)), polygons)
  stopifnot(identical(corners$classification,
    if (system == detailed) c("Areia", "Muito argilosa", "Silte") else c("Arenosa", "Muito argilosa", "Siltosa")))
  cat(system, ": class coverage, area, order independence, and analytical reference checks PASS\n")
}

# Published boundaries remain explicit candidates under the app's common policy.
boundary <- data.frame(soil = "60% clay", sand = 20, silt = 20, clay = 60)
for (system in c(detailed, grouped)) {
  result <- classify_soil_data(boundary, system)
  stopifnot(is.na(result$classification), result$classification_status == "boundary",
    result$classification_candidates == if (system == detailed) "Argila; Muito argilosa" else "Argilosa; Muito argilosa")
}
group_boundaries <- data.frame(soil = c("35% clay", "15% sand", "sand minus clay = 70"),
                              sand = c(30, 15, 80), clay = c(35, 20, 10))
group_boundaries$silt <- 100 - group_boundaries$sand - group_boundaries$clay
result <- classify_soil_data(group_boundaries, grouped)
stopifnot(all(is.na(result$classification)), all(result$classification_status == "boundary"))

# Regression for the exact 27% clay limit and the low-clay sandy-loam notch.
near <- data.frame(soil = c("27.2% clay", "Low clay"), sand = c(30, 47), clay = c(27.2, 5))
near$silt <- 100 - near$sand - near$clay
stopifnot(identical(classify_soil_data(near, detailed)$classification, c("Francoargilosa", "Francoarenosa")))

app_env <- new.env()
source("soil_triangle.R", local = app_env)
shiny::testServer(app_env$server, {
  soil_data(samples)
  for (system in c(detailed, grouped)) {
    session$setInputs(dataset = system)
    result <- read.csv(output$downloadDataBtn)
    stopifnot(isTRUE(all.equal(result, classify_soil_data(samples, system), check.attributes = FALSE)),
              all(result$classification_system == system),
              grepl("SiBCS", output$classificationReference$html, fixed = TRUE),
              grepl("0.05", output$classificationReference$html, fixed = TRUE),
              !any(grepl("\n", result$classification, fixed = TRUE)),
              !is.null(output$ternaryPlot), nrow(results_table()) == nrow(samples))
  }
})
cat("Brazilian results, metadata, versioned exports, and Shiny plots: PASS\n")
