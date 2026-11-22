# Read as text so mapped sample identifiers retain leading zeroes and literal NA.
read_upload_table <- function(path, format = "samples") {
  format <- match.arg(format, c("samples", "results"))
  data <- read_soil_table(path, format)
  if (ncol(data) < 4L) stop("Include at least four columns to map to soil, sand, silt and clay.", call. = FALSE)
  data
}

default_upload_mapping <- function(data) {
  required <- c("soil", "sand", "silt", "clay")
  stats::setNames(vapply(required, function(column) {
    matches <- which(tolower(trimws(names(data))) == column)
    if (length(matches) == 1L) names(data)[matches] else ""
  }, character(1)), required)
}

inspect_upload <- function(data, mapping, tolerance = 1e-8) {
  required <- c("soil", "sand", "silt", "clay")
  if (!identical(names(mapping), required) || anyNA(mapping) ||
      any(!mapping %in% names(data)) || anyDuplicated(mapping)) {
    stop("Choose a different source column for each of soil, sand, silt and clay.", call. = FALSE)
  }
  raw <- data[, unname(mapping), drop = FALSE]
  names(raw) <- required
  samples <- parse_soil_values(raw)
  issues <- data.frame(row = integer(), field = character(), value = character(), message = character())
  add_issue <- function(bad, field, values, message) {
    rows <- which(bad)
    if (length(rows)) issues <<- rbind(issues, data.frame(row = rows, field = field,
      value = as.character(values[rows]), message = rep(message, length.out = length(rows))))
  }
  add_issue(is.na(samples$soil) | !nzchar(samples$soil), "soil", raw$soil, "Enter a sample name.")
  valid <- rep(TRUE, nrow(samples))
  for (column in required[-1]) {
    values <- samples[[column]]
    bad <- !is.finite(values) | values < 0 | values > 100
    add_issue(bad, column, raw[[column]], "Use a numeric percentage from 0 to 100 (decimal point, no % sign).")
    valid <- valid & !bad
  }
  totals <- rowSums(samples[required[-1]])
  bad_total <- valid & abs(totals - 100) > tolerance
  add_issue(bad_total, "total", totals, "Must total 100%. Check rounding in the source values; no automatic normalization is applied.")
  list(samples = samples, preview = raw, issues = issues[order(issues$row, issues$field), ],
       ignored = setdiff(names(data), unname(mapping)))
}

remaining_percentage <- function(values, component) {
  if (length(component) != 1L || !component %in% c("sand", "silt", "clay"))
    stop("Choose the percentage to calculate.", call. = FALSE)
  others <- values[setdiff(c("sand", "silt", "clay"), component)]
  if (length(others) != 2L || any(!is.finite(others)) || any(others < 0 | others > 100) || sum(others) > 100)
    stop("The other two percentages must be between 0 and 100 and total no more than 100%.", call. = FALSE)
  100 - sum(others)
}
