# System definitions are discovered from R/classifications/*.R. Each file returns
# one list; it is evaluated in its own environment to avoid global data names.
canonical_texture_label <- function(x) trimws(gsub("[[:space:]]+", " ", x))

# Convert named polygon vertices in (sand %, clay %) pairs to the shared schema.
texture_polygons <- function(vertices) {
  if (!is.list(vertices) || !length(vertices) || is.null(names(vertices)) ||
      anyNA(names(vertices)) || any(!nzchar(trimws(names(vertices)))) || anyDuplicated(names(vertices))) {
    stop("Polygon vertices must be a nonempty list with unique class names.", call. = FALSE)
  }
  data <- lapply(names(vertices), function(label) {
    values <- vertices[[label]]
    if (!is.numeric(values) || length(values) < 6L || length(values) %% 2L || any(!is.finite(values))) {
      stop("Polygon '", label, "' needs at least three finite (sand %, clay %) pairs.", call. = FALSE)
    }
    xy <- matrix(values, ncol = 2, byrow = TRUE)
    data.frame(Sand = xy[, 1] / 100, Clay = xy[, 2] / 100,
               Silt = (100 - xy[, 1] - xy[, 2]) / 100,
               Label = label, stringsAsFactors = FALSE)
  })
  do.call(rbind, data)
}

validate_classification_definition <- function(definition) {
  fail <- function(message) stop(message, call. = FALSE)
  scalar_text <- function(x) is.character(x) && length(x) == 1L && !is.na(x) && nzchar(trimws(x))
  scalar_number <- function(x) is.numeric(x) && length(x) == 1L && is.finite(x)
  required <- c("id", "display", "order", "clockwise", "data", "colours")
  if (!is.list(definition) || !all(required %in% names(definition))) {
    fail(paste("Definition requires:", paste(required, collapse = ", ")))
  }
  allowed <- c(required, "label_size", "label_overrides", "source", "source_url", "fractions", "definition_file", "category")
  if (anyNA(names(definition)) || anyDuplicated(names(definition)) ||
      any(!names(definition) %in% allowed)) fail("Definition contains duplicate or unknown fields.")
  if (!scalar_text(definition$id) || !scalar_text(definition$display)) fail("id and display must be nonempty strings.")
  if (!scalar_number(definition$order)) fail("order must be a finite number.")
  if (!is.logical(definition$clockwise) || length(definition$clockwise) != 1L || is.na(definition$clockwise)) {
    fail("clockwise must be TRUE or FALSE.")
  }
  if (is.null(definition$category)) definition$category <- "Current"
  if (!scalar_text(definition$category) || !definition$category %in% c("Current", "Historic")) {
    fail("category must be Current or Historic.")
  }
  data <- definition$data
  fractions <- c("Sand", "Silt", "Clay")
  if (!is.data.frame(data) || !all(c(fractions, "Label") %in% names(data)) || !nrow(data)) {
    fail("data must contain Sand, Silt, Clay, and Label columns with polygon rows.")
  }
  if (!all(vapply(data[fractions], is.numeric, logical(1)))) fail("Polygon coordinates must be numeric fractions.")
  coordinates <- as.matrix(data[fractions])
  if (any(!is.finite(coordinates)) || any(coordinates < -1e-12 | coordinates > 1 + 1e-12) ||
      any(abs(rowSums(coordinates) - 1) > 1e-10)) {
    fail("Polygon fractions must be finite, in 0–1, and total one at each vertex.")
  }
  if (!is.character(data$Label) || anyNA(data$Label) || any(!nzchar(trimws(data$Label)))) fail("Class labels must be nonempty strings.")
  for (polygon in split(data, data$Label)) {
    if (nrow(unique(polygon[fractions])) < 3L) fail("Each class requires at least three distinct vertices.")
    next_vertex <- c(seq_len(nrow(polygon))[-1], 1L)
    area <- abs(sum(polygon$Sand * polygon$Clay[next_vertex] - polygon$Clay * polygon$Sand[next_vertex])) / 2
    if (area <= 1e-12) fail("Each class polygon must have positive area.")
  }
  classes <- canonical_texture_label(unique(data$Label))
  if (anyDuplicated(classes)) fail("Class labels must remain distinct after whitespace normalization.")
  colours <- definition$colours
  if (!is.character(colours) || is.null(names(colours)) || anyNA(colours) || anyNA(names(colours)) ||
      anyDuplicated(names(colours)) || !setequal(names(colours), classes) ||
      any(!grepl("^#[[:xdigit:]]{6}([[:xdigit:]]{2})?$", colours))) {
    fail("colours must provide one named hex colour for every class, without extra classes.")
  }
  if (is.null(definition$label_size)) definition$label_size <- 4
  if (!scalar_number(definition$label_size) || definition$label_size <= 0) fail("label_size must be positive.")
  if (is.null(definition$label_overrides)) definition$label_overrides <- list()
  overrides <- definition$label_overrides
  if (!is.list(overrides) || (length(overrides) && (is.null(names(overrides)) ||
      anyNA(names(overrides)) || anyDuplicated(names(overrides)) || !all(names(overrides) %in% classes)))) {
    fail("label_overrides must be a named list using existing class names.")
  }
  for (override in overrides) {
    if (!is.list(override) || !length(override) || is.null(names(override)) ||
        anyNA(names(override)) || anyDuplicated(names(override)) ||
        !all(names(override) %in% c("text", "angle", "size", "sand", "clay"))) fail("Label overrides support text, angle, size, sand, and clay only.")
    if (!is.null(override$text) && !scalar_text(override$text)) fail("Override text must be a nonempty string.")
    if (!is.null(override$angle) && !scalar_number(override$angle)) fail("Override angle must be finite.")
    if (!is.null(override$size) && (!scalar_number(override$size) || override$size <= 0)) fail("Override size must be positive.")
    if (!is.null(override$sand) || !is.null(override$clay)) {
      if (!scalar_number(override$sand) || !scalar_number(override$clay) ||
          override$sand < 0 || override$clay < 0 || override$sand + override$clay > 100) {
        fail("Label positions require sand and clay percentages in the triangle.")
      }
    }
  }
  source_fields <- c("source", "source_url", "fractions")
  if (any(source_fields %in% names(definition)) &&
      !all(vapply(definition[source_fields], scalar_text, logical(1)))) {
    fail("Source metadata requires source, source_url, and fractions together.")
  }
  definition
}

load_classification_systems <- function(path = "R/classifications") {
  files <- list.files(path, pattern = "\\.R$", full.names = TRUE)
  if (!length(files)) stop("No classification definitions found in ", path, call. = FALSE)
  definitions <- lapply(files, function(file) {
    tryCatch({
      definition <- source(file, local = new.env(parent = environment()), encoding = "UTF-8")$value
      definition <- validate_classification_definition(definition)
      definition$definition_file <- file
      definition
    }, error = function(e) stop(basename(file), ": ", conditionMessage(e), call. = FALSE))
  })
  ids <- vapply(definitions, function(x) x$id, character(1))
  displays <- vapply(definitions, function(x) x$display, character(1))
  if (anyDuplicated(ids)) stop("Classification IDs must be unique.", call. = FALSE)
  if (anyDuplicated(displays)) stop("Classification display names must be unique.", call. = FALSE)
  priorities <- vapply(definitions, function(x) x$order, numeric(1))
  order <- order(priorities, ids)
  stats::setNames(definitions[order], ids[order])
}

classification_systems <- load_classification_systems()

classification_definition <- function(system) {
  if (length(system) != 1L || is.na(system) || !system %in% names(classification_systems)) {
    stop("Unknown classification system: ", paste(system, collapse = ", "), call. = FALSE)
  }
  classification_systems[[system]]
}

classification_choices <- function() {
  groups <- lapply(c("Current", "Historic"), function(category) {
    definitions <- Filter(function(definition) definition$category == category, classification_systems)
    displays <- vapply(definitions, function(definition) definition$display, character(1))
    ids <- names(definitions)
    alphabetical <- order(tolower(displays), method = "radix")
    stats::setNames(ids[alphabetical], displays[alphabetical])
  })
  stats::setNames(groups, c("Current", "Historic"))
}

# Only shortened labels need a key; ordinary wrapping keeps the same name.
classification_label_key <- function(system) {
  definition <- classification_definition(system)
  normalize <- function(x) canonical_texture_label(gsub("-[[:space:]]+", "-", x))
  rows <- lapply(names(definition$label_overrides), function(label) {
    text <- definition$label_overrides[[label]]$text
    if (is.null(text) || normalize(text) == normalize(label)) return(NULL)
    data.frame(Label = text, Class = label, stringsAsFactors = FALSE)
  })
  rows <- Filter(Negate(is.null), rows)
  if (!length(rows)) return(data.frame(Label = character(), Class = character()))
  do.call(rbind, rows)
}
