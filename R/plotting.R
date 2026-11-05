# Keep all layers in the same fraction units and inherit the ternary mapping.
# Explicit z mappings on individual ggplot2 layers generate spurious warnings.
build_soil_plot <- function(samples, system) {
  polygon_data <- switch(system,
    "New Zealand" = nz_data,
    "USDA" = usda_data,
    "Australian" = australian_data,
    stop("Unknown classification system: ", system, call. = FALSE)
  )
  labels <- polygon_data |>
    dplyr::group_by(Label) |>
    dplyr::summarise(dplyr::across(c(Sand, Clay, Silt), mean), .groups = "drop")
  labels$angle <- ifelse(labels$Label == "Loamy Sand" & system == "USDA", 330, 0)
  labels$font_size <- if (system == "Australian") 3.5 else 4
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
  ggtern::ggtern(polygon_data, ggtern::aes(x = Sand, y = Clay, z = Silt)) +
    ggplot2::geom_polygon(ggtern::aes(fill = Label, group = Label),
                          alpha = 0.4, linewidth = 0.6, colour = "black") +
    # ggplot2 4 defaults to position_nudge(), which ggtern removes. Explicit
    # identity positions keep both class and sample text layers in the plot.
    ggplot2::geom_text(data = labels, ggtern::aes(label = Label, angle = angle, size = font_size),
                      position = "identity",
                      colour = "black") +
    ggplot2::geom_point(data = points, size = 3.5, colour = "red") +
    ggplot2::geom_text(data = points, ggtern::aes(label = soil, hjust = hjust, vjust = vjust),
                      position = "identity", size = 3.5, colour = "red") +
    ggplot2::geom_path(data = outline, linewidth = 1, colour = "black") +
    ggtern::theme_nogrid() +
    ggtern::theme_showarrows() +
    ggtern::theme_nolatex() +
    ggtern::theme_hidetitles() +
    ggplot2::theme(tern.axis.clockwise = system != "New Zealand",
                  tern.axis.arrow = ggplot2::element_line(colour = "black", linewidth = 0.8),
                  tern.axis.text = ggplot2::element_text(size = 11, colour = "black"),
                  tern.axis.arrow.text = ggplot2::element_text(size = 12),
                  legend.position = "none",
                  plot.margin = ggplot2::margin(25, 45, 25, 45)) +
    ggtern::scale_T_continuous(breaks = seq(0.1, 1, by = 0.1)) +
    ggtern::scale_L_continuous(breaks = seq(0.1, 1, by = 0.1)) +
    ggtern::scale_R_continuous(breaks = seq(0.1, 1, by = 0.1)) +
    ggplot2::scale_size_identity() +
    ggplot2::labs(x = "Sand (%)", y = "Clay (%)", z = "Silt (%)")
}
