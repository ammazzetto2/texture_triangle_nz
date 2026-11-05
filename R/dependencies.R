# Keep the app's direct dependencies in one place. Missing packages and their
# dependencies are installed locally; existing usable packages are reused.
ensure_project_dependencies <- function(
    packages = c("shiny", "ggplot2", "ggtern", "dplyr", "pracma"),
    library = ".R-library",
    repos = "https://cloud.r-project.org") {
  if (!dir.exists(library) && !dir.create(library, recursive = TRUE)) {
    stop("Could not create the project package library: ", library, call. = FALSE)
  }
  library <- normalizePath(library, mustWork = TRUE)
  .libPaths(c(library, .libPaths()))
  available <- function() vapply(packages, requireNamespace, logical(1), quietly = TRUE)
  missing <- packages[!available()]
  if (length(missing)) {
    message("Installing missing R packages into ", library, ": ",
            paste(missing, collapse = ", "))
    tryCatch(
      install.packages(missing, lib = library, repos = repos),
      error = function(e) stop(
        "Package installation failed: ", conditionMessage(e),
        ". Check your internet connection and library write permissions, then retry.",
        call. = FALSE
      )
    )
    # install.packages() can warn rather than throw when installation fails.
    missing <- packages[!available()]
    if (length(missing)) {
      stop("Packages are still unavailable: ", paste(missing, collapse = ", "),
           ". Check the installation messages, internet connection, and any required system build tools, then retry.",
           call. = FALSE)
    }
  }
  invisible(library)
}
