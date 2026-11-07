# ISSS texture triangle: 12 classes, after Verheye and Ameryckx (1984).
# Numerical transcription: Moeys et al., soiltexture 1.5.3, ISSS.TT;
# ISSS.TT contribution credited to Wei Shangguan.
# Source revision and scope: docs/classifications/isss.md.
# Coordinates are (silt %, clay %) pairs; sand is derived by difference.
vertices <- matrix(c(
  0, 100, 0, 45, 45, 45, 55, 45, 0, 25, 20, 25,
  45, 25, 75, 25, 0, 15, 20, 15, 45, 15, 85, 15,
  0, 5, 0, 0, 15, 0, 35, 0, 45, 0, 100, 0
), ncol = 2, byrow = TRUE)
regions <- list(
  "HCl · Heavy clay" = c(1, 2, 3, 4),
  "SaCl · Sandy clay" = c(2, 5, 6),
  "LCl · Light clay" = c(2, 6, 7, 3),
  "SiCl · Silty clay" = c(3, 7, 8, 4),
  "SaClLo · Sandy clay loam" = c(5, 9, 10, 6),
  "ClLo · Clay loam" = c(6, 10, 11, 7),
  "SiClLo · Silty clay loam" = c(7, 11, 12, 8),
  "LoSa · Loamy sand" = c(9, 13, 15),
  "Sa · Sand" = c(13, 14, 15),
  "SaLo · Sandy loam" = c(9, 15, 16, 10),
  "Lo · Loam" = c(10, 16, 17, 11),
  "SiLo · Silt loam" = c(11, 17, 18, 12)
)
polygons <- lapply(regions, function(rows) {
  xy <- vertices[rows, , drop = FALSE]
  as.vector(t(cbind(100 - xy[, 1] - xy[, 2], xy[, 2])))
})
list(
  id = "ISSS (ISSS.TT 1.5.3, 12 classes)",
  display = "ISSS (also used in Japan) · 1984 reference · 12 classes",
  order = 150,
  clockwise = TRUE,
  data = texture_polygons(polygons),
  colours = c(
    "HCl · Heavy clay" = "#b9a28b",
    "SaCl · Sandy clay" = "#d3b49d",
    "LCl · Light clay" = "#d8c8b1",
    "SiCl · Silty clay" = "#c7cbd9",
    "SaClLo · Sandy clay loam" = "#e0c9a6",
    "ClLo · Clay loam" = "#d4c8a0",
    "SiClLo · Silty clay loam" = "#c6d1bd",
    "LoSa · Loamy sand" = "#dfd1a7",
    "Sa · Sand" = "#efe4c7",
    "SaLo · Sandy loam" = "#e8d7b7",
    "Lo · Loam" = "#dedab9",
    "SiLo · Silt loam" = "#cbd5ba"
  ),
  label_size = 3.5,
  label_overrides = stats::setNames(lapply(names(regions), function(label) {
    list(text = strsplit(label, " · ", fixed = TRUE)[[1]][1])
  }), names(regions)),
  source = "Japanese international-method geometry corroborated by HRO Analysis Methods 2012, corrected chapter III (2013-04-23), Table 2, p.34; exact shared equalities retain the app candidate policy. ISSS texture triangle after Verheye and Ameryckx (1984); numerical transcription: Moeys et al., soiltexture 1.5.3, ISSS.TT (contributed by Wei Shangguan)",
  source_url = "https://www.hro.or.jp/upload/13654/3v2.pdf",
  fractions = "Fine earth <2 mm: sand 0.02–2 mm; silt 0.002–0.02 mm; clay <0.002 mm. This is the ISSS 12-class triangle, not merely a particle-size convention or a USDA alias. Expand the class label key for names. Switching views does not convert laboratory fractions."
)
