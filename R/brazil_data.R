# Brazil: Sistema Brasileiro de Classificação de Solos, 6th edition (2025).
# Source: https://www.infoteca.cnptia.embrapa.br/handle/doc/1176834
# Figures 1.1/1.2 and definitions on printed pages 54–56. Figure 1.1 explicitly
# adapts USDA (2017) and adds Muito argilosa above 60% clay. Exact base boundaries
# use Soil Survey Manual (2017), pp. 122–125, rather than tracing raster pixels:
# https://www.nrcs.usda.gov/sites/default/files/2022-09/The-Soil-Survey-Manual.pdf
# Original implementation of these published definitions; no soiltexture code
# or digitised package data is copied. Vertices below are (sand %, clay %).
# The app retains its shared-edge candidate policy, not an inequality tie-break.
make_brazil_polygons <- function(vertices) {
  data <- lapply(names(vertices), function(label) {
    xy <- matrix(vertices[[label]], ncol = 2, byrow = TRUE)
    data.frame(Sand = xy[, 1] / 100, Clay = xy[, 2] / 100,
               Silt = (100 - xy[, 1] - xy[, 2]) / 100,
               Label = label, stringsAsFactors = FALSE)
  })
  do.call(rbind, data)
}

brazil_data <- make_brazil_polygons(list(
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

# Group boundaries are independent of the detailed class polygons: e.g. Siltosa
# uses sand <=15% and clay <35%, rather than simply merging Silte polygons.
brazil_groups_data <- make_brazil_polygons(list(
  "Muito argilosa" = c(0, 60, 40, 60, 0, 100),
  "Argilosa" = c(0, 35, 65, 35, 40, 60, 0, 60),
  "Média" = c(15, 0, 70, 0, 85, 15, 65, 35, 15, 35),
  "Arenosa" = c(70, 0, 100, 0, 85, 15),
  "Siltosa" = c(0, 0, 15, 0, 15, 35, 0, 35)
))
