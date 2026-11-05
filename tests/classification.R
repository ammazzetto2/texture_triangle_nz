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
            identical(names(empty), c(names(fixtures), "classification", "classification_system",
                                     "classification_status", "classification_candidates")),
            is.character(empty$classification), is.character(empty$classification_system))

  # Unique outer boundaries, including all three corners, have a single class.
  corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
  details <- classification_details(corners, polygons)
  stopifnot(identical(details$classification, c("Sand", "Clay",
              if (system == "Australian") "Silty Loam" else "Silt")),
            all(details$classification_status == "boundary"))
  areas <- vapply(polygons, function(p) {
    next_vertex <- c(2:nrow(p), 1)
    abs(sum(p$Sand * p$Clay[next_vertex] - p$Sand[next_vertex] * p$Clay)) / 2
  }, numeric(1))
  if (system != "Australian") stopifnot(abs(sum(areas) - 0.5) < 1e-10)
  cat(system, "classification checks: PASS; polygon area total:", sum(areas), "\n")
}

# Confirm the known Australian overlap is reported instead of resolved by order.
overlap <- data.frame(soil = "Overlap", sand = 90.5, silt = 1.3, clay = 8.2)
polygons <- classification_polygons("Australian")
matches <- names(polygons)[vapply(polygons, function(p) {
  pracma::inpolygon(overlap$sand / 100, overlap$clay / 100, p$Sand, p$Clay)
}, logical(1))]
details <- classify_soil_data(overlap, "Australian")
stopifnot(identical(matches, c("Sand", "Sandy Loam")),
          is.na(details$classification), details$classification_status == "overlap",
          details$classification_candidates == "Sand; Sandy Loam",
          identical(classification_details(overlap, polygons),
                    classification_details(overlap, rev(polygons))))

# Exact and near shared boundaries must be stable despite floating-point noise.
boundary <- data.frame(soil = "Boundary", sand = 20, silt = 20, clay = 60)
details <- classify_soil_data(boundary, "New Zealand")
stopifnot(is.na(details$classification), details$classification_status == "boundary",
          details$classification_candidates == "Clay; Loamy Clay")
near <- boundary
near$clay <- near$clay + 1e-10
near$silt <- near$silt - 1e-10
stopifnot(identical(classify_soil_data(near, "New Zealand")$classification_candidates,
                    details$classification_candidates))
for (offset in c(-1e-5, 1e-5)) {
  near$clay <- 60 + offset
  near$silt <- 20 - offset
  details <- classify_soil_data(near, "New Zealand")
  stopifnot(details$classification_status == "classified",
            details$classification == if (offset < 0) "Loamy Clay" else "Clay")
}
# No polygon match remains explicit, including when a geometry gap is present.
gap <- classification_details(data.frame(sand = 200, clay = 200), polygons)
stopifnot(is.na(gap$classification), gap$classification_status == "unclassified",
          gap$classification_candidates == "")
for (system in systems) {
  polygons <- classification_polygons(system)
  stopifnot(identical(classification_details(fixtures, polygons),
                      classification_details(fixtures, rev(polygons))))
}

# Sample the complete triangle at whole-percentage resolution. This checks
# coverage at these points only; it cannot prove the absence of small gaps.
grid <- expand.grid(sand = 0:100, clay = 0:100)
grid <- grid[grid$sand + grid$clay <= 100, ]
for (system in systems) {
  details <- classification_details(grid, classification_polygons(system))
  ambiguous <- grepl("; ", details$classification_candidates, fixed = TRUE)
  stopifnot(nrow(details) == 5151L,
            !any(details$classification_status == "unclassified"),
            all(is.na(details$classification[ambiguous])),
            all(!is.na(details$classification[!ambiguous])))
}
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
    expected_export <- classify_soil_data(fixtures, system)
    stopifnot(identical(manual, upload),
              identical(manual$classification, expected[[system]]),
              identical(manual$classification_status, expected_export$classification_status),
              identical(manual$classification_candidates, expected_export$classification_candidates),
              all(manual$classification_system == system))
  }
  soil_data(fixtures[FALSE, ])
  stopifnot(nrow(read.csv(output$downloadDataBtn_manual)) == 0L,
            nrow(read.csv(output$downloadDataBtn_upload)) == 0L)
})
cat("Classification download integration checks: PASS\n")
