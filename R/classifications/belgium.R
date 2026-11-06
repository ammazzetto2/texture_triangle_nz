# Belgian seven-class triangle; official diagram: Flemish field guide, Figure 4.8.
# Numerical transcription: Moeys et al., soiltexture 1.5.3, BE.TT.
# Source revision and scope: docs/classifications/belgium.md.
# Coordinates below are (silt %, clay %) pairs; sand is derived by difference.
vertices <- matrix(c(
  0, 100, 55, 45, 0, 35, 55, 35, 0, 17.5, 15, 17.5,
  52.5, 17.5, 56.875, 18.125, 60, 20, 62.5, 22.5, 70, 30,
  0, 8.75, 8.75, 8.75, 21.25, 11.25, 38.75, 11.25,
  0, 0, 17.5, 0, 32.5, 0, 50, 0, 85, 0, 100, 0
), ncol = 2, byrow = TRUE)
regions <- list(
  "U · Argile lourde / Zware klei" = c(1, 3, 4, 2),
  "E · Argile / Klei" = c(3, 4, 2, 11, 10, 9, 8, 7, 5),
  "A · Limon / Leem" = c(10, 11, 21, 20),
  "L · Limon sableux / Zandleem" = c(6, 7, 8, 9, 10, 20, 19, 15, 14),
  "P · Limon sableux léger / Licht zandleem" = c(14, 15, 19, 18),
  "S · Sable limoneux / Lemig zand" = c(5, 6, 14, 18, 17, 13, 12),
  "Z · Sable / Zand" = c(12, 13, 17, 16)
)
polygons <- lapply(regions, function(rows) {
  xy <- vertices[rows, , drop = FALSE]
  as.vector(t(cbind(100 - xy[, 1] - xy[, 2], xy[, 2])))
})
list(
  id = "Belgium (BE.TT 1.5.3, 7 classes)",
  display = "Belgium · 1984 reference · 7 classes",
  order = 110,
  clockwise = TRUE,
  data = texture_polygons(polygons),
  colours = c(
    "U · Argile lourde / Zware klei" = "#b9a28b",
    "E · Argile / Klei" = "#d8c8b1",
    "A · Limon / Leem" = "#cbd5ba",
    "L · Limon sableux / Zandleem" = "#c6d1bd",
    "P · Limon sableux léger / Licht zandleem" = "#dedab9",
    "S · Sable limoneux / Lemig zand" = "#e8d7b7",
    "Z · Sable / Zand" = "#efe4c7"
  ),
  label_size = 4,
  label_overrides = stats::setNames(lapply(names(regions), function(label) {
    list(text = strsplit(label, " · ", fixed = TRUE)[[1]][1])
  }), names(regions)),
  source = "Belgian seven-class texture triangle; Flemish field guide, Figure 4.8; numerical transcription: Moeys et al., soiltexture 1.5.3, BE.TT",
  source_url = "https://publicaties.onroerenderfgoed.be/HAOE-29-BeschrijvenBodems/04_bodembeschrijving.html#fig-04-08",
  fractions = "Fine earth <2 mm: sand 0.05–2 mm; silt (limon / leem) 0.002–0.05 mm; clay <0.002 mm. Expand the class label key for French and Dutch names. Switching views does not convert laboratory fractions."
)
