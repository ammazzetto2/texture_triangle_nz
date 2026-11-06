# Keep all layers in the same fraction units and inherit the ternary mapping.
# Explicit z mappings on individual ggplot2 layers generate spurious warnings.
build_soil_plot <- function(samples, system, text_scale = 1, show_labels = TRUE,
                            selected_row = NULL, avoid_overlap = FALSE) {
  definition <- classification_definition(system)
  polygon_data <- definition$data
  labels <- polygon_data |>
    dplyr::group_by(Label) |>
    dplyr::summarise(dplyr::across(c(Sand, Clay, Silt), mean), .groups = "drop")
  labels$angle <- 0
  labels$font_size <- definition$label_size
  labels$display_label <- labels$Label
  label_keys <- canonical_texture_label(labels$Label)
  for (key in names(definition$label_overrides)) {
    rows <- which(label_keys == key)
    override <- definition$label_overrides[[key]]
    if (!is.null(override$text)) labels$display_label[rows] <- override$text
    if (!is.null(override$angle)) labels$angle[rows] <- override$angle
    if (!is.null(override$size)) labels$font_size[rows] <- override$size
    if (!is.null(override$sand)) {
      labels$Sand[rows] <- override$sand / 100
      labels$Clay[rows] <- override$clay / 100
      labels$Silt[rows] <- 1 - labels$Sand[rows] - labels$Clay[rows]
    }
  }
  points <- data.frame(Sand = samples$sand / 100, Clay = samples$clay / 100,
                       Silt = samples$silt / 100, soil = samples$soil)
  # Keep labels near sand/silt corners directed into the triangle.
  points$hjust <- ifelse(points$Sand > 0.8, 0, ifelse(points$Silt > 0.8, 1, 0.5))
  points$vjust <- ifelse(points$Clay < 0.1, -0.8, 1.5)
  outline <- data.frame(Sand = c(0, 1, 0, 0), Clay = c(0, 0, 1, 0),
                        Silt = c(1, 0, 0, 1))
  class_names <- unique(polygon_data$Label)
  colours <- stats::setNames(
    unname(definition$colours[canonical_texture_label(class_names)]), class_names)
  labels$font_size <- labels$font_size * text_scale
  label_points <- if (show_labels) points else points[FALSE, ]
  selected <- points[FALSE, ]
  if (length(selected_row) == 1L && is.finite(selected_row) &&
      selected_row >= 1L && selected_row <= nrow(points)) {
    selected <- points[selected_row, , drop = FALSE]
    if (show_labels) label_points <- points[-selected_row, , drop = FALSE]
  }
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
                      position = "identity", size = 3.5 * text_scale, colour = "#963e28",
                      check_overlap = avoid_overlap) +
    ggplot2::geom_path(data = outline, linewidth = 0.7, colour = "#4a554c") +
    ggplot2::geom_point(data = selected, size = 6, shape = 21, stroke = 1.4,
                       fill = NA, colour = "#173f70") +
    ggplot2::geom_text(data = selected, ggtern::aes(label = soil, hjust = hjust, vjust = vjust),
                      position = "identity", size = 4 * text_scale, fontface = "bold", colour = "#173f70") +
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
