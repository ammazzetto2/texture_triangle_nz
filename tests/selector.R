# Run from repository root: Rscript --vanilla tests/selector.R
source("R/dependencies.R")
ensure_project_dependencies()
source("R/classification_systems.R")
choices <- classification_choices()
stopifnot(identical(names(choices), c("Current", "Historic")))
ids <- unlist(choices, use.names = FALSE)
stopifnot(length(ids) == length(classification_systems), !anyDuplicated(ids),
          setequal(ids, names(classification_systems)), "New Zealand" %in% choices$Current)
for (group in choices) {
  stopifnot(identical(order(tolower(names(group)), method = "radix"), seq_along(group)))
}
stopifnot(setequal(unname(choices$Historic), c(
  "Netherlands (NEN 5104 1989, 14 classes)",
  "FAO-UNESCO (1974, 3 groups)",
  "Germany (SEA74 1974, DE.SEA74.TT 1.5.3, 13 classes)",
  "Germany (TGL85 1985, DE.TGL85.TT 1.5.3, 14 classes)",
  "USDA 1911 (Whitney, USDA1911 1.5.3, 8 classes)")))
# Labels have three consistent fields and counts match the actual definitions.
for (definition in classification_systems) {
  fields <- strsplit(definition$display, " · ", fixed = TRUE)[[1]]
  stopifnot(length(fields) == 3L, nzchar(fields[1]),
            grepl("^([0-9]{4}( reference)?|Year unverified)$", fields[2]),
            grepl("^[0-9]+ (classes|groups|regions)$", fields[3]),
            as.integer(sub(" .*", "", fields[3])) == length(unique(definition$data$Label)))
}
stopifnot(classification_definition("Germany (BK94 1994, 31 classes)")$display ==
            "Germany (BK94) · 1994 · 31 classes")
# Verified reference dates must stay distinct from an asserted edition year.
reference_years <- c(
  "Brazil (SiBCS 2025, 13 classes)" = "2013",
  "Brazil (SiBCS 2025, 5 groups)" = "1996",
  "New Zealand" = "1995 reference", "USDA" = "1951 reference",
  "Australian" = "2018 reference", "Belgium (BE.TT 1.5.3, 7 classes)" = "1984 reference",
  "France (Aisne-Jamagne, FR.AISNE.TT 1.5.3, 15 classes)" = "1967 reference")
for (id in names(reference_years)) {
  fields <- strsplit(classification_definition(id)$display, " · ", fixed = TRUE)[[1]]
  stopifnot(fields[2] == reference_years[[id]])
}
stopifnot(!any(grepl("Year unverified", unlist(lapply(choices, names)), fixed = TRUE)))
valid <- classification_definition("New Zealand")
stopifnot(valid$category == "Current")
valid$category <- "Unknown"
error <- tryCatch(validate_classification_definition(valid), error = conditionMessage)
stopifnot(is.character(error), grepl("category must be", error, fixed = TRUE))
# Verify Shiny renders native option groups and retains the selected default.
app_env <- new.env()
source("soil_triangle.R", local = app_env)
html <- as.character(app_env$ui)
stopifnot(grepl('<optgroup label="Current">', html, fixed = TRUE),
          grepl('<optgroup label="Historic">', html, fixed = TRUE),
          grepl('value="New Zealand" selected', html, fixed = TRUE))
cat("Selector: grouped alphabetical choices, complete stable IDs, category validation and default selection PASS\n")
