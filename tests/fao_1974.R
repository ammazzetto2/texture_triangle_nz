# Run from the repository root: Rscript --vanilla tests/fao_1974.R
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")

system <- "FAO-UNESCO (1974, 3 groups)"
cases <- read.csv("tests/fixtures/fao_1974.csv", stringsAsFactors = FALSE)
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status == "classified"),
          setequal(unique(classification_definition(system)$data$Label), cases$expected))

# Independent numerical reference from the 1974 Legend, p. 5. Random points
# test strict interiors; exact limits are tested separately under the app policy.
set.seed(1974)
random <- matrix(rexp(30000), ncol = 3)
random <- random / rowSums(random) * 100
points <- data.frame(sand = random[, 1], silt = random[, 2], clay = random[, 3])
expected <- ifelse(points$clay > 35, "Fine",
                   ifelse(points$clay < 18 & points$sand > 65, "Coarse", "Medium"))
details <- classification_details(points, classification_polygons(system))
stopifnot(all(details$classification_status == "classified"),
          identical(details$classification, expected))

# Both parts of the coarse/medium step, the fine limit, and the step vertex.
boundaries <- data.frame(soil = c("Sand step", "Clay step", "Fine limit", "Step vertex"),
                         sand = c(65, 70, 20, 65), clay = c(10, 18, 35, 18))
boundaries$silt <- 100 - boundaries$sand - boundaries$clay
result <- classify_soil_data(boundaries, system)
stopifnot(all(is.na(result$classification)), all(result$classification_status == "boundary"),
          identical(result$classification_candidates,
                    c("Coarse; Medium", "Coarse; Medium", "Fine; Medium", "Coarse; Medium")))
sides <- data.frame(sand = c(64.999, 65.001, 70, 70, 20, 20),
                    clay = c(10, 10, 17.999, 18.001, 34.999, 35.001))
stopifnot(identical(classify_points(sides, classification_polygons(system)),
                    c("Medium", "Coarse", "Coarse", "Medium", "Medium", "Fine")))
corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
stopifnot(identical(classify_points(corners, classification_polygons(system)),
                    c("Coarse", "Fine", "Medium")))
example <- read.csv("examples/fao_1974_samples.csv")
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
            grepl("1974", output$classificationReference$html, fixed = TRUE),
            grepl("View source publication", output$classificationReference$html, fixed = TRUE),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("FAO-UNESCO: reference cases, 10,000 analytical comparisons, boundaries, metadata, and exports PASS\n")
