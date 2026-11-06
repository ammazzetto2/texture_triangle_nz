# German TGL85 1985 triangle for agricultural soils: 14 classes.
# Factual numerical transcription: Moeys et al., soiltexture 1.5.3, DE.TGL85.TT.
# Source revision and scope: docs/classifications/germany_tgl85.md.
# Coordinates are (silt %, clay %) pairs; sand is derived by difference.
vertices <- matrix(c(
  0, 100, 50, 50, 30, 50, 0, 50, 70, 30, 50, 30,
  20, 30, 0, 30, 82, 18, 50, 18, 0, 18, 92, 8,
  72, 8, 80, 0, 100, 0, 0, 14, 0, 11, 0, 8,
  0, 5, 0, 0, 15, 0, 30, 0, 30, 5, 30, 8.5,
  50, 0, 50, 5
), ncol = 2, byrow = TRUE)
regions <- list(
  "rS · Reiner Sand" = c(19, 20, 21),
  "l''S · Sehr schwach lehmiger Sand" = c(18, 19, 21, 22),
  "l'S · Schwach lehmiger Sand" = c(17, 18, 22, 23),
  "lS · Stark lehmiger Sand" = c(16, 17, 23, 24),
  "uS · Schluffiger Sand" = c(24, 23, 22, 25, 26),
  "U · Schluff" = c(13, 14, 15, 12),
  "lU · Lehmiger Schluff" = c(10, 26, 25, 14, 13, 12, 9),
  "sL · Sandiger Lehm" = c(11, 16, 24, 26, 10),
  "L · Lehm" = c(8, 11, 10, 6, 7),
  "UL · Schlufflehm" = c(6, 10, 9, 5),
  "uT · Schluffiger Ton" = c(3, 6, 5, 2),
  "lT · Lehmiger Ton" = c(4, 7, 6, 3),
  "sT · Sandiger Ton" = c(4, 8, 7),
  "T · Ton" = c(1, 4, 3, 2)
)
polygons <- lapply(regions, function(rows) {
  xy <- vertices[rows, , drop = FALSE]
  as.vector(t(cbind(100 - xy[, 1] - xy[, 2], xy[, 2])))
})
list(
  id = "Germany (TGL85 1985, DE.TGL85.TT 1.5.3, 14 classes)",
  display = "Germany · TGL85 1985 (14 classes)",
  order = 170,
  clockwise = TRUE,
  data = texture_polygons(polygons),
  colours = c(
    "rS · Reiner Sand" = "#efe4c7",
    "l''S · Sehr schwach lehmiger Sand" = "#e8d7b7",
    "l'S · Schwach lehmiger Sand" = "#ddd0ac",
    "lS · Stark lehmiger Sand" = "#dfd1a7",
    "uS · Schluffiger Sand" = "#dedab9",
    "U · Schluff" = "#d8e2d9",
    "lU · Lehmiger Schluff" = "#cbd5ba",
    "sL · Sandiger Lehm" = "#e0c9a6",
    "L · Lehm" = "#d4c8a0",
    "UL · Schlufflehm" = "#c6d1bd",
    "uT · Schluffiger Ton" = "#c7cbd9",
    "lT · Lehmiger Ton" = "#d8c8b1",
    "sT · Sandiger Ton" = "#d3b49d",
    "T · Ton" = "#b9a28b"
  ),
  label_size = 3.5,
  label_overrides = stats::setNames(lapply(names(regions), function(label) {
    list(text = strsplit(label, " · ", fixed = TRUE)[[1]][1])
  }), names(regions)),
  source = "Historical German TGL85 1985 texture triangle for agricultural soils; numerical transcription: Moeys et al., soiltexture 1.5.3, DE.TGL85.TT",
  source_url = "https://www.julienmoeys.info/2015/02/06/texture-triangle-gallery/",
  fractions = "Fine earth <2 mm: sand 0.063–2 mm; silt (Schluff) 0.002–0.063 mm; clay (Ton) <0.002 mm. Historical TGL85 1985 view for agricultural soils, separate from BK94. Expand the key for German names. Switching views does not convert laboratory fractions."
)
