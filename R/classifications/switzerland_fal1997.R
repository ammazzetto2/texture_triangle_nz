# Swiss FAL 1997: 13 mineral fine-earth texture classes.
# Brunner, Jaeggli, Nievergelt and Peyer, Schriftenreihe der FAL 24 (1997),
# section 3.5, Tables 3.5a/3.5b and Figure 3.5a (PDF pages 34-35).
# Original polygons derived from the primary table, not ggsoiltexture's
# separate ten-class Canton Zurich dataset. See source and review notes.
# Vertices are (sand %, clay %) pairs; shared edges retain all candidates.
polygons <- list(
  "S · Sand" = c(100, 0, 85, 0, 80, 5, 95, 5),
  "uS · Schluffiger Sand" = c(85, 0, 50, 0, 45, 5, 80, 5),
  "lS · Lehmiger Sand" = c(95, 5, 45, 5, 40, 10, 90, 10),
  "lrS · Lehmreicher Sand" = c(90, 10, 40, 10, 35, 15, 85, 15),
  "sL · Sandiger Lehm" = c(85, 15, 35, 15, 30, 20, 80, 20),
  "L · Lehm" = c(80, 20, 30, 20, 20, 30, 70, 30),
  "tL · Toniger Lehm" = c(70, 30, 20, 30, 10, 40, 60, 40),
  "lT · Lehmiger Ton" = c(60, 40, 10, 40, 0, 50, 50, 50),
  "T · Ton" = c(50, 50, 0, 50, 0, 100),
  "sU · Sandiger Schluff" = c(50, 0, 30, 0, 20, 10, 40, 10),
  "U · Schluff" = c(30, 0, 0, 0, 0, 10, 20, 10),
  "lU · Lehmiger Schluff" = c(40, 10, 0, 10, 0, 30, 20, 30),
  "tU · Toniger Schluff" = c(20, 30, 0, 30, 0, 50)
)
list(
  id = "Switzerland (FAL 1997, 13 classes)",
  display = "Switzerland (FAL) · 1997 · 13 classes",
  order = 200,
  clockwise = TRUE,
  data = texture_polygons(polygons),
  colours = c(
    "S · Sand" = "#efe4c7", "uS · Schluffiger Sand" = "#e5dfbd",
    "lS · Lehmiger Sand" = "#dfd1a7", "lrS · Lehmreicher Sand" = "#e8d7b7",
    "sL · Sandiger Lehm" = "#e0c9a6", "L · Lehm" = "#dedab9",
    "tL · Toniger Lehm" = "#d4c8a0", "lT · Lehmiger Ton" = "#d8c8b1",
    "T · Ton" = "#b9a28b", "sU · Sandiger Schluff" = "#cadcd4",
    "U · Schluff" = "#d8e2d9", "lU · Lehmiger Schluff" = "#cbd5ba",
    "tU · Toniger Schluff" = "#c6d1bd"
  ),
  label_size = 3.5,
  label_overrides = stats::setNames(lapply(names(polygons), function(label) {
    list(text = strsplit(label, " · ", fixed = TRUE)[[1]][1])
  }), names(polygons)),
  source = "Brunner, Jaeggli, Nievergelt and Peyer (1997), Kartieren und Beurteilen von Landwirtschaftsboeden, Schriftenreihe der FAL 24, section 3.5, Tables 3.5a/3.5b and Figure 3.5a (PDF pages 34-35); 13 mineral fine-earth texture classes. This is the FAL 1997 view, not the separate ten-class Zurich package variant.",
  source_url = "https://ira.agroscope.ch/en-US/publication/17770",
  fractions = "Mass percentages of mineral fine earth (<2 mm), excluding organic matter and coarse fragments: sand 0.05–2 mm; silt 0.002–0.05 mm; clay <0.002 mm. The three mineral fractions must total 100%. This view does not assign organic, coarse-fragment or land-suitability classes. Switching systems does not convert laboratory fractions."
)
