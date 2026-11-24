# Run from the repository root: Rscript --vanilla tests/plotting.R
source("R/dependencies.R")
ensure_project_dependencies()
# Grob layout can request a device before explicit drawing. Keep that scratch
# device in memory instead of creating an Rplots.pdf in the repository.
options(device = function(...) grDevices::pdf(file = NULL))
source("R/classification_systems.R")
source("R/plotting.R")

text_labels <- function(grob) {
  if (inherits(grob, "recordedGrob")) {
    grob <- do.call(grob$list$layout, grob$list[setdiff(names(grob$list), "layout")])
  }
  labels <- if (inherits(grob, "text")) as.character(grob$label) else character()
  children <- c(grob$grobs, as.list(grob$children))
  c(labels, unlist(lapply(children, text_labels), use.names = FALSE))
}

samples <- read.csv("examples/soil_samples.csv")
samples$soil <- c("Sample A", "Boundary sample", "Sand sample")
for (system in names(classification_systems)) {
  for (points in list(samples, samples[FALSE, ])) {
    diagnostics <- character()
    withCallingHandlers({
      plot <- build_soil_plot(points, system)
      built <- ggtern::ggplot_build(plot)
      grob <- ggtern::ggplotGrob(plot)
      rendered_labels <- text_labels(grob)
      clean <- function(x) gsub("-[[:space:]]+", "-", gsub("[[:space:]]+", " ", x))
      expected_classes <- unique(plot$data$Label)
      # Definition overrides may use short codes; full names stay in the key.
      definition <- classification_definition(system)
      expected_classes <- vapply(expected_classes, function(label) {
        text <- definition$label_overrides[[canonical_texture_label(label)]]$text
        if (is.null(text)) label else text
      }, character(1))
      stopifnot(all(clean(expected_classes) %in% clean(rendered_labels)),
                all(points$soil %in% rendered_labels),
                all(c("Sand (%)", "Silt (%)", "Clay (%)") %in% rendered_labels),
                nrow(built$data[[3]]) == nrow(points),
                nrow(built$data[[6]]) == nrow(points))
      # Complete drawing catches graphics-device errors beyond plot building.
      file <- tempfile(fileext = ".pdf")
      grDevices::pdf(file, width = 9, height = 8)
      tryCatch(grid::grid.draw(grob), finally = grDevices::dev.off())
      unlink(file)
    }, warning = function(w) {
      diagnostics <<- c(diagnostics, conditionMessage(w))
      invokeRestart("muffleWarning")
    }, message = function(m) {
      diagnostics <<- c(diagnostics, conditionMessage(m))
      invokeRestart("muffleMessage")
    })
    if (length(diagnostics)) stop(paste(diagnostics, collapse = "\n"))
  }
  cat(system, "plot labels and warning-free rendering: PASS\n")
}

# Hiding sample labels leaves sample points and class labels intact.
hidden <- ggtern::ggplot_build(build_soil_plot(samples, "New Zealand", show_labels = FALSE))
stopifnot(nrow(hidden$data[[3]]) == nrow(samples), nrow(hidden$data[[6]]) == 0L)

# Exercise the device-sized label layout at desktop and mobile sizes. Include
# nearby samples, every vertex, and an unbroken name that cannot wrap naturally.
crowded <- data.frame(soil = c("Field A", "Field B", "Field C", strrep("LongName", 20), "Silt", "Clay"),
  sand = c(50, 51, 49, 100, 0, 0), silt = c(25, 24, 26, 0, 100, 0), clay = c(25, 25, 25, 0, 0, 100))
for (system in names(classification_systems)) {
  plot <- build_soil_plot(crowded, system, avoid_overlap = TRUE, selected_row = 4)
  built <- ggtern::ggplot_build(plot)
  stopifnot(identical(built$data[[3]]$x, crowded$sand / 100),
    identical(built$data[[3]]$y, crowded$clay / 100),
    identical(built$data[[3]]$z, crowded$silt / 100))
  recording <- plot$layers[[6]]$geom$draw_panel(built$data[[6]],
    built$layout$panel_params[[1]], built$layout$coord, avoid_overlap = TRUE)
  for (width in c(70, 210)) {
    grid::pushViewport(grid::viewport(width = grid::unit(width, "mm"), height = grid::unit(width, "mm")))
    layout <- do.call(recording$list$layout, recording$list[setdiff(names(recording$list), "layout")])
    rendered <- text_labels(layout)
    stopifnot(any(grepl("^LongName.*\\.\\.\\.$", rendered)))
    if (system == "New Zealand" && width == 210) stopifnot(all(c("Field A", "Field B", "Field C") %in% rendered))
    # Independently convert each label rectangle's corners to barycentric
    # coordinates. Nonnegative fractions prove the complete box is in bounds.
    triangle <- recording$list$triangle
    inverse <- solve(rbind(triangle$x * width, triangle$y * width, 1))
    label_trees <- Filter(function(child) inherits(child, "gTree"), as.list(layout$children))
    occupied <- matrix(numeric(), ncol = 4)
    for (tree in label_trees) {
      box <- tree$children[[1]]
      x <- as.numeric(box$x)
      y <- as.numeric(box$y)
      half_width <- as.numeric(box$width) / 2
      half_height <- as.numeric(box$height) / 2
      corners <- expand.grid(x = x + c(-half_width, half_width), y = y + c(-half_height, half_height))
      stopifnot(all(inverse %*% rbind(t(corners), 1) >= -1e-10))
      stopifnot(!any(x - half_width < occupied[, 2] & x + half_width > occupied[, 1] &
        y - half_height < occupied[, 4] & y + half_height > occupied[, 3]))
      occupied <- rbind(occupied, c(x - half_width, x + half_width, y - half_height, y + half_height))
    }
    # The layout also draws successfully on the current device.
    grid::grid.draw(layout)
    grid::popViewport()
  }
}
cat("Label layout: nearby samples, all vertices, long names, mobile sizing and exact point positions PASS\n")

app_env <- new.env()
source("soil_triangle.R", local = app_env)
shiny::testServer(app_env$server, {
  soil_data(samples)
  for (system in names(classification_systems)) {
    session$setInputs(dataset = system)
    plot_output <- output$ternaryPlot
    stopifnot(!is.null(plot_output))
  }
})
cat("Shiny plot integration checks: PASS\n")
