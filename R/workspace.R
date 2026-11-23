# Versioned JSON stores measurements and settings. Results are recalculated.
workspace_settings <- function(system, show_labels, avoid_overlap, selected_row = NULL) {
  list(classification_system = system, chart = list(
    show_labels = show_labels, avoid_overlap = avoid_overlap, selected_row = selected_row))
}

write_workspace <- function(path, samples, settings) {
  jsonlite::write_json(list(
    format = "soil-texture-workspace", version = 1L,
    samples = samples, classification_system = settings$classification_system,
    chart = settings$chart
  ), path, auto_unbox = TRUE, dataframe = "rows", null = "null", digits = NA, pretty = TRUE)
}

read_workspace <- function(path) {
  data <- tryCatch(jsonlite::fromJSON(path, simplifyVector = FALSE),
    error = function(e) stop("Could not read the workspace JSON file.", call. = FALSE))
  fields_match <- function(value, fields) {
    is.list(value) && !anyDuplicated(names(value)) && length(value) == length(fields) &&
      setequal(names(value), fields)
  }
  scalar <- function(value, type) {
    length(value) == 1L && !is.na(value) && switch(type,
      text = is.character(value), number = is.numeric(value) && is.finite(value),
      flag = is.logical(value))
  }
  fail <- function(message) stop(message, call. = FALSE)
  if (!fields_match(data, c("format", "version", "samples", "classification_system", "chart")) ||
      !identical(data$format, "soil-texture-workspace")) {
    fail("Choose a Soil Texture workspace file.")
  }
  if (!scalar(data$version, "number") || data$version != 1) {
    fail("This workspace version is unsupported.")
  }
  if (!scalar(data$classification_system, "text") ||
      !data$classification_system %in% names(classification_systems)) {
    fail("The workspace uses an unavailable classification system.")
  }
  if (!is.list(data$samples) || !is.null(names(data$samples))) {
    fail("Workspace samples must be a list of sample records.")
  }
  samples <- data.frame(soil = character(), sand = numeric(), silt = numeric(), clay = numeric())
  if (length(data$samples)) {
    valid_rows <- vapply(data$samples, function(row) {
      fields_match(row, c("soil", "sand", "silt", "clay")) &&
        scalar(row$soil, "text") &&
        all(vapply(row[c("sand", "silt", "clay")], scalar, logical(1), type = "number"))
    }, logical(1))
    if (!all(valid_rows)) fail("Each sample needs a name and three numeric percentages.")
    samples <- as.data.frame(lapply(names(samples), function(column) {
      vapply(data$samples, function(row) row[[column]],
        if (column == "soil") character(1) else numeric(1))
    }), col.names = names(samples), stringsAsFactors = FALSE)
    samples <- validate_soil_data(samples)
  }
  chart <- data$chart
  if (!fields_match(chart, c("show_labels", "avoid_overlap", "selected_row")) ||
      !scalar(chart$show_labels, "flag") || !scalar(chart$avoid_overlap, "flag")) {
    fail("Workspace chart settings must contain valid label options.")
  }
  selected <- chart$selected_row
  if (!is.null(selected) && (!scalar(selected, "number") || selected != floor(selected) ||
      selected < 1 || selected > nrow(samples))) {
    fail("The highlighted sample does not exist in this workspace.")
  }
  list(samples = samples, settings = workspace_settings(
    data$classification_system, chart$show_labels, chart$avoid_overlap, selected))
}
