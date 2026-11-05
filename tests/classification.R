# Run from the repository root: Rscript --vanilla tests/classification.R
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_data.R")
source("R/classification.R")

systems <- c("New Zealand", "USDA", "Australian")
fixtures <- read_soil_csv("examples/soil_samples.csv")
expected <- list(
  "New Zealand" = c("Clay Loam", NA_character_, "Sand"),
  "USDA" = c("Sandy Clay Loam", "Clay", "Sand"),
  "Australian" = c(NA_character_, "Clay", "Sand")
)
for (system in systems) {
  polygons <- classification_polygons(system)
  vertices <- do.call(rbind, polygons)
  stopifnot(all(is.finite(as.matrix(vertices))),
            all(as.matrix(vertices) >= 0), all(as.matrix(vertices) <= 1),
            all(abs(rowSums(vertices) - 1) < 1e-10))
  centers <- do.call(rbind, lapply(polygons, function(p) {
    data.frame(sand = mean(p$Sand) * 100, silt = mean(p$Silt) * 100,
               clay = mean(p$Clay) * 100)
  }))
  stopifnot(identical(classify_points(centers, polygons), names(polygons)))
  result <- classify_soil_data(fixtures, system)
  stopifnot(identical(result$classification, expected[[system]]),
            all(result$classification_system == system),
            identical(result[names(fixtures)], fixtures))
  empty <- classify_soil_data(fixtures[FALSE, ], system)
  stopifnot(nrow(empty) == 0L,
            identical(names(empty), c(names(fixtures), "classification", "classification_system")),
            is.character(empty$classification), is.character(empty$classification_system))

  # Record the existing boundary limitation, not a scientific endorsement.
  corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
  stopifnot(all(is.na(classify_points(corners, polygons))))
  areas <- vapply(polygons, function(p) {
    next_vertex <- c(2:nrow(p), 1)
    abs(sum(p$Sand * p$Clay[next_vertex] - p$Sand[next_vertex] * p$Clay)) / 2
  }, numeric(1))
  if (system != "Australian") stopifnot(abs(sum(areas) - 0.5) < 1e-10)
  cat(system, "classification checks: PASS; polygon area total:", sum(areas), "\n")
}

# Confirm the known Australian overlap and the existing last-match outcome.
overlap <- data.frame(soil = "Overlap", sand = 90.5, silt = 1.3, clay = 8.2)
polygons <- classification_polygons("Australian")
matches <- names(polygons)[vapply(polygons, function(p) {
  pracma::inpolygon(overlap$sand / 100, overlap$clay / 100, p$Sand, p$Clay)
}, logical(1))]
stopifnot(identical(matches, c("Sand", "Sandy Loam")),
          classify_soil_data(overlap, "Australian")$classification == "Sandy Loam")
error <- tryCatch(classification_polygons("Unknown"), error = conditionMessage)
stopifnot(identical(error, "Unknown classification system: Unknown"))

app_env <- new.env()
source("soil_triangle.R", local = app_env)
shiny::testServer(app_env$server, {
  soil_data(fixtures)
  for (system in systems) {
    session$setInputs(dataset = system, dataset_upload = system)
    # Exercise actual Shiny download handlers, not just the shared helper.
    manual <- read.csv(output$downloadDataBtn_manual)
    upload <- read.csv(output$downloadDataBtn_upload)
    stopifnot(identical(manual, upload),
              identical(manual$classification, expected[[system]]),
              all(manual$classification_system == system))
  }
  soil_data(fixtures[FALSE, ])
  stopifnot(nrow(read.csv(output$downloadDataBtn_manual)) == 0L,
            nrow(read.csv(output$downloadDataBtn_upload)) == 0L)
})
cat("Classification download integration checks: PASS\n")
