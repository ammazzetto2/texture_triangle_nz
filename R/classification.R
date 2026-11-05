# This module expects classification_data.R to have been sourced first.
classification_polygons <- function(system) {
  data <- switch(system,
    "New Zealand" = nz_data,
    "USDA" = usda_data,
    "Australian" = australian_data,
    stop("Unknown classification system: ", system, call. = FALSE)
  )
  # Keep the original split order and display labels to preserve exports.
  split(data[c("Sand", "Silt", "Clay")], data$Label)
}

classify_points <- function(points, polygons) {
  classification <- rep(NA_character_, nrow(points))
  if (nrow(points) == 0L) return(classification)
  for (i in seq_along(polygons)) {
    polygon <- polygons[[i]]
    # Explicitly preserve pracma's default: exact edges are excluded.
    # Defining a scientifically justified boundary policy is a separate change.
    inside <- pracma::inpolygon(
      points$sand / 100, points$clay / 100,
      polygon$Sand, polygon$Clay, boundary = FALSE
    )
    classification[inside] <- names(polygons)[i]
  }
  classification
}

classify_soil_data <- function(points, system) {
  polygons <- classification_polygons(system)
  if (nrow(points) > 0L) points <- validate_soil_data(points)
  points$classification <- classify_points(points, polygons)
  points$classification_system <- rep(system, nrow(points))
  points
}
