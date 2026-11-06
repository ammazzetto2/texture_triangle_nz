# Brazil: Sistema Brasileiro de Classificação de Solos, 6th edition (2025).
# Source: https://www.infoteca.cnptia.embrapa.br/handle/doc/1176834
# Figures 1.1/1.2 and definitions on printed pages 54–56. Figure 1.1 explicitly
# adapts USDA (2017) and adds Muito argilosa above 60% clay. Exact base boundaries
# use Soil Survey Manual (2017), pp. 122–125, rather than tracing raster pixels:
# https://www.nrcs.usda.gov/sites/default/files/2022-09/The-Soil-Survey-Manual.pdf
# Original implementation of these published definitions; no soiltexture code
# or digitised package data is copied. Vertices below are (sand %, clay %).
# The app retains its shared-edge candidate policy, not an inequality tie-break.

data <- texture_polygons(list(
  "Muito argilosa" = c(0, 60, 40, 60, 0, 100),
  "Argila" = c(45, 40, 45, 55, 40, 60, 0, 60, 20, 40),
  "Argilossiltosa" = c(0, 40, 20, 40, 0, 60),
  "Argiloarenosa" = c(45, 35, 65, 35, 45, 55),
  "Francoargilosa" = c(20, 27, 45, 27, 45, 40, 20, 40),
  "Franco-argilossiltosa" = c(0, 27, 20, 27, 20, 40, 0, 40),
  "Franco-argiloarenosa" = c(45, 27, 45, 35, 65, 35, 80, 20, 52, 20),
  "Franca" = c(43, 7, 52, 7, 52, 20, 45, 27, 23, 27),
  "Francoarenosa" = c(70, 0, 50, 0, 43, 7, 52, 7, 52, 20, 80, 20, 85, 15),
  "Francossiltosa" = c(50, 0, 20, 0, 8, 12, 0, 12, 0, 27, 23, 27, 43, 7),
  "Silte" = c(0, 0, 20, 0, 8, 12, 0, 12),
  "Areia franca" = c(70, 0, 85, 0, 90, 10, 85, 15),
  "Areia" = c(85, 0, 100, 0, 90, 10)
))


definition <- list(id = "Brazil (SiBCS 2025, 13 classes)", display = "Brazil · 13 classes",
    order = 40, clockwise = TRUE, colours = c(`Muito argilosa` = "#b9a28b",
    Argila = "#d8c8b1", Argilossiltosa = "#c7cbd9", Argiloarenosa = "#d3b49d",
    Francoargilosa = "#d4c8a0", `Franco-argilossiltosa` = "#c6d1bd",
    `Franco-argiloarenosa` = "#e0c9a6", Franca = "#dedab9", Francoarenosa = "#e8d7b7",
    Francossiltosa = "#cbd5ba", Silte = "#d8e2d9", `Areia franca` = "#dfd1a7",
    Areia = "#efe4c7"), label_size = 3.5, label_overrides = list(
        `Muito argilosa` = list(text = "Muito\nargilosa"), `Franco-argilossiltosa` = list(
            text = "Franco-\nargilossiltosa"), `Franco-argiloarenosa` = list(
            text = "Franco-\nargiloarenosa"), `Areia franca` = list(
            angle = 330)), source = "SiBCS, 6th edition (2025), Figure 1.1, printed page 55",
    source_url = "https://www.infoteca.cnptia.embrapa.br/handle/doc/1176834",
    fractions = "Sand 0.05–2 mm; silt 0.002–0.05 mm; clay <0.002 mm.")

definition$data <- data
definition
