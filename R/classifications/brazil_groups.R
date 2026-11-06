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
  "Argilosa" = c(0, 35, 65, 35, 40, 60, 0, 60),
  "Média" = c(15, 0, 70, 0, 85, 15, 65, 35, 15, 35),
  "Arenosa" = c(70, 0, 100, 0, 85, 15),
  "Siltosa" = c(0, 0, 15, 0, 15, 35, 0, 35)
))


definition <- list(id = "Brazil (SiBCS 2025, 5 groups)", display = "Brazil (SiBCS) · 2025 · 5 groups",
    order = 50, clockwise = TRUE, colours = c(`Muito argilosa` = "#b9a28b",
    Argilosa = "#d8c8b1", Média = "#dedab9", Arenosa = "#efe4c7",
    Siltosa = "#cadcd4"), label_size = 4, label_overrides = list(
        `Muito argilosa` = list(text = "Muito\nargilosa"), Siltosa = list(
            angle = 60)), source = "SiBCS, 6th edition (2025), Figure 1.2 and texture-group definitions, printed pages 55–56",
    source_url = "https://www.infoteca.cnptia.embrapa.br/handle/doc/1176834",
    fractions = "Sand 0.05–2 mm; silt 0.002–0.05 mm; clay <0.002 mm.")

definition$data <- data
definition
