# Poland: PTG 2008, adopted 5 March 2008, published in 2009.
# Numerical transcription: Moeys et al., soiltexture 1.5.3, PTG_2008.TT.
# Polish names/diacritics follow the original PTG publication, Table 2.
# Pinned binary data source: docs/classifications/poland_ptg2008.md.
# Coordinates are (silt %, clay %) pairs; sand is derived by difference.
vertices <- matrix(c(
  0, 100,
  0, 60,
  40, 60,
  0, 55,
  15, 40,
  40, 40,
  60, 40,
  0, 35,
  20, 35,
  28, 27,
  50, 27,
  53, 27,
  73, 27,
  0, 20,
  15, 20,
  28, 20,
  50, 12,
  80, 12,
  88, 12,
  28, 7,
  41, 7,
  50, 7,
  0, 15,
  0, 10,
  0, 5,
  0, 0,
  10, 0,
  15, 0,
  30, 0,
  50, 0,
  80, 0,
  100, 0
), ncol = 2, byrow = TRUE)
regions <- list(
  "ic · Ił ciężki" = c(1, 2, 3),
  "iz · Ił zwykły" = c(2, 3, 6, 5, 4),
  "ipy · Ił pylasty" = c(3, 7, 6),
  "ip · Ił piaszczysty" = c(4, 5, 9, 8),
  "gi · Glina ilasta" = c(5, 6, 12, 11, 10, 9),
  "gpyi · Glina pylasto-ilasta" = c(6, 7, 13, 12),
  "gpi · Glina piaszczysto-ilasta" = c(8, 9, 10, 16, 15, 14),
  "gz · Glina zwykła" = c(10, 11, 17, 22, 21, 16),
  "pyi · Pył ilasty" = c(11, 12, 13, 19, 18, 17),
  "pyg · Pył gliniasty" = c(17, 18, 31, 30, 22),
  "gl · Glina lekka" = c(15, 16, 21, 20),
  "gp · Glina piaszczysta" = c(14, 15, 20, 21, 22, 30, 29, 23),
  "pyz · Pył zwykły" = c(18, 19, 32, 31),
  "pg · Piasek gliniasty" = c(23, 29, 28, 24),
  "ps · Piasek słabogliniasty" = c(24, 28, 27, 25),
  "pl · Piasek luźny" = c(25, 27, 26)
)
polygons <- lapply(regions, function(rows) {
  xy <- vertices[rows, , drop = FALSE]
  as.vector(t(cbind(100 - xy[, 1] - xy[, 2], xy[, 2])))
})
list(
  id = "Poland (PTG 2008, PTG_2008.TT 1.5.3, 16 classes)",
  display = "Poland (PTG) · 2008 · 16 classes",
  order = 190,
  clockwise = TRUE,
  data = texture_polygons(polygons),
  colours = c(
    "ic · Ił ciężki" = "#b9a28b",
    "iz · Ił zwykły" = "#d8c8b1",
    "ipy · Ił pylasty" = "#c7cbd9",
    "ip · Ił piaszczysty" = "#d3b49d",
    "gi · Glina ilasta" = "#d4c8a0",
    "gpyi · Glina pylasto-ilasta" = "#c6d1bd",
    "gpi · Glina piaszczysto-ilasta" = "#e0c9a6",
    "gz · Glina zwykła" = "#dedab9",
    "pyi · Pył ilasty" = "#c5cfaf",
    "pyg · Pył gliniasty" = "#cbd5ba",
    "gl · Glina lekka" = "#ddd0ac",
    "gp · Glina piaszczysta" = "#e8d7b7",
    "pyz · Pył zwykły" = "#d8e2d9",
    "pg · Piasek gliniasty" = "#dfd1a7",
    "ps · Piasek słabogliniasty" = "#e5dcbf",
    "pl · Piasek luźny" = "#efe4c7"
  ),
  label_size = 3.2,
  label_overrides = stats::setNames(lapply(names(regions), function(label) {
    override <- list(text = strsplit(label, " · ", fixed = TRUE)[[1]][1])
    # gp is concave: its vertex average lies in gl. Place its code in gp.
    if (label == "gp · Glina piaszczysta") {
      override$sand <- 70
      override$clay <- 5
    }
    override
  }), names(regions)),
  source = "Polish Society of Soil Science, PTG 2008 classification (adopted 5 March 2008; published 2009), Table 2 and Figure 1; numerical transcription: Moeys et al., soiltexture 1.5.3, PTG_2008.TT",
  source_url = "https://ssa.ptgleb.pl/wp-content/uploads/pdf/2009-60-2/2009-60-2-s-5-16.pdf",
  fractions = "Fine earth <2 mm: sand (piasek) 0.05–2 mm; silt (pył) 0.002–0.05 mm; clay (ił) <0.002 mm. This PTG 2008 view is separate from older Polish schemes. Sand-size subclasses and coarse fragments are excluded. Switching systems does not convert laboratory fractions."
)
