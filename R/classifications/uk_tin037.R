# Natural England TIN037, first edition (21 February 2008), Figure 1 and Table 1.
# Original polygons derived from the labelled limits in Figure 1 (page 1).
# Coordinates are (sand %, clay %) pairs; shared edges retain the app policy.
list(
  id = "UK (TIN037 2008, 11 classes)",
  display = "UK · 11 classes (TIN037 2008)",
  order = 80,
  clockwise = TRUE,
  data = texture_polygons(list(
    "Sand" = c(100, 0, 85, 0, 90, 10),
    "Loamy Sand" = c(85, 0, 70, 0, 85, 15, 90, 10),
    "Sandy Loam" = c(70, 0, 50, 0, 50, 18, 82, 18, 85, 15),
    "Sandy Silt Loam" = c(50, 0, 20, 0, 20, 18, 50, 18),
    "Silt Loam" = c(20, 0, 0, 0, 0, 18, 20, 18),
    "Sandy Clay Loam" = c(82, 18, 50, 18, 50, 30, 70, 30),
    "Clay Loam" = c(50, 18, 20, 18, 20, 35, 45, 35, 50, 30),
    "Silty Clay Loam" = c(20, 18, 0, 18, 0, 35, 20, 35),
    "Sandy Clay" = c(70, 30, 50, 30, 45, 35, 45, 55),
    "Clay" = c(45, 35, 20, 35, 0, 55, 0, 100, 45, 55),
    "Silty Clay" = c(20, 35, 0, 35, 0, 55)
  )),
  colours = c(
    "Sand" = "#efe4c7", "Loamy Sand" = "#dfd1a7", "Sandy Loam" = "#e8d7b7",
    "Sandy Silt Loam" = "#dedab9", "Silt Loam" = "#cbd5ba",
    "Sandy Clay Loam" = "#e0c9a6", "Clay Loam" = "#d4c8a0",
    "Silty Clay Loam" = "#c6d1bd", "Sandy Clay" = "#d3b49d",
    "Clay" = "#d8c8b1", "Silty Clay" = "#c7cbd9"
  ),
  label_size = 3.5,
  label_overrides = list(
    "Loamy Sand" = list(angle = 330),
    "Sandy Silt Loam" = list(text = "Sandy Silt\nLoam"),
    "Sandy Clay Loam" = list(text = "Sandy Clay\nLoam"),
    "Silty Clay Loam" = list(text = "Silty Clay\nLoam"),
    "Sandy Clay" = list(text = "Sandy\nClay"),
    "Silty Clay" = list(text = "Silty\nClay")
  ),
  source = "Natural England TIN037: Soil texture, first edition (21 February 2008), Figure 1 and Table 1; mineral-soil classes of the former Soil Survey of England and Wales",
  source_url = "https://publications.naturalengland.org.uk/file/83081",
  fractions = "Mineral soils: sand 0.06–2 mm; silt 0.002–0.06 mm; clay <0.002 mm. The sand/silt cutoff differs from 0.05 mm systems; switching views does not convert measurements. Organic, peat and calcareous classifications are excluded."
)
