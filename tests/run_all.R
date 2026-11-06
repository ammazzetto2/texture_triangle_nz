# Run from the repository root: Rscript --vanilla tests/run_all.R
# Separate R sessions keep tests' graphics devices and options isolated.
scripts <- setdiff(list.files("tests", pattern = "\\.R$", full.names = TRUE), "tests/run_all.R")
for (script in scripts) {
  cat("Running", script, "\n")
  status <- system2(file.path(R.home("bin"), "Rscript"), c("--vanilla", shQuote(script)))
  if (status != 0L) stop(script, " failed with exit status ", status, call. = FALSE)
}
cat("All", length(scripts), "test scripts passed.\n")
