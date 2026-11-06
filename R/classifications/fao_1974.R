# FAO-Unesco Soil Map of the World, Volume I: Legend (1974), printed pp. 4-5.
# Polygons derived independently from the numerical limits and triangle on p. 5.
# Coordinates are (sand %, clay %) pairs; shared edges retain the app policy.
list(
  id = "FAO-UNESCO (1974, 3 groups)",
  display = "FAO–UNESCO · 3 groups (1974)",
  order = 70,
  clockwise = TRUE,
  data = texture_polygons(list(
    "Coarse" = c(65, 0, 100, 0, 82, 18, 65, 18),
    "Medium" = c(0, 0, 65, 0, 65, 18, 82, 18, 65, 35, 0, 35),
    "Fine" = c(0, 35, 65, 35, 0, 100)
  )),
  colours = c("Coarse" = "#efe4c7", "Medium" = "#cbd5ba", "Fine" = "#d8c8b1"),
  label_size = 4,
  source = "FAO-Unesco Soil Map of the World, Volume I: Legend (1974), printed pages 4–5, three textural classes",
  source_url = "https://www.fao.org/4/as360e/as360e.pdf",
  fractions = "Use fine-earth percentages (<2 mm), with sand 0.05–2 mm, silt 0.002–0.05 mm, and clay <0.002 mm. No particle-size conversion is performed."
)
