# One registry drives selection, plotting, classification, and source details.
# Source classification_data.R and brazil_data.R before this file.
classification_systems <- list(
  "New Zealand" = list(data = nz_data, display = "New Zealand", clockwise = FALSE),
  "USDA" = list(data = usda_data, display = "USDA", clockwise = TRUE),
  "Australian" = list(data = australian_data, display = "Australian", clockwise = TRUE),
  "Brazil (SiBCS 2025, 13 classes)" = list(
    data = brazil_data, display = "Brazil · 13 classes", clockwise = TRUE,
    source = "SiBCS, 6th edition (2025), Figure 1.1, printed page 55",
    source_url = "https://www.infoteca.cnptia.embrapa.br/handle/doc/1176834",
    fractions = "Sand 0.05–2 mm; silt 0.002–0.05 mm; clay <0.002 mm."
  ),
  "Brazil (SiBCS 2025, 5 groups)" = list(
    data = brazil_groups_data, display = "Brazil · 5 groups", clockwise = TRUE,
    source = "SiBCS, 6th edition (2025), Figure 1.2 and texture-group definitions, printed pages 55–56",
    source_url = "https://www.infoteca.cnptia.embrapa.br/handle/doc/1176834",
    fractions = "Sand 0.05–2 mm; silt 0.002–0.05 mm; clay <0.002 mm."
  )
)

classification_definition <- function(system) {
  if (length(system) != 1L || is.na(system) || !system %in% names(classification_systems)) {
    stop("Unknown classification system: ", paste(system, collapse = ", "), call. = FALSE)
  }
  classification_systems[[system]]
}

classification_choices <- function() {
  stats::setNames(names(classification_systems),
    vapply(classification_systems, function(definition) definition$display, character(1)))
}
