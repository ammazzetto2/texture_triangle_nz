# Exact compositions only: nearby points retain their individual coordinates.
coincident_sample_groups <- function(samples) {
  samples$row <- seq_len(nrow(samples))
  samples |>
    dplyr::group_by(sand, silt, clay) |>
    dplyr::summarise(count = dplyr::n(), rows = list(row), .groups = "drop") |>
    dplyr::filter(count > 1L)
}

# Lay out labels in physical units on the actual graphics device, so the same
# spacing works in the responsive chart, enlarged view, and high-resolution PNG.
soil_label_grob <- function(data, triangle, class_labels, points, avoid_overlap) {
  width <- grid::convertWidth(grid::unit(1, "npc"), "mm", valueOnly = TRUE)
  height <- grid::convertHeight(grid::unit(1, "npc"), "mm", valueOnly = TRUE)
  triangle <- cbind(triangle$x * width, triangle$y * height)
  points <- cbind(points$x * width, points$y * height)
  boxes <- matrix(numeric(), ncol = 4)
  for (i in seq_len(nrow(class_labels))) {
    label <- grid::textGrob(class_labels$display_label[i], rot = class_labels$angle[i],
      gp = grid::gpar(fontsize = class_labels$font_size[i] * 72.27 / 25.4))
    half_width <- grid::convertWidth(grid::grobWidth(label), "mm", valueOnly = TRUE) / 2
    half_height <- grid::convertHeight(grid::grobHeight(label), "mm", valueOnly = TRUE) / 2
    x <- class_labels$x[i] * width
    y <- class_labels$y[i] * height
    boxes <- rbind(boxes, c(x - half_width, x + half_width, y - half_height, y + half_height))
  }
  lines <- labels <- list()
  angles <- c(pi / 2, -pi / 2, 0, pi, pi / 4, 3 * pi / 4, -pi / 4, -3 * pi / 4)
  offsets <- expand.grid(angle = angles, distance = c(0, 3, 7, 12, 20, 30))
  for (i in seq_len(nrow(data))) {
    name <- trimws(gsub("[[:space:]]+", " ", data$label[i]))
    if (nchar(name, type = "width") > 32) name <- paste0(strtrim(name, 29), "...")
    gp <- grid::gpar(col = data$colour[i], fontsize = data$size[i] * 72.27 / 25.4,
      fontface = data$fontface[i], fontfamily = "sans")
    label <- grid::textGrob(name, gp = gp)
    # Fit even unbroken names on narrow screens. Full names remain in Results
    # and in the selected-sample summary above the chart.
    while (grid::convertWidth(grid::grobWidth(label), "mm", valueOnly = TRUE) > width * 0.42 &&
           nchar(name) > 4) {
      name <- paste0(substr(sub("\\.\\.\\.$", "", name), 1, nchar(name) - 4), "...")
      label <- grid::textGrob(name, gp = gp)
    }
    half_width <- grid::convertWidth(grid::grobWidth(label), "mm", valueOnly = TRUE) / 2 + 1
    half_height <- grid::convertHeight(grid::grobHeight(label), "mm", valueOnly = TRUE) / 2 + 0.7
    x <- data$x[i] * width
    y <- data$y[i] * height
    candidates <- cbind(x + sign(round(cos(offsets$angle), 8)) * (half_width + 2 + offsets$distance),
                        y + sign(round(sin(offsets$angle), 8)) * (half_height + 2 + offsets$distance))
    candidates <- rbind(candidates, colMeans(triangle))
    candidate_boxes <- cbind(candidates[, 1] - half_width, candidates[, 1] + half_width,
                             candidates[, 2] - half_height, candidates[, 2] + half_height)
    # Every corner of the label must lie inside the triangle's three edges.
    inside <- rep(TRUE, nrow(candidates))
    for (edge in seq_len(3)) {
      a <- triangle[edge, ]
      b <- triangle[edge %% 3 + 1, ]
      centre <- colMeans(triangle)
      direction <- sign((b[1] - a[1]) * (centre[2] - a[2]) - (b[2] - a[2]) * (centre[1] - a[1]))
      for (corner in list(c(1, 3), c(1, 4), c(2, 3), c(2, 4))) {
        inside <- inside & direction * ((b[1] - a[1]) * (candidate_boxes[, corner[2]] - a[2]) -
          (b[2] - a[2]) * (candidate_boxes[, corner[1]] - a[1])) >= 0
      }
    }
    candidates <- candidates[inside, , drop = FALSE]
    candidate_boxes <- candidate_boxes[inside, , drop = FALSE]
    if (!nrow(candidates)) next
    collisions <- integer(nrow(candidates))
    if (avoid_overlap) {
      collisions <- vapply(seq_len(nrow(candidates)), function(j) {
        box <- candidate_boxes[j, ]
        sum(box[1] < boxes[, 2] + 0.8 & box[2] > boxes[, 1] - 0.8 &
            box[3] < boxes[, 4] + 0.8 & box[4] > boxes[, 3] - 0.8) +
          sum(points[, 1] > box[1] - 2 & points[, 1] < box[2] + 2 &
              points[, 2] > box[3] - 2 & points[, 2] < box[4] + 2)
      }, integer(1))
    }
    if (avoid_overlap && !data$required[i] && all(collisions > 0)) next
    distance <- rowSums((candidates - matrix(c(x, y), nrow(candidates), 2, byrow = TRUE)) ^ 2)
    chosen <- order(collisions, distance)[1]
    box <- candidate_boxes[chosen, ]
    position <- candidates[chosen, ]
    boxes <- rbind(boxes, box)
    lines[[length(lines) + 1L]] <- grid::segmentsGrob(x0 = x, y0 = y,
      x1 = max(box[1], min(box[2], x)), y1 = max(box[3], min(box[4], y)),
      default.units = "mm", gp = grid::gpar(col = data$colour[i], lwd = 0.7))
    label$x <- grid::unit(position[1], "mm")
    label$y <- grid::unit(position[2], "mm")
    labels[[length(labels) + 1L]] <- grid::grobTree(
      grid::roundrectGrob(x = position[1], y = position[2], width = 2 * half_width,
        height = 2 * half_height, default.units = "mm", r = grid::unit(0.6, "mm"),
        gp = grid::gpar(fill = "#FFFFFFE6", col = NA)), label)
  }
  # Selected samples are first in the layout and last in the drawing order.
  grid::gTree(children = do.call(grid::gList, c(lines, rev(labels))))
}

soil_label_layer <- function(data, class_labels, points, avoid_overlap) {
  # An anonymous GeomText extension retains ggtern's approved geometry class.
  geom <- ggplot2::ggproto(NULL, ggplot2::GeomText,
    draw_panel = function(data, panel_params, coord, na.rm = FALSE, avoid_overlap = TRUE) {
      transform <- function(values) {
        names(values)[match(c("Sand", "Clay", "Silt"), names(values))] <- c("x", "y", "z")
        coord$transform(values, panel_params)
      }
      triangle <- transform(data.frame(Sand = c(0, 1, 0), Clay = c(0, 0, 1), Silt = c(1, 0, 0)))
      transformed <- coord$transform(data, panel_params)
      transformed$required <- data$fontface == "bold"
      grid::recordGrob(grid::grid.draw(layout(data, triangle, class_labels, points, avoid_overlap)),
        list(layout = soil_label_grob, data = transformed, triangle = triangle,
             class_labels = transform(class_labels), points = transform(points), avoid_overlap = avoid_overlap))
    })
  ggplot2::layer(data = data, mapping = ggtern::aes(label = soil, size = font_size,
    colour = I(colour), fontface = fontface), geom = geom, stat = "identity", position = "identity",
    params = list(avoid_overlap = avoid_overlap))
}

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
  groups <- coincident_sample_groups(samples)
  counts <- data.frame(Sand = groups$sand / 100, Clay = groups$clay / 100,
                       Silt = groups$silt / 100, label = sprintf("%d samples", groups$count))
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
  # A shared position gets one count label. Selected samples still show their name.
  shared_rows <- unlist(groups$rows, use.names = FALSE)
  label_points <- label_points[!rownames(label_points) %in% as.character(shared_rows), , drop = FALSE]
  names(counts)[4] <- "soil"
  chart_labels <- rbind(selected, counts, label_points)
  chart_labels$font_size <- c(rep(4, nrow(selected)), rep(3.2, nrow(counts)), rep(3.5, nrow(label_points))) * text_scale
  chart_labels$fontface <- c(rep("bold", nrow(selected) + nrow(counts)), rep("plain", nrow(label_points)))
  chart_labels$colour <- c(rep("#173f70", nrow(selected)), rep("#963e28", nrow(counts) + nrow(label_points)))
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
    ggplot2::geom_path(data = outline, linewidth = 0.7, colour = "#4a554c") +
    ggplot2::geom_point(data = selected, size = 6, shape = 21, stroke = 1.4,
                       fill = NA, colour = "#173f70") +
    soil_label_layer(chart_labels, labels, points, avoid_overlap) +
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
