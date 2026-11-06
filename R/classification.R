# Source data and classification_systems.R before this module.
classification_polygons <- function(system) {
  data <- classification_definition(system)$data
  # Retain the original display labels; match order never resolves ambiguity.
  split(data[c("Sand", "Silt", "Clay")], data$Label)
}

# Distance to polygon edges in sand/clay fraction coordinates. A tolerance of
# 1e-10 fractions handles numerical noise, not laboratory measurement error.
points_on_polygon <- function(x, y, polygon, tolerance = 1e-10) {
  on_edge <- rep(FALSE, length(x))
  next_vertex <- c(seq_len(nrow(polygon))[-1], 1L)
  for (i in seq_len(nrow(polygon))) {
    j <- next_vertex[i]
    dx <- polygon$Sand[j] - polygon$Sand[i]
    dy <- polygon$Clay[j] - polygon$Clay[i]
    length_squared <- dx * dx + dy * dy
    if (length_squared == 0) {
      distance_squared <- (x - polygon$Sand[i])^2 + (y - polygon$Clay[i])^2
    } else {
      position <- ((x - polygon$Sand[i]) * dx + (y - polygon$Clay[i]) * dy) / length_squared
      position <- pmin(1, pmax(0, position))
      distance_squared <- (x - polygon$Sand[i] - position * dx)^2 +
        (y - polygon$Clay[i] - position * dy)^2
    }
    on_edge <- on_edge | distance_squared <= tolerance^2
  }
  on_edge
}

classification_details <- function(points, polygons) {
  result <- data.frame(
    classification = rep(NA_character_, nrow(points)),
    classification_status = rep("unclassified", nrow(points)),
    classification_candidates = rep("", nrow(points)),
    stringsAsFactors = FALSE
  )
  if (nrow(points) == 0L) return(result)
  inside <- on_edge <- matrix(FALSE, nrow(points), length(polygons))
  for (i in seq_along(polygons)) {
    polygon <- polygons[[i]]
    on_edge[, i] <- points_on_polygon(points$sand / 100, points$clay / 100, polygon)
    inside[, i] <- pracma::inpolygon(
      points$sand / 100, points$clay / 100,
      polygon$Sand, polygon$Clay, boundary = FALSE
    ) & !on_edge[, i]
  }
  matches <- inside | on_edge
  counts <- rowSums(matches)
  for (row in seq_len(nrow(points))) {
    candidates <- sort(names(polygons)[matches[row, ]])
    result$classification_candidates[row] <- paste(candidates, collapse = "; ")
    if (counts[row] == 1L) result$classification[row] <- candidates
  }
  result$classification_status[counts == 1L] <- "classified"
  result$classification_status[rowSums(on_edge) > 0L] <- "boundary"
  result$classification_status[rowSums(inside) > 1L] <- "overlap"
  result
}

classify_points <- function(points, polygons) {
  classification_details(points, polygons)$classification
}

classify_soil_data <- function(points, system) {
  polygons <- classification_polygons(system)
  if (nrow(points) > 0L) points <- validate_soil_data(points)
  details <- classification_details(points, polygons)
  points$classification <- details$classification
  points$classification_system <- rep(system, nrow(points))
  points$classification_status <- details$classification_status
  points$classification_candidates <- details$classification_candidates
  points
}
