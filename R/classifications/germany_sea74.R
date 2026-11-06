# German SEA74 1974 triangle for forest soils: 13 classes.
# Factual numerical transcription: Moeys et al., soiltexture 1.5.3, DE.SEA74.TT.
# Source revision and scope: docs/classifications/germany_sea74.md.
# Coordinates are (silt %, clay %) pairs; sand is derived by difference.
vertices <- matrix(c(
  0, 100, 55, 45, 0, 45, 70, 30, 55, 30, 15, 30,
  0, 30, 82, 18, 55, 18, 15, 18, 0, 15, 15, 12,
  55, 5, 55, 0, 20, 0, 10, 0, 0, 0, 0, 5,
  0, 10, 7.5, 2.5, 15, 5, 80, 8, 92, 8, 100, 0,
  80, 0, 40, 45
), ncol = 2, byrow = TRUE)
regions <- list(
  "L · Lehm" = c(10, 6, 5, 9),
  "stL · Sandig-toniger Lehm" = c(11, 7, 6, 10, 12),
  "sL · Sandiger Lehm" = c(12, 10, 9, 13),
  "S · Sand" = c(17, 18, 20, 16),
  "alS · Anlehmiger Sand" = c(18, 19, 21, 15, 16, 20),
  "lS · Lehmiger Sand" = c(19, 11, 12, 13, 14, 15, 21),
  "T · Ton" = c(3, 1, 2),
  "uT · Schluffiger Ton" = c(5, 26, 2, 4),
  "lT · Lehmiger Ton" = c(3, 26, 5, 6),
  "sT · Sandiger Ton" = c(7, 3, 6),
  "U · Schluff" = c(25, 22, 23, 24),
  "UL · Schlufflehm" = c(9, 5, 4, 8),
  "lU · Lehmiger Schluff" = c(14, 13, 9, 8, 23, 22, 25)
)
polygons <- lapply(regions, function(rows) {
  xy <- vertices[rows, , drop = FALSE]
  as.vector(t(cbind(100 - xy[, 1] - xy[, 2], xy[, 2])))
})
list(
  id = "Germany (SEA74 1974, DE.SEA74.TT 1.5.3, 13 classes)",
  display = "Germany (SEA74) · 1974 · 13 classes",
  order = 160,
  category = "Historic",
  clockwise = TRUE,
  data = texture_polygons(polygons),
  colours = c(
    "L · Lehm" = "#d4c8a0",
    "stL · Sandig-toniger Lehm" = "#d3b49d",
    "sL · Sandiger Lehm" = "#e0c9a6",
    "S · Sand" = "#efe4c7",
    "alS · Anlehmiger Sand" = "#e8d7b7",
    "lS · Lehmiger Sand" = "#dfd1a7",
    "T · Ton" = "#b9a28b",
    "uT · Schluffiger Ton" = "#c7cbd9",
    "lT · Lehmiger Ton" = "#d8c8b1",
    "sT · Sandiger Ton" = "#d3b49d",
    "U · Schluff" = "#d8e2d9",
    "UL · Schlufflehm" = "#c6d1bd",
    "lU · Lehmiger Schluff" = "#cbd5ba"
  ),
  label_size = 3.5,
  label_overrides = stats::setNames(lapply(names(regions), function(label) {
    list(text = strsplit(label, " · ", fixed = TRUE)[[1]][1])
  }), names(regions)),
  source = "Historical German SEA74 1974 texture triangle for forest soils; numerical transcription: Moeys et al., soiltexture 1.5.3, DE.SEA74.TT",
  source_url = "https://www.julienmoeys.info/2015/02/06/texture-triangle-gallery/",
  fractions = "Fine earth <2 mm: sand 0.063–2 mm; silt (Schluff) 0.002–0.063 mm; clay (Ton) <0.002 mm. Historical SEA74 1974 view for forest soils, separate from BK94. Expand the key for German names. Switching views does not convert laboratory fractions."
)
