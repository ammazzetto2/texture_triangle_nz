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

# Shared CSV reader: preserve identifiers and reject malformed records before mapping.
read_soil_table <- function(path, format = c("samples", "results")) {
  format <- match.arg(format)
  data <- tryCatch(withCallingHandlers({
    counts <- count.fields(path, sep = ",", quote = '"', comment.char = "", blank.lines.skip = TRUE)
    counts <- counts[!is.na(counts)]
    if (length(counts) && any(counts != counts[1])) stop("Inconsistent field counts.")
    read.csv(path, check.names = FALSE, colClasses = "character", na.strings = character(),
             row.names = NULL, fill = FALSE)
    },
    warning = function(w) stop(conditionMessage(w), call. = FALSE)),
    error = function(e) stop("Could not read the CSV. Check comma separators, quotes, and the number of columns in each row.", call. = FALSE))
  if (anyDuplicated(names(data)) || any(!nzchar(trimws(names(data)))))
    stop("Column names must be nonblank and unique.", call. = FALSE)
  if (!nrow(data)) stop("Add at least one sample to the CSV.", call. = FALSE)
  if (identical(format, "results") && !setequal(names(data),
      c("soil", "sand", "silt", "clay", "classification", "classification_system",
        "classification_status", "classification_candidates"))) {
    stop("Downloaded results must contain exactly these columns: soil, sand, silt, clay, classification, classification_system, classification_status, classification_candidates. Choose Samples to map another CSV layout.", call. = FALSE)
  }
  data
}

# Both direct CSV reads and mapped uploads use the same text-to-number conversion.
parse_soil_values <- function(data) {
  data$soil <- trimws(data$soil)
  for (column in c("sand", "silt", "clay")) {
    data[[column]] <- suppressWarnings(as.numeric(data[[column]]))
  }
  data
}

read_soil_csv <- function(path, format = c("samples", "results")) {
  format <- match.arg(format)
  data <- read_soil_table(path, format)
  required <- c("soil", "sand", "silt", "clay")
  if (format == "samples" && !setequal(names(data), required)) {
    stop("Use exactly these columns: soil, sand, silt, clay (no extra columns).", call. = FALSE)
  }
  # Recalculate saved classifications from the measurements on import.
  samples <- validate_soil_data(parse_soil_values(data[, required, drop = FALSE]))
  # Preserve integer columns returned by the original direct reader.
  for (column in required[-1]) {
    if (is.integer(type.convert(data[[column]], as.is = TRUE))) {
      samples[[column]] <- as.integer(samples[[column]])
    }
  }
  samples
}
