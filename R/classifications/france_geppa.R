# GEPPA (1963), 17 classes, as reproduced by Denis Baize / INRAE, Figure 3.
# Numerical coordinate transcription: Julien Moeys et al., soiltexture 1.5.3,
# FR.GEPPA.TT (factual vertex data only; no package functions or dependency).
# Pinned source and precision limits are documented in docs/classifications/france_geppa.md.
# Coordinates below are (silt %, clay %) in the published right-triangle frame.
vertices <- matrix(c(
  0, 100, 0, 60, 45, 55, 0, 45, 20, 42.6, 46.53285, 39.41606,
  62.5, 37.5, 0, 32.5, 25, 30.77586, 54.22883, 28.76008,
  72.5, 27.5, 0, 22.5, 25, 20.98485, 35.14793, 20.36982,
  61.43926, 18.77641, 82.5, 17.5, 0, 12.5, 25, 11.14865,
  40, 10.33784, 68.652344, 8.789063, 92.5, 7.5, 0, 7.5,
  25, 3.333333, 0, 0, 25, 0, 45, 0, 75, 0, 100, 0
), ncol = 2, byrow = TRUE)
regions <- list(
  "AA · Argile lourde" = c(1, 2, 3),
  "A · Argileux" = c(2, 4, 5, 6, 7, 3),
  "As · Argile sableuse" = c(4, 8, 9, 5),
  "Als · Argile limono-sableuse" = c(5, 9, 10, 6),
  "Al · Argile limoneuse" = c(6, 10, 11, 7),
  "AS · Argilo-sableux" = c(8, 12, 13, 9),
  "LAS · Limon argilo-sableux" = c(9, 13, 14, 15, 10),
  "La · Limon argileux" = c(10, 15, 16, 11),
  "Sa · Sable argileux" = c(12, 17, 18, 13),
  "Sal · Sable argilo-limoneux" = c(13, 18, 19, 14),
  "Lsa · Limon sablo-argileux" = c(14, 19, 20, 15),
  "L · Limon" = c(15, 20, 21, 16),
  "S · Sableux" = c(17, 22, 23, 18),
  "SS · Sable" = c(22, 24, 25, 23),
  "Sl · Sable limoneux" = c(18, 23, 25, 26, 19),
  "Ls · Limon sableux" = c(19, 26, 27, 20),
  "LL · Limon pur" = c(20, 27, 28, 21)
)
polygons <- lapply(regions, function(rows) {
  xy <- vertices[rows, , drop = FALSE]
  as.vector(t(cbind(100 - xy[, 1] - xy[, 2], xy[, 2])))
})
list(
  id = "France (GEPPA 1963, 17 classes)",
  display = "France · GEPPA 17 classes (1963)",
  order = 90,
  clockwise = TRUE,
  data = texture_polygons(polygons),
  colours = c(
    "AA · Argile lourde" = "#b9a28b", "A · Argileux" = "#d8c8b1",
    "As · Argile sableuse" = "#d3b49d", "Als · Argile limono-sableuse" = "#c5baa7",
    "Al · Argile limoneuse" = "#c7cbd9", "AS · Argilo-sableux" = "#d6bd98",
    "LAS · Limon argilo-sableux" = "#d4c8a0", "La · Limon argileux" = "#c6d1bd",
    "Sa · Sable argileux" = "#e0c9a6", "Sal · Sable argilo-limoneux" = "#ddd0ac",
    "Lsa · Limon sablo-argileux" = "#c5cfaf", "L · Limon" = "#cbd5ba",
    "S · Sableux" = "#dfd1a7", "SS · Sable" = "#efe4c7",
    "Sl · Sable limoneux" = "#e8d7b7", "Ls · Limon sableux" = "#dedab9",
    "LL · Limon pur" = "#d8e2d9"
  ),
  label_size = 2.7,
  label_overrides = list(
    "AA · Argile lourde" = list(text = "AA · Argile\nlourde", size = 3.5),
    "As · Argile sableuse" = list(text = "As · Argile\nsableuse"),
    "Als · Argile limono-sableuse" = list(text = "Als · Argile\nlimono-sableuse"),
    "Al · Argile limoneuse" = list(text = "Al · Argile\nlimoneuse"),
    "AS · Argilo-sableux" = list(text = "AS · Argilo-\nsableux"),
    "LAS · Limon argilo-sableux" = list(text = "LAS · Limon\nargilo-sableux"),
    "La · Limon argileux" = list(text = "La · Limon\nargileux"),
    "Sa · Sable argileux" = list(text = "Sa · Sable\nargileux"),
    "Sal · Sable argilo-limoneux" = list(text = "Sal · Sable\nargilo-limoneux"),
    "Lsa · Limon sablo-argileux" = list(text = "Lsa · Limon\nsablo-argileux"),
    "Sl · Sable limoneux" = list(text = "Sl · Sable\nlimoneux"),
    "Ls · Limon sableux" = list(text = "Ls · Limon\nsableux")
  ),
  source = "GEPPA (1963), 17 classes; diagram reproduced by Denis Baize, INRAE, Figure 3 (2018); numerical transcription: Moeys et al., soiltexture 1.5.3",
  source_url = "https://mots-agronomie.inrae.fr/index.php?title=Granulom%C3%A9trie_et_diagrammes_de_texture",
  fractions = "Fine earth <2 mm: sand 0.05–2 mm; silt 0.002–0.05 mm; clay <0.002 mm. French class codes are case-sensitive (As and AS differ). The equilateral display preserves compositions; switching systems does not convert laboratory fractions."
)
