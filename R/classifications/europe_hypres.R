# European Soil Map / HYPRES: five mineral texture classes.
# Numerical limits: Moeys et al., soiltexture 1.5.3, HYPRES.TT.
# HYPRES background and fractions: European Commission ESDAC metadata.
# Source revision and scope: docs/classifications/europe_hypres.md.
# Coordinates are (sand %, clay %) pairs; shared edges retain the app policy.
list(
  id = "Europe (HYPRES.TT 1.5.3, 5 classes)",
  display = "Europe · HYPRES 5 classes",
  order = 120,
  clockwise = TRUE,
  data = texture_polygons(list(
    "Very fine" = c(0, 60, 0, 100, 40, 60),
    "Fine" = c(65, 35, 40, 60, 0, 60, 0, 35),
    "Medium" = c(82, 18, 65, 35, 15, 35, 15, 0, 65, 0, 65, 18),
    "Medium fine" = c(15, 0, 15, 35, 0, 35, 0, 0),
    "Coarse" = c(100, 0, 82, 18, 65, 18, 65, 0)
  )),
  colours = c("Very fine" = "#b9a28b", "Fine" = "#d8c8b1",
              "Medium" = "#cbd5ba", "Medium fine" = "#d8e2d9", "Coarse" = "#efe4c7"),
  label_size = 4,
  label_overrides = list("Medium fine" = list(text = "Medium\nfine")),
  source = "European Soil Map / HYPRES five mineral texture classes; European Commission ESDAC metadata; numerical transcription: Moeys et al., soiltexture 1.5.3, HYPRES.TT",
  source_url = "https://esdac.jrc.ec.europa.eu/ESDB_Archive/ESDBv2/popup/hy_meta.htm",
  fractions = "Fine earth <2 mm: sand 0.05–2 mm; silt 0.002–0.05 mm; clay <0.002 mm. This view supplies five mineral texture classes only, not organic horizons, topsoil/subsoil classes or hydraulic-property estimates. Switching views does not convert laboratory fractions."
)
