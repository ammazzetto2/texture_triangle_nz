# Romanian SRTS 2003 texture view: 15 regions, three sand-size groups combined.
# Numerical transcription: Moeys et al., soiltexture 1.5.3, ROM.TT;
# ROM.TT contribution credited to Bogdan Rosca, Romanian Academy, 2010.
# Source revision and grouping limits: docs/classifications/romania_srts2003.md.
# Coordinates are (silt %, clay %) pairs; sand is derived by difference.
vertices <- matrix(c(
  0, 70, 30, 70, 0, 60, 33, 60, 40, 60, 0, 45, 14, 45,
  33, 45, 55, 45, 0, 33, 14, 33, 33, 33, 67, 33,
  0, 20, 14, 20, 33, 20, 50, 20, 80, 20, 0, 12, 33, 12,
  0, 5, 33, 5, 33, 0, 50, 0, 0, 100, 0, 0, 100, 0
), ncol = 2, byrow = TRUE)
regions <- list(
  "AF · Argilă fină" = c(1, 25, 2),
  "AA · Argilă medie" = c(1, 3, 4, 5, 2),
  "AP · Argilă prăfoasă" = c(4, 8, 9, 5),
  "AL · Argilă lutoasă" = c(3, 6, 7, 8, 4),
  "TP · Lut argilo-prăfos" = c(8, 12, 13, 9),
  "TT · Lut argilos mediu" = c(7, 11, 12, 8),
  "TN · Argilă nisipoasă" = c(6, 10, 11, 7),
  "LP · Lut prăfos" = c(12, 16, 17, 18, 13),
  "LL · Lut mediu" = c(11, 15, 16, 12),
  "LN · Lut nisipo-argilos" = c(10, 14, 15, 11),
  "SP · Praf" = c(17, 24, 27, 18),
  "SS · Lut nisipos prăfos" = c(16, 20, 22, 23, 24, 17),
  "SG+SM+SF · Lut nisipos" = c(14, 19, 20, 16, 15),
  "UG+UM+UF · Nisip lutos" = c(19, 21, 22, 20),
  "NG+NM+NF · Nisip" = c(21, 26, 23, 22)
)
polygons <- lapply(regions, function(rows) {
  xy <- vertices[rows, , drop = FALSE]
  as.vector(t(cbind(100 - xy[, 1] - xy[, 2], xy[, 2])))
})
list(
  id = "Romania (SRTS 2003, ROM.TT 1.5.3, 15 regions)",
  display = "Romania (SRTS) · 2003 · 15 regions",
  order = 140,
  clockwise = TRUE,
  data = texture_polygons(polygons),
  colours = c(
    "AF · Argilă fină" = "#b9a28b", "AA · Argilă medie" = "#c5baa7",
    "AP · Argilă prăfoasă" = "#c7cbd9", "AL · Argilă lutoasă" = "#d8c8b1",
    "TP · Lut argilo-prăfos" = "#c6d1bd", "TT · Lut argilos mediu" = "#d4c8a0",
    "TN · Argilă nisipoasă" = "#d3b49d", "LP · Lut prăfos" = "#cbd5ba",
    "LL · Lut mediu" = "#dedab9", "LN · Lut nisipo-argilos" = "#e0c9a6",
    "SP · Praf" = "#d8e2d9", "SS · Lut nisipos prăfos" = "#c5cfaf",
    "SG+SM+SF · Lut nisipos" = "#ddd0ac", "UG+UM+UF · Nisip lutos" = "#e8d7b7",
    "NG+NM+NF · Nisip" = "#efe4c7"
  ),
  label_size = 3.1,
  label_overrides = stats::setNames(lapply(names(regions), function(label) {
    list(text = strsplit(label, " · ", fixed = TRUE)[[1]][1])
  }), names(regions)),
  source = "Romanian SRTS 2003 texture triangle; numerical transcription: Moeys et al., soiltexture 1.5.3, ROM.TT (contributed by Bogdan Rosca); 15 regions with sand-size subclasses grouped",
  source_url = "https://horticultura-bucuresti.ro/site-vechi/images/pdf/Pedologia.pdf#page=39",
  fractions = "Fine earth <2 mm: sand (nisip) 0.02–2 mm; silt (praf) 0.002–0.02 mm; clay (argilă) <0.002 mm. SG+SM+SF, UG+UM+UF and NG+NM+NF combine sand-size subclasses; totals cannot separate them. This view supplies texture only, not full SRTS taxonomy. Switching views does not convert laboratory fractions."
)
