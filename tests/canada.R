# Run from the repository root: Rscript --vanilla tests/canada.R
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")

system <- "Canada (CSSC 1998, 13 classes)"
cases <- read.csv("tests/fixtures/canada.csv", stringsAsFactors = FALSE)
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status == "classified"),
          length(unique(cases$expected)) == 13L,
          setequal(unique(classification_definition(system)$data$Label), cases$expected))

# Independent analytic reference from AAFC's glossary. Boundary conventions in
# the prose differ from the app's candidate policy, so compare strict interiors.
reference_canada <- function(p) {
  sand <- p$sand; silt <- p$silt; clay <- p$clay
  result <- rep(NA_character_, nrow(p))
  put <- function(condition, label) result[condition] <<- label
  put(silt + 1.5 * clay < 15, "Sand")
  put(silt + 1.5 * clay >= 15 & silt + 2 * clay < 30, "Loamy Sand")
  put((clay < 20 & sand > 52 & silt + 2 * clay > 30) |
        (clay < 7 & silt < 50 & sand > 43 & sand < 52), "Sandy Loam")
  put(clay > 7 & clay < 27 & silt > 28 & silt < 50 & sand < 52, "Loam")
  put((silt > 50 & clay > 12 & clay < 27) | (silt > 50 & silt < 80 & clay < 12), "Silt Loam")
  put(silt > 80 & clay < 12, "Silt")
  put(clay > 20 & clay < 35 & silt < 28 & sand > 45, "Sandy Clay Loam")
  put(clay > 27 & clay < 40 & sand > 20 & sand < 45, "Clay Loam")
  put(clay > 27 & clay < 40 & sand < 20, "Silty Clay Loam")
  put(clay > 35 & sand > 45, "Sandy Clay")
  put(clay > 40 & silt > 40, "Silty Clay")
  put(clay > 40 & sand < 45 & silt < 40, "Clay")
  put(clay > 60, "Heavy Clay")
  result
}

set.seed(1998)
random <- matrix(rexp(30000), ncol = 3)
random <- random / rowSums(random) * 100
points <- data.frame(sand = random[, 1], silt = random[, 2], clay = random[, 3])
details <- classification_details(points, classification_polygons(system))
stopifnot(all(details$classification_status == "classified"),
          identical(details$classification, reference_canada(points)))

boundary <- data.frame(soil = "60% clay", sand = 20, silt = 20, clay = 60)
details <- classify_soil_data(boundary, system)
stopifnot(is.na(details$classification), details$classification_status == "boundary",
          details$classification_candidates == "Clay; Heavy Clay")
either_side <- data.frame(soil = c("Below", "Above"), sand = 20, clay = c(59.999, 60.001))
either_side$silt <- 100 - either_side$sand - either_side$clay
stopifnot(identical(classify_soil_data(either_side, system)$classification, c("Clay", "Heavy Clay")))
corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
stopifnot(identical(classify_points(corners, classification_polygons(system)), c("Sand", "Heavy Clay", "Silt")))

app_env <- new.env()
source("soil_triangle.R", local = app_env)
shiny::testServer(app_env$server, {
  soil_data(samples)
  session$setInputs(dataset = system)
  exported <- read.csv(output$downloadDataBtn)
  stopifnot(isTRUE(all.equal(exported, classify_soil_data(samples, system), check.attributes = FALSE)),
            all(exported$classification_system == system),
            identical(results_table()$Class, cases$expected),
            grepl("Canadian", output$classificationReference$html, fixed = TRUE),
            grepl("View source publication", output$classificationReference$html, fixed = TRUE),
            !grepl("Embrapa", output$classificationReference$html, fixed = TRUE),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("Canada: 13 reference classes, 10,000 analytical comparisons, boundaries, metadata, and exports PASS\n")
