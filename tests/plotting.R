# Run from the repository root: Rscript --vanilla tests/plotting.R
source("R/dependencies.R")
ensure_project_dependencies()
# Grob layout can request a device before explicit drawing. Keep that scratch
# device in memory instead of creating an Rplots.pdf in the repository.
options(device = function(...) grDevices::pdf(file = NULL))
source("R/classification_data.R")
source("R/plotting.R")

text_labels <- function(grob) {
  labels <- if (inherits(grob, "text")) as.character(grob$label) else character()
  children <- c(grob$grobs, as.list(grob$children))
  c(labels, unlist(lapply(children, text_labels), use.names = FALSE))
}

samples <- read.csv("examples/soil_samples.csv")
samples$soil <- c("Sample A", "Boundary sample", "Sand sample")
for (system in c("New Zealand", "USDA", "Australian")) {
  for (points in list(samples, samples[FALSE, ])) {
    diagnostics <- character()
    withCallingHandlers({
      plot <- build_soil_plot(points, system)
      built <- ggtern::ggplot_build(plot)
      grob <- ggtern::ggplotGrob(plot)
      rendered_labels <- text_labels(grob)
      clean <- function(x) gsub("[[:space:]]+", " ", x)
      expected_classes <- unique(plot$data$Label)
      stopifnot(all(clean(expected_classes) %in% clean(rendered_labels)),
                all(points$soil %in% rendered_labels),
                all(c("Sand (%)", "Silt (%)", "Clay (%)") %in% rendered_labels),
                nrow(built$data[[3]]) == nrow(points),
                nrow(built$data[[4]]) == nrow(points))
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

app_env <- new.env()
source("soil_triangle.R", local = app_env)
shiny::testServer(app_env$server, {
  soil_data(samples)
  for (system in c("New Zealand", "USDA", "Australian")) {
    session$setInputs(dataset = system, dataset_upload = system)
    plot_output <- output$ternaryPlot
    stopifnot(!is.null(plot_output))
  }
})
cat("Shiny plot integration checks: PASS\n")
