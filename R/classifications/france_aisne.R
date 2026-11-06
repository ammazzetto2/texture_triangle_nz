# Aisne/Jamagne, modified 15-class form; INRAE / Denis Baize, Figure 2.
# Numerical transcription: Moeys et al., soiltexture 1.5.3, FR.AISNE.TT.
# Source revision and historical scope: docs/classifications/france_aisne.md.
# Coordinates below are (silt %, clay %) pairs; sand is derived by difference.
vertices <- matrix(c(
  0, 45, 10, 45, 35, 45, 55, 45, 0, 25, 20, 25,
  25, 30, 35, 30, 50, 30, 70, 30, 0, 10, 10, 10,
  10, 12.5, 32.5, 12.5, 27.5, 17.5, 47.5, 17.5,
  67.5, 17.5, 82.5, 17.5, 0, 0, 20, 0, 37.5, 7.5,
  57.5, 7.5, 77.5, 7.5, 92.5, 7.5, 45, 0, 85, 0,
  100, 0, 0, 100, 55, 30
), ncol = 2, byrow = TRUE)
regions <- list(
  "ALO · Argile lourde" = c(28, 1, 4),
  "A · Argile" = c(2, 7, 9, 3),
  "AL · Argile limoneuse" = c(3, 9, 10, 4),
  "AS · Argile sableuse" = c(1, 5, 6, 7, 2),
  "LA · Limon argileux" = c(29, 17, 18, 10),
  "LAS · Limon argilo-sableux" = c(8, 16, 17, 29, 9),
  "LSA · Limon sablo-argileux" = c(7, 6, 15, 16, 8),
  "SA · Sable argileux" = c(5, 11, 12, 13, 14, 15, 6),
  "LM · Limon moyen" = c(17, 23, 24, 18),
  "LMS · Limon moyen sableux" = c(16, 22, 23, 17),
  "LS · Limon sableux" = c(15, 14, 21, 22, 16),
  "SL · Sable limoneux" = c(13, 12, 20, 25, 21, 14),
  "S · Sable" = c(11, 19, 20, 12),
  "LL · Limon léger" = c(23, 26, 27, 24),
  "LLS · Limon léger sableux" = c(21, 25, 26, 23, 22)
)
polygons <- lapply(regions, function(rows) {
  xy <- vertices[rows, , drop = FALSE]
  as.vector(t(cbind(100 - xy[, 1] - xy[, 2], xy[, 2])))
})
list(
  id = "France (Aisne-Jamagne, FR.AISNE.TT 1.5.3, 15 classes)",
  display = "France · Aisne/Jamagne 15 classes",
  order = 130,
  clockwise = TRUE,
  data = texture_polygons(polygons),
  colours = c(
    "ALO · Argile lourde" = "#b9a28b", "A · Argile" = "#d8c8b1",
    "AL · Argile limoneuse" = "#c7cbd9", "AS · Argile sableuse" = "#d3b49d",
    "LA · Limon argileux" = "#c6d1bd", "LAS · Limon argilo-sableux" = "#d4c8a0",
    "LSA · Limon sablo-argileux" = "#c5cfaf", "SA · Sable argileux" = "#e0c9a6",
    "LM · Limon moyen" = "#cbd5ba", "LMS · Limon moyen sableux" = "#dedab9",
    "LS · Limon sableux" = "#ddd0ac", "SL · Sable limoneux" = "#e8d7b7",
    "S · Sable" = "#efe4c7", "LL · Limon léger" = "#d8e2d9",
    "LLS · Limon léger sableux" = "#d1d9c4"
  ),
  label_size = 3.5,
  label_overrides = stats::setNames(lapply(names(regions), function(label) {
    list(text = strsplit(label, " · ", fixed = TRUE)[[1]][1])
  }), names(regions)),
  source = "Aisne/Jamagne modified 15-class triangle; Denis Baize / INRAE, Figure 2 (2018); numerical transcription: Moeys et al., soiltexture 1.5.3, FR.AISNE.TT",
  source_url = "https://mots-agronomie.inrae.fr/index.php?title=Granulom%C3%A9trie_et_diagrammes_de_texture",
  fractions = "Fine earth <2 mm: sand 0.05–2 mm; silt 0.002–0.05 mm; clay <0.002 mm. This modified 15-class Aisne/Jamagne view is separate from GEPPA. Expand the class label key for French names. Switching systems does not convert laboratory fractions."
)
