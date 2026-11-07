# NEN 5104:1989 mineral lutum-silt-zand triangle, 14 classes.
# Geometry: Rijkswaterstaat, Indelen in grondsoorten, Figure 2 (2021);
# corroboration: RIVM report 711701049/2008, Figure 5-1 and Table 5-13.
# Original derivation from published diagram limits; no package dependency.
# The clay/leem segment joins (sand, clay)=(50,8) and (0,25), hence
# clay + 0.34*sand = 25 and its sand=15 intersection is clay=19.9.
polygons <- list(
  "Ks1 · Zwak siltige klei" = c(50, 50, 0, 50, 0, 100),
  "Ks2 · Matig siltige klei" = c(65, 35, 0, 35, 0, 50, 50, 50),
  "Ks3 · Sterk siltige klei" = c(75, 25, 0, 25, 0, 35, 65, 35),
  "Ks4 · Uiterst siltige klei" = c(50, 8, 50, 25, 0, 25),
  "Kz1 · Zwak zandige klei" = c(82.5, 17.5, 50, 17.5, 50, 25, 75, 25),
  "Kz2 · Matig zandige klei" = c(88, 12, 50, 12, 50, 17.5, 82.5, 17.5),
  "Kz3 · Sterk zandige klei" = c(92, 8, 50, 8, 50, 12, 88, 12),
  "Lz1 · Zwak zandige leem" = c(0, 0, 15, 0, 15, 19.9, 0, 25),
  "Lz3 · Sterk zandige leem" = c(15, 0, 50, 0, 50, 8, 15, 19.9),
  "Zk · Kleiig zand" = c(95, 5, 82.5, 5, 82.5, 8, 92, 8),
  "Zs1 · Zwak siltig zand" = c(100, 0, 90, 0, 90, 5, 95, 5),
  "Zs2 · Matig siltig zand" = c(90, 0, 82.5, 0, 82.5, 5, 90, 5),
  "Zs3 · Sterk siltig zand" = c(82.5, 0, 67.5, 0, 67.5, 8, 82.5, 8),
  "Zs4 · Uiterst siltig zand" = c(67.5, 0, 50, 0, 50, 8, 67.5, 8)
)
list(
  id = "Netherlands (NEN 5104 1989, 14 classes)",
  display = "Netherlands (NEN 5104, mineral only) · 1989 · 14 classes",
  order = 210,
  category = "Historic",
  clockwise = TRUE,
  data = texture_polygons(polygons),
  colours = c(
    "Ks1 · Zwak siltige klei" = "#b9a28b", "Ks2 · Matig siltige klei" = "#d8c8b1",
    "Ks3 · Sterk siltige klei" = "#d4c8a0", "Ks4 · Uiterst siltige klei" = "#c6d1bd",
    "Kz1 · Zwak zandige klei" = "#d3b49d", "Kz2 · Matig zandige klei" = "#e0c9a6",
    "Kz3 · Sterk zandige klei" = "#e8d7b7", "Lz1 · Zwak zandige leem" = "#d8e2d9",
    "Lz3 · Sterk zandige leem" = "#cadcd4", "Zk · Kleiig zand" = "#dfd1a7",
    "Zs1 · Zwak siltig zand" = "#efe4c7", "Zs2 · Matig siltig zand" = "#e5dfbd",
    "Zs3 · Sterk siltig zand" = "#dedab9", "Zs4 · Uiterst siltig zand" = "#cbd5ba"
  ),
  label_size = 3.2,
  label_overrides = stats::setNames(lapply(names(polygons), function(label) {
    list(text = strsplit(label, " · ", fixed = TRUE)[[1]][1])
  }), names(polygons)),
  source = "NEN 5104:1989 mineral lutum-silt-zand triangle, 14 classes, reproduced by Rijkswaterstaat (Indelen in grondsoorten, Figure 2, 2021) and RIVM report 711701049/2008 (Figure 5-1, Table 5-13). Historical mineral-only reference. NEN 5104:1989 was withdrawn 20 August 2020; this view does not implement the current ISO 14688/Dutch supplements. Only the mineral triangle is implemented; no organic-matter, gravel or engineering-suitability classification is inferred.",
  source_url = "https://loket.rijkswaterstaat.nl/procedures/publicatie/indelen-in-grondsoorten",
  fractions = "Mass percentages of the mineral fraction below 2 mm, totalling 100%: sand 0.063–2 mm; silt 0.002–0.063 mm; clay (lutum) <0.002 mm. Organic-matter and gravel classification require additional inputs and are excluded. This is the withdrawn NEN 5104:1989 mineral triangle, not a current-standard conformity assessment. Switching systems does not convert or rebase measurements."
)
