# Historical Whitney / USDA 1911 view, eight classes.
# Factual numerical transcription: Moeys et al., soiltexture 1.5.3, USDA1911;
# package source credits Nic Jelinski (2014).
# Source-label caveat and historical fractions: docs/classifications/usda_1911.md.
# Coordinates are (silt %, clay %) pairs; sand is derived by difference.
vertices <- matrix(c(
  0, 0, 0, 20, 20, 0, 0, 50, 20, 30, 30, 20, 50, 0,
  50, 20, 50, 30, 70, 30, 80, 20, 100, 0, 0, 100
), ncol = 2, byrow = TRUE)
regions <- list(
  "C · Clay" = c(4, 13, 10, 5),
  "SaC · Sandy Clay" = c(2, 4, 5),
  "CL · Clay Loam" = c(5, 9, 8, 6),
  # Preserve the pinned source name/code, despite its silt-side position.
  "SaCL · Sandy Clay Loam" = c(8, 9, 10, 11),
  "L · Loam" = c(7, 6, 8),
  "SiL · Silt Loam" = c(7, 8, 11, 12),
  "SaL · Sandy Loam" = c(3, 2, 5, 7),
  "Sa · Sand" = c(1, 2, 3)
)
polygons <- lapply(regions, function(rows) {
  xy <- vertices[rows, , drop = FALSE]
  as.vector(t(cbind(100 - xy[, 1] - xy[, 2], xy[, 2])))
})
list(
  id = "USDA 1911 (Whitney, USDA1911 1.5.3, 8 classes)",
  display = "USDA · Whitney 1911 (8 classes)",
  order = 180,
  clockwise = TRUE,
  data = texture_polygons(polygons),
  colours = c("C · Clay" = "#d8c8b1", "SaC · Sandy Clay" = "#d3b49d",
              "CL · Clay Loam" = "#d4c8a0", "SaCL · Sandy Clay Loam" = "#c6d1bd",
              "L · Loam" = "#dedab9", "SiL · Silt Loam" = "#cbd5ba",
              "SaL · Sandy Loam" = "#e8d7b7", "Sa · Sand" = "#efe4c7"),
  label_size = 3.8,
  label_overrides = stats::setNames(lapply(names(regions), function(label) {
    list(text = strsplit(label, " · ", fixed = TRUE)[[1]][1])
  }), names(regions)),
  source = "Historical Whitney / USDA 1911 triangle; numerical transcription: Moeys et al., soiltexture 1.5.3, USDA1911 (credited to Nic Jelinski). SaCL retains the package's Sandy Clay Loam label on the silt side, pending historical source review.",
  source_url = "https://www.julienmoeys.info/2015/02/06/texture-triangle-gallery/",
  fractions = "Historical fine-earth fractions: sand 0.05–2 mm; silt 0.005–0.05 mm; clay <0.005 mm. The clay/silt cutoff differs from modern USDA. Use compatible historical measurements; switching views does not convert laboratory fractions. Expand the key for names."
)
