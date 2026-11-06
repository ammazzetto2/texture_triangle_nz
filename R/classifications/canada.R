# Canadian System of Soil Classification, 3rd edition (1998), Figure 42:
# https://sis.agr.gc.ca/cansis/taxa/cssc3/chpt17.html
# Numerical class limits are specified in the AAFC soil-science glossary:
# https://sis.agr.gc.ca/cansis/glossary/t/index.html
# Original polygons derived from those definitions, not another country's data.
# Coordinates are (sand %, clay %) pairs. Shared edges retain the app policy.
list(
  id = "Canada (CSSC 1998, 13 classes)",
  display = "Canada (CSSC) · 1998 · 13 classes",
  order = 60,
  clockwise = TRUE,
  data = texture_polygons(list(
    "Heavy Clay" = c(0, 60, 40, 60, 0, 100),
    "Clay" = c(45, 40, 45, 55, 40, 60, 0, 60, 20, 40),
    "Silty Clay" = c(0, 40, 20, 40, 0, 60),
    "Sandy Clay" = c(45, 35, 65, 35, 45, 55),
    "Clay Loam" = c(20, 27, 45, 27, 45, 40, 20, 40),
    "Silty Clay Loam" = c(0, 27, 20, 27, 20, 40, 0, 40),
    "Sandy Clay Loam" = c(45, 27, 45, 35, 65, 35, 80, 20, 52, 20),
    "Loam" = c(43, 7, 52, 7, 52, 20, 45, 27, 23, 27),
    "Sandy Loam" = c(70, 0, 50, 0, 43, 7, 52, 7, 52, 20, 80, 20, 85, 15),
    "Silt Loam" = c(50, 0, 20, 0, 8, 12, 0, 12, 0, 27, 23, 27, 43, 7),
    "Silt" = c(0, 0, 20, 0, 8, 12, 0, 12),
    "Loamy Sand" = c(70, 0, 85, 0, 90, 10, 85, 15),
    "Sand" = c(85, 0, 100, 0, 90, 10)
  )),
  colours = c(
    "Heavy Clay" = "#b9a28b", "Clay" = "#d8c8b1", "Silty Clay" = "#c7cbd9",
    "Sandy Clay" = "#d3b49d", "Clay Loam" = "#d4c8a0", "Silty Clay Loam" = "#c6d1bd",
    "Sandy Clay Loam" = "#e0c9a6", "Loam" = "#dedab9", "Sandy Loam" = "#e8d7b7",
    "Silt Loam" = "#cbd5ba", "Silt" = "#d8e2d9", "Loamy Sand" = "#dfd1a7", "Sand" = "#efe4c7"
  ),
  label_size = 3.5,
  label_overrides = list(
    "Heavy Clay" = list(text = "Heavy\nClay"),
    "Sandy Clay" = list(text = "Sandy\nClay"),
    "Silty Clay Loam" = list(text = "Silty Clay\nLoam"),
    "Sandy Clay Loam" = list(text = "Sandy Clay\nLoam"),
    "Loamy Sand" = list(angle = 330)
  ),
  source = "The Canadian System of Soil Classification, 3rd edition (1998), Chapter 17, Figure 42; AAFC texture-class glossary",
  source_url = "https://sis.agr.gc.ca/cansis/taxa/cssc3/chpt17.html",
  fractions = "Fine earth <2 mm: sand 0.05–2 mm; silt 0.002–0.05 mm; clay ≤0.002 mm."
)
