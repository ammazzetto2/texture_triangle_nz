# Run from the repository root: Rscript --vanilla tests/definitions.R
source("R/dependencies.R")
ensure_project_dependencies()
source("R/classification_systems.R")
source("R/classification.R")

# Every discovered definition participates, including future additions.
grid <- expand.grid(sand = 0:100, clay = 0:100)
grid <- grid[grid$sand + grid$clay <= 100, ]
for (system in names(classification_systems)) {
  polygons <- classification_polygons(system)
  area <- sum(vapply(polygons, function(p) {
    next_vertex <- c(2:nrow(p), 1)
    abs(sum(p$Sand * p$Clay[next_vertex] - p$Clay * p$Sand[next_vertex])) / 2
  }, numeric(1)))
  # Explicitly retain the documented original Australian geometry defect.
  expected_area <- if (system == "Australian") 0.50025 else 0.5
  stopifnot(abs(area - expected_area) < 1e-12)
  details <- classification_details(grid, polygons)
  # Concave polygons need not contain their vertex average. Check that every
  # class has a covered interior instead of imposing a convexity assumption.
  stopifnot(all(names(polygons) %in% details$classification[details$classification_status == "classified"]))
  stopifnot(!any(details$classification_status == "unclassified"),
            identical(details, classification_details(grid, rev(polygons))))
  if (system != "Australian") stopifnot(!any(details$classification_status == "overlap"))
  cat(system, ": shared geometry and 5,151-point coverage checks PASS\n")
}

expect_error <- function(expr, pattern) {
  message <- tryCatch({ force(expr); NULL }, error = conditionMessage)
  stopifnot(!is.null(message), grepl(pattern, message, fixed = TRUE))
}
valid <- classification_definition("Canada (CSSC 1998, 13 classes)")
bad <- valid; bad$colours <- bad$colours[-1]
expect_error(validate_classification_definition(bad), "one named hex colour")
bad <- valid; bad$data$Sand[1] <- 50
expect_error(validate_classification_definition(bad), "total one")
bad <- valid; bad$data$Silt[1] <- NA_real_
expect_error(validate_classification_definition(bad), "finite")
bad <- valid; bad$label_overrides <- list("Unknown class" = list(angle = 45))
expect_error(validate_classification_definition(bad), "existing class names")
bad <- valid; bad$source_url <- NULL
expect_error(validate_classification_definition(bad), "Source metadata")
bad <- valid; bad$label_szie <- 3
expect_error(validate_classification_definition(bad), "unknown fields")
expect_error(texture_polygons(list("Invalid" = c(1, 2, 3))), "three finite")
bad <- valid; bad$label_overrides[[names(bad$colours)[1]]] <- list(sand = 70)
expect_error(validate_classification_definition(bad), "sand and clay percentages")
bad <- valid; bad$label_overrides[[names(bad$colours)[1]]] <- list(sand = 80, clay = 30)
expect_error(validate_classification_definition(bad), "sand and clay percentages")

# Loading a new file discovers it without a registry/UI/renderer edit. Order is
# controlled by metadata, not filenames; duplicate IDs fail before app startup.
test_discovery <- function() {
  directory <- tempfile("soil-definitions-")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE))
  first <- valid
  second <- valid; second$id <- "Additional system"; second$display <- "Additional system"; second$order <- 1
  dput(first, file = file.path(directory, "a.R"))
  dput(second, file = file.path(directory, "z.R"))
  loaded <- load_classification_systems(directory)
  stopifnot(identical(names(loaded), c(second$id, first$id)))
  second$id <- first$id
  dput(second, file = file.path(directory, "z.R"))
  expect_error(load_classification_systems(directory), "IDs must be unique")
  unlink(file.path(directory, "z.R"))
  writeLines("42", file.path(directory, "invalid.R"))
  expect_error(load_classification_systems(directory), "invalid.R: Definition requires")
}
test_discovery()
cat("Definition schema, isolated loading, automatic discovery, and error messages: PASS\n")
