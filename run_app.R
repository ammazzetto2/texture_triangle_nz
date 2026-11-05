# Run from the repository root with Rscript run_app.R or source("run_app.R").
source("R/dependencies.R", local = TRUE)
ensure_project_dependencies()
shiny::runApp("soil_triangle.R", launch.browser = interactive())
