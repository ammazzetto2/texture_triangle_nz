source("R/dependencies.R")
ensure_project_dependencies()
app_env <- new.env()
source("soil_triangle.R", local = app_env)

expect_error <- function(expr, pattern) {
  message <- tryCatch({ force(expr); NULL }, error = conditionMessage)
  stopifnot(!is.null(message), grepl(pattern, message, fixed = TRUE))
}
samples <- data.frame(soil = c("001", "NA", 'Paddock, "north"', "Łąka", "Boundary"),
                      sand = c(50, 90, 20, 33.3, 20),
                      silt = c(25, 5, 20, 33.3, 20), clay = c(25, 5, 60, 33.4, 60))
csv <- tempfile(fileext = ".csv")
systems <- unname(unlist(app_env$classification_choices()))
for (system in systems) {
  exported <- app_env$classify_soil_data(samples, system)
  write.csv(exported, csv, row.names = FALSE)
  restored <- app_env$read_soil_csv(csv, "results")
  stopifnot(isTRUE(all.equal(restored, samples)))
}
# Exact schemas, not arbitrary extra columns, distinguish the two formats.
expect_error(app_env$read_soil_csv(csv), "exactly these columns")
write.csv(samples, csv, row.names = FALSE)
stopifnot(isTRUE(all.equal(app_env$read_soil_csv(csv), samples)))
expect_error(app_env$read_soil_csv(csv, "results"), "Downloaded results")
exported <- app_env$classify_soil_data(samples, "New Zealand")
write.csv(exported[, rev(names(exported))], csv, row.names = FALSE)
stopifnot(isTRUE(all.equal(app_env$read_soil_csv(csv, "results"), samples)))
for (bad in list(exported[-8], transform(exported, extra = "unexpected"))) {
  write.csv(bad, csv, row.names = FALSE)
  expect_error(app_env$read_soil_csv(csv, "results"), "exactly these columns")
}
bad <- exported
names(bad)[8] <- names(bad)[7]
write.csv(bad, csv, row.names = FALSE)
expect_error(app_env$read_soil_csv(csv, "results"), "unique")
bad <- exported
bad$sand[1] <- 49
write.csv(bad, csv, row.names = FALSE)
expect_error(app_env$read_soil_csv(csv, "results"), "total 100%")
write.csv(exported[FALSE, ], csv, row.names = FALSE)
expect_error(app_env$read_soil_csv(csv, "results"), "at least one")
unlink(csv)

shiny::testServer(app_env$server, {
  session$setInputs(dataset = "New Zealand", undoDataBtn = 0)
  change_samples(samples, "Initial samples")
  saved <- tempfile(fileext = ".csv")
  file.copy(output$downloadDataBtn, saved)
  original <- soil_data()
  # Use a different compatible system; stale/forged output must not be reused.
  historical <- read.csv(saved, colClasses = c(soil = "character"), na.strings = character())
  historical$classification <- "Saved class that must not be used"
  historical$classification_status <- "saved status"
  historical$classification_system <- "Unknown historical edition"
  historical$classification_candidates <- "saved candidates"
  write.csv(historical, saved, row.names = FALSE)
  session$setInputs(csvFormat = "results", dataset = "USDA",
                    fileUpload = list(datapath = saved))
  stopifnot(identical(soil_data(), original))
  session$setInputs(confirmImportBtn = 1)
  stopifnot(nrow(soil_data()) == 10L,
            identical(soil_data()$soil, rep(samples$soil, 2)),
            all(classified_data()$classification_system == "USDA"),
            !any(classified_data()$classification_status == "saved status"),
            grepl("recalculated using USDA", output$sampleFeedback, fixed = TRUE))
  # Selecting another format does not silently re-import the selected file.
  session$setInputs(csvFormat = "samples")
  stopifnot(nrow(soil_data()) == 10L)
  session$setInputs(undoDataBtn = 1)
  stopifnot(identical(soil_data(), original))
  bad_path <- tempfile(fileext = ".csv")
  historical$clay[1] <- -1
  write.csv(historical, bad_path, row.names = FALSE)
  session$setInputs(csvFormat = "results", fileUpload = list(datapath = bad_path))
  stopifnot(identical(soil_data(), original), is.null(undo_state()))
  unlink(c(saved, bad_path))
})
cat("CSV round trips: all systems, text names, strict schemas, recalculation, append, and undo PASS\n")
