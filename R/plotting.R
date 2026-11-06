# Keep all layers in the same fraction units and inherit the ternary mapping.
# Explicit z mappings on individual ggplot2 layers generate spurious warnings.
build_soil_plot <- function(samples, system, text_scale = 1, show_labels = TRUE) {
  definition <- classification_definition(system)
  polygon_data <- definition$data
  labels <- polygon_data |>
    dplyr::group_by(Label) |>
    dplyr::summarise(dplyr::across(c(Sand, Clay, Silt), mean), .groups = "drop")
  labels$angle <- ifelse(labels$Label == "Loamy Sand" & system == "USDA", 330, 0)
  labels$font_size <- if (system == "Australian") 3.5 else 4
  labels$display_label <- labels$Label
  if (startsWith(system, "Brazil")) {
    labels$font_size <- if (nrow(labels) == 13L) 3.5 else 4
    labels$display_label <- gsub("Franco-", "Franco-\n", labels$display_label, fixed = TRUE)
    labels$display_label[labels$Label == "Muito argilosa"] <- "Muito\nargilosa"
    labels$angle[labels$Label == "Areia franca"] <- 330
    if (nrow(labels) == 5L) labels$angle[labels$Label == "Siltosa"] <- 60
  }
  if (system == "Australian") {
    labels$angle[labels$Label %in% c("Sandy Clay", "Sandy Loam", "Sandy Clay Loam")] <- 60
    labels$angle[labels$Label == "Clay Loam"] <- 25
    labels$font_size[labels$Label == "Sandy Clay Loam"] <- 2.5
  }
  points <- data.frame(Sand = samples$sand / 100, Clay = samples$clay / 100,
                       Silt = samples$silt / 100, soil = samples$soil)
  # Keep labels near sand/silt corners directed into the triangle.
  points$hjust <- ifelse(points$Sand > 0.8, 0, ifelse(points$Silt > 0.8, 1, 0.5))
  points$vjust <- ifelse(points$Clay < 0.1, -0.8, 1.5)
  outline <- data.frame(Sand = c(0, 1, 0, 0), Clay = c(0, 0, 1, 0),
                        Silt = c(1, 0, 0, 1))
  palette <- c("Clay" = "#d8c8b1", "Loamy Clay" = "#c6d2ae",
    "Silt Clay" = "#c1d0d5", "Sandy Clay Loam" = "#e0c9a6",
    "Clay Loam" = "#d4c8a0", "Silt Loam" = "#cbd5ba",
    "Sandy Loam" = "#e8d7b7", "Sand" = "#efe4c7", "Loamy Sand" = "#dfd1a7",
    "Loamy Silt" = "#c5d7c5", "Silt" = "#d8e2d9", "Sandy Clay" = "#d3b49d",
    "Silty Clay" = "#c7cbd9", "Silty Clay Loam" = "#c6d1bd", "Loam" = "#dedab9",
    "Silty Loam" = "#cadcd4",
    "Muito argilosa" = "#b9a28b", "Argila" = "#d8c8b1",
    "Argilossiltosa" = "#c7cbd9", "Argiloarenosa" = "#d3b49d",
    "Francoargilosa" = "#d4c8a0", "Franco-argilossiltosa" = "#c6d1bd",
    "Franco-argiloarenosa" = "#e0c9a6", "Franca" = "#dedab9",
    "Francoarenosa" = "#e8d7b7", "Francossiltosa" = "#cbd5ba",
    "Silte" = "#d8e2d9", "Areia franca" = "#dfd1a7", "Areia" = "#efe4c7",
    "Argilosa" = "#d8c8b1", "Média" = "#dedab9", "Arenosa" = "#efe4c7",
    "Siltosa" = "#cadcd4")
  class_names <- unique(polygon_data$Label)
  colours <- stats::setNames(unname(palette[trimws(gsub("[[:space:]]+", " ", class_names))]), class_names)
  labels$font_size <- labels$font_size * text_scale
  label_points <- if (show_labels) points else points[FALSE, ]
  ggtern::ggtern(polygon_data, ggtern::aes(x = Sand, y = Clay, z = Silt)) +
    ggplot2::geom_polygon(ggtern::aes(fill = Label, group = Label),
                          linewidth = 0.45, colour = "#6a7369") +
    # ggplot2 4 defaults to position_nudge(), which ggtern removes. Explicit
    # identity positions keep both class and sample text layers in the plot.
    ggplot2::geom_text(data = labels, ggtern::aes(label = display_label, angle = angle, size = font_size),
                      position = "identity",
                      colour = "#25392f") +
    ggplot2::geom_point(data = points, size = 3.5, shape = 21, stroke = 0.7,
                       fill = "#a3452c", colour = "white") +
    ggplot2::geom_text(data = label_points, ggtern::aes(label = soil, hjust = hjust, vjust = vjust),
                      position = "identity", size = 3.5 * text_scale, colour = "#963e28") +
    ggplot2::geom_path(data = outline, linewidth = 0.7, colour = "#4a554c") +
    ggtern::theme_nogrid() +
    ggtern::theme_showarrows() +
    ggtern::theme_nolatex() +
    ggtern::theme_hidetitles() +
    ggplot2::theme(tern.axis.clockwise = definition$clockwise,
                  text = ggplot2::element_text(family = "sans", colour = "#25392f"),
                  tern.axis.arrow = ggplot2::element_line(colour = "#4a554c", linewidth = 0.6),
                  tern.axis.text = ggplot2::element_text(size = 11 * text_scale, colour = "#4a554c"),
                  # Move text outward from each arrow. The horizontal bottom
                  # axis needs the opposite justification to the sloping axes.
                  tern.axis.arrow.text = ggplot2::element_text(size = 12 * text_scale, vjust = 0),
                  tern.axis.arrow.text.L = ggplot2::element_text(vjust = if (definition$clockwise) 1 else 0),
                  tern.axis.arrow.text.R = ggplot2::element_text(vjust = if (definition$clockwise) 0 else 1),
                  legend.position = "none",
                  plot.background = ggplot2::element_rect(fill = "white", colour = NA),
                  tern.panel.expand = 0.16,
                  plot.margin = ggplot2::margin(6, 12, 8, 12)) +
    ggtern::scale_T_continuous(breaks = seq(0.1, 1, by = 0.1)) +
    ggtern::scale_L_continuous(breaks = seq(0.1, 1, by = 0.1)) +
    ggtern::scale_R_continuous(breaks = seq(0.1, 1, by = 0.1)) +
    ggplot2::scale_size_identity() +
    ggplot2::scale_fill_manual(values = colours) +
    ggplot2::labs(x = "Sand (%)", y = "Clay (%)", z = "Silt (%)")
}
