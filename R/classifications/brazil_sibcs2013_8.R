# SiBCS 2013 texture subgroups, eight classes (not the 13-class detailed view).
# Numerical transcription: Moeys et al., soiltexture 1.5.3, SiBCS13.TT.
# Digitisation credited to Jose Lucas Safanelli and Alexandre ten Caten.
# Source revision and published reference cases: docs/classifications/brazil_sibcs2013_8.md.
# Coordinates are (silt %, clay %) pairs; sand is derived by difference.
vertices <- matrix(c(
  0, 100, 0, 60, 40, 60, 0, 35, 17.5, 35, 50, 35,
  65, 35, 0, 20, 25, 20, 27.5, 25, 0, 15, 0, 10,
  0, 0, 15, 0, 30, 0, 47.5, 0, 85, 0, 100, 0
), ncol = 2, byrow = TRUE)
regions <- list(
  "Muito argilosa" = c(1, 2, 3),
  "Argilosa" = c(2, 3, 7, 6, 5, 4),
  "Siltosa" = c(6, 7, 18, 17),
  "Média siltosa" = c(5, 6, 17, 16, 9, 10),
  "Média argilosa" = c(4, 5, 10, 9, 8),
  "Média arenosa" = c(8, 9, 16, 15, 11),
  "Arenosa média" = c(11, 15, 14, 12),
  "Muito arenosa" = c(12, 14, 13)
)
polygons <- lapply(regions, function(rows) {
  xy <- vertices[rows, , drop = FALSE]
  as.vector(t(cbind(100 - xy[, 1] - xy[, 2], xy[, 2])))
})
codes <- c("MA", "A", "S", "MeS", "MeA", "MeAr", "ArMe", "MAr")
list(
  id = "Brazil (SiBCS 2013, SiBCS13.TT 1.5.3, 8 classes)",
  display = "Brazil (SiBCS) · 2013 · 8 classes",
  order = 55,
  clockwise = TRUE,
  data = texture_polygons(polygons),
  colours = c(
    "Muito argilosa" = "#b9a28b", "Argilosa" = "#d8c8b1",
    "Siltosa" = "#cadcd4", "Média siltosa" = "#cbd5ba",
    "Média argilosa" = "#d4c8a0", "Média arenosa" = "#e8d7b7",
    "Arenosa média" = "#dfd1a7", "Muito arenosa" = "#efe4c7"
  ),
  label_size = 4,
  label_overrides = stats::setNames(lapply(codes, function(code) list(text = code)), names(regions)),
  source = "SiBCS 2013 texture subgroups, eight classes; numerical transcription: Moeys et al., soiltexture 1.5.3, SiBCS13.TT, digitised by Jose Lucas Safanelli and Alexandre ten Caten. Published implementation and reference cases: ten Caten, Safanelli and Silva (2015), Tables 1, 2 and 4, Figure 2b.",
  source_url = "https://www.eventossolos.org.br/cbcs2015/arearestrita/arquivos/1064.pdf",
  fractions = "Fine earth <2 mm: sand 0.05–2 mm; silt 0.002–0.05 mm; clay <0.002 mm. SiBCS13 means the 2013 edition, not 13 classes. This view provides eight texture subgroups, not full SiBCS taxonomy. Switching systems does not convert laboratory fractions."
)
