# Check that --vanilla startup activates renv before checking dependencies.
env <- new.env(parent = baseenv())
sys.source("R/dependencies.R", envir = env)
activated <- FALSE
env$source <- function(file) {
  stopifnot(identical(file, "renv/activate.R"))
  activated <<- TRUE
}
env$requireNamespace <- function(package, quietly) {
  stopifnot(activated)
  package == "shiny"
}
env$.libPaths <- function() "project-library"
stopifnot(identical(env$ensure_project_dependencies("shiny"), "project-library"))
error <- tryCatch({
  env$ensure_project_dependencies(c("shiny", "pracma"))
  NULL
}, error = conditionMessage)
stopifnot(grepl("Project packages are unavailable: pracma", error, fixed = TRUE),
          grepl("renv::restore()", error, fixed = TRUE))

# Exercise the real activation path used by the app and other test scripts.
source("R/dependencies.R")
project_library <- ensure_project_dependencies()
stopifnot(identical(normalizePath(project_library), normalizePath(renv::paths$library())))
cat("Dependency setup: locked library activation and restore guidance PASS\n")
