# Activate the locked project library even when R starts with --vanilla.
ensure_project_dependencies <- function(
    packages = c("shiny", "bslib", "ggplot2", "ggtern", "dplyr", "pracma")) {
  source("renv/activate.R")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop(
      "Project packages are unavailable: ", paste(missing, collapse = ", "),
      ". Run Rscript -e 'renv::restore()' from the repository root, then retry.",
      call. = FALSE
    )
  }
  invisible(.libPaths()[1])
}
