# BK94 / Bodenkundliche Kartieranleitung, fourth edition (1994), 31 classes.
# Factual vertex transcription: Moeys et al., soiltexture 1.5.3, DE.BK94.TT.
# Source revision and scope: docs/classifications/germany_bk94.md.
# Coordinates below are (silt %, clay %) pairs; sand is derived by difference.
vertices <- matrix(c(
  100, 0, 92, 8, 88, 12, 83, 17, 80, 0, 80, 8,
  75, 25, 65, 8, 65, 12, 65, 17, 65, 25, 65, 30,
  65, 35, 55, 45, 50, 0, 50, 8, 50, 17, 50, 25,
  50, 30, 50, 35, 50, 45, 40, 0, 40, 8, 40, 12,
  40, 17, 40, 25, 35, 65, 30, 17, 30, 25, 30, 35,
  30, 45, 30, 65, 25, 0, 25, 5, 25, 8, 15, 17,
  15, 25, 15, 35, 15, 45, 15, 65, 10, 0, 10, 5,
  10, 8, 10, 12, 10, 17, 0, 0, 0, 5, 0, 17,
  0, 25, 0, 35, 0, 45, 0, 65, 0, 100
), ncol = 2, byrow = TRUE)
regions <- list(
  "Ss · Reiner Sand" = c(41, 46, 47, 42),
  "Su2 · Schwach schluffiger Sand" = c(33, 41, 42, 34),
  "Sl2 · Schwach lehmiger Sand" = c(34, 42, 43, 35),
  "Sl3 · Mittel lehmiger Sand" = c(23, 35, 43, 44, 24),
  "St2 · Schwach toniger Sand" = c(42, 47, 48, 45, 44, 43),
  "Su3 · Mittel schluffiger Sand" = c(22, 33, 34, 35, 23),
  "Su4 · Stark schluffiger Sand" = c(15, 22, 23, 16),
  "Slu · Schluffig-lehmiger Sand" = c(16, 23, 24, 25, 17),
  "Sl4 · Stark lehmiger Sand" = c(24, 44, 45, 36, 28, 25),
  "St3 · Mittel toniger Sand" = c(36, 45, 48, 49, 37),
  "Ls2 · Schwach sandiger Lehm" = c(17, 25, 26, 18),
  "Ls3 · Mittel sandiger Lehm" = c(25, 28, 29, 26),
  "Ls4 · Stark sandiger Lehm" = c(28, 36, 37, 29),
  "Lt2 · Schwach toniger Lehm" = c(18, 26, 29, 30, 20, 19),
  "Lts · Sandig-toniger Lehm" = c(29, 37, 38, 39, 31, 30),
  "Ts4 · Stark sandiger Ton" = c(37, 49, 50, 38),
  "Ts3 · Mittel sandiger Ton" = c(38, 50, 51, 39),
  "Uu · Reiner Schluff" = c(1, 5, 6, 2),
  "Us · Sandiger Schluff" = c(5, 15, 16, 8, 6),
  "Ut2 · Schwach toniger Schluff" = c(2, 6, 8, 9, 3),
  "Ut3 · Mittel toniger Schluff" = c(3, 9, 10, 4),
  "Uls · Sandig-lehmiger Schluff" = c(8, 16, 17, 10, 9),
  "Ut4 · Stark toniger Schluff" = c(4, 10, 11, 7),
  "Lu · Schluffiger Lehm" = c(10, 17, 18, 19, 12, 11),
  "Lt3 · Mittel toniger Lehm" = c(20, 30, 31, 21),
  "Tu3 · Mittel schluffiger Ton" = c(12, 19, 20, 21, 14, 13),
  "Tu4 · Stark schluffiger Ton" = c(7, 11, 12, 13),
  "Ts2 · Schwach sandiger Ton" = c(39, 51, 52, 40),
  "Tl · Lehmiger Ton" = c(31, 39, 40, 32),
  "Tu2 · Schwach schluffiger Ton" = c(14, 21, 31, 32, 27),
  "Tt · Reiner Ton" = c(27, 32, 40, 52, 53)
)
polygons <- lapply(regions, function(rows) {
  xy <- vertices[rows, , drop = FALSE]
  as.vector(t(cbind(100 - xy[, 1] - xy[, 2], xy[, 2])))
})
list(
  id = "Germany (BK94 1994, 31 classes)",
  display = "Germany · BK94 31 classes (1994)",
  order = 100,
  clockwise = TRUE,
  data = texture_polygons(polygons),
  colours = c(
    "Ss · Reiner Sand" = "#efe4c7",
    "Su2 · Schwach schluffiger Sand" = "#e8d7b7",
    "Sl2 · Schwach lehmiger Sand" = "#dfd1a7",
    "Sl3 · Mittel lehmiger Sand" = "#e0c9a6",
    "St2 · Schwach toniger Sand" = "#efe4c7",
    "Su3 · Mittel schluffiger Sand" = "#e8d7b7",
    "Su4 · Stark schluffiger Sand" = "#dfd1a7",
    "Slu · Schluffig-lehmiger Sand" = "#e0c9a6",
    "Sl4 · Stark lehmiger Sand" = "#efe4c7",
    "St3 · Mittel toniger Sand" = "#e8d7b7",
    "Ls2 · Schwach sandiger Lehm" = "#c5cfaf",
    "Ls3 · Mittel sandiger Lehm" = "#c6d1bd",
    "Ls4 · Stark sandiger Lehm" = "#dedab9",
    "Lt2 · Schwach toniger Lehm" = "#d4c8a0",
    "Lts · Sandig-toniger Lehm" = "#c5cfaf",
    "Ts4 · Stark sandiger Ton" = "#d3b49d",
    "Ts3 · Mittel sandiger Ton" = "#d8c8b1",
    "Uu · Reiner Schluff" = "#cbd5ba",
    "Us · Sandiger Schluff" = "#c6d1bd",
    "Ut2 · Schwach toniger Schluff" = "#c7cbd9",
    "Ut3 · Mittel toniger Schluff" = "#d8e2d9",
    "Uls · Sandig-lehmiger Schluff" = "#cbd5ba",
    "Ut4 · Stark toniger Schluff" = "#c6d1bd",
    "Lu · Schluffiger Lehm" = "#c6d1bd",
    "Lt3 · Mittel toniger Lehm" = "#dedab9",
    "Tu3 · Mittel schluffiger Ton" = "#c5baa7",
    "Tu4 · Stark schluffiger Ton" = "#b9a28b",
    "Ts2 · Schwach sandiger Ton" = "#d3b49d",
    "Tl · Lehmiger Ton" = "#d8c8b1",
    "Tu2 · Schwach schluffiger Ton" = "#c5baa7",
    "Tt · Reiner Ton" = "#b9a28b"
  ),
  label_size = 3.2,
  # Codes are readable in the narrow polygons; the UI generates a full-name key.
  label_overrides = stats::setNames(lapply(names(regions), function(label) {
    list(text = strsplit(label, " · ", fixed = TRUE)[[1]][1])
  }), names(regions)),
  source = "Bodenkundliche Kartieranleitung, fourth edition (1994), BK94; numerical transcription: Moeys et al., soiltexture 1.5.3, DE.BK94.TT (31 classes)",
  source_url = "https://www.hypersoil.uni-muenster.de/0/03/06.htm",
  fractions = "Fine earth <2 mm: sand 0.063–2 mm; silt (Schluff) 0.002–0.063 mm; clay (Ton) <0.002 mm. BK94 is the 1994 edition. Switching views does not convert particle-size measurements. Expand the class-label key for German names."
)
