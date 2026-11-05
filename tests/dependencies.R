# Run from the repository root: Rscript --vanilla tests/dependencies.R
# Simulate package availability without downloading packages or changing R's
# actual library paths, so installation and failure paths can run offline.
env <- new.env(parent = baseenv())
sys.source("R/dependencies.R", envir = env)
installed <- "shiny"
calls <- list()
paths <- character()
env$.libPaths <- function(new) {
  if (!missing(new)) paths <<- new
  paths
}
env$requireNamespace <- function(package, quietly) package %in% installed
env$install.packages <- function(pkgs, lib, repos) {
  calls[[length(calls) + 1L]] <<- list(pkgs = pkgs, lib = lib, repos = repos)
  installed <<- c(installed, pkgs)
}
library <- tempfile("soil-library-")
env$ensure_project_dependencies(c("shiny", "pracma"), library = library)
stopifnot(dir.exists(library), length(calls) == 1L,
          identical(calls[[1]]$pkgs, "pracma"),
          identical(paths[1], normalizePath(library)),
          identical(calls[[1]]$lib, normalizePath(library)),
          identical(calls[[1]]$repos, "https://cloud.r-project.org"))
env$ensure_project_dependencies(c("shiny", "pracma"), library = library)
stopifnot(length(calls) == 1L) # No reinstall when packages are available.

installed <- character()
env$install.packages <- function(...) invisible(NULL)
error <- tryCatch({
  env$ensure_project_dependencies("pracma", library = library)
  NULL
}, error = conditionMessage)
stopifnot(grepl("still unavailable: pracma", error, fixed = TRUE))
env$install.packages <- function(...) stop("Download failed")
error <- tryCatch({
  env$ensure_project_dependencies("pracma", library = library)
  NULL
}, error = conditionMessage)
stopifnot(grepl("Package installation failed: Download failed", error, fixed = TRUE))
unlink(library, recursive = TRUE)
cat("Dependency setup checks: PASS\n")
