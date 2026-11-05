# Validate both manual entries and CSV uploads before changing session data.
validate_soil_data <- function(data, tolerance = 1e-8) {
  required <- c("soil", "sand", "silt", "clay")
  fail <- function(message) stop(message, call. = FALSE)
  if (!is.data.frame(data)) fail("Expected a table of soil samples.")
  if (anyDuplicated(names(data))) fail("Column names must be unique.")
  if (!setequal(names(data), required)) {
    fail("Use exactly these columns: soil, sand, silt, clay (no extra columns).")
  }
  if (nrow(data) == 0L) fail("Add at least one sample.")
  data <- data[, required, drop = FALSE]
  rows <- function(bad) paste(which(bad), collapse = ", ")
  sample_names <- trimws(as.character(data$soil))
  bad <- is.na(data$soil) | is.na(sample_names) | !nzchar(sample_names)
  if (any(bad)) fail(paste0("Sample names are required. Sample row(s): ", rows(bad), "."))
  for (column in required[-1]) {
    values <- data[[column]]
    if (!is.numeric(values)) fail(paste0("Column '", column, "' must contain numeric percentages."))
    bad <- !is.finite(values) | values < 0 | values > 100
    if (any(bad)) {
      fail(paste0("Column '", column, "' must contain finite values from 0 to 100. Sample row(s): ", rows(bad), "."))
    }
  }
  bad <- abs(rowSums(data[required[-1]]) - 100) > tolerance
  if (any(bad)) fail(paste0("Sand, silt, and clay must total 100%. Sample row(s): ", rows(bad), "."))
  data$soil <- sample_names
  data
}

read_soil_csv <- function(path) {
  # Treat parser warnings (for example, an unterminated quoted field) as errors.
  data <- tryCatch(
    withCallingHandlers(
      read.csv(path, check.names = FALSE, stringsAsFactors = FALSE,
               row.names = NULL, fill = FALSE),
      warning = function(w) stop(conditionMessage(w), call. = FALSE)
    ),
    error = function(e) stop(
      "Could not read the CSV. Check comma separators, quotes, and the number of fields in each row.",
      call. = FALSE
    )
  )
  validate_soil_data(data)
}
