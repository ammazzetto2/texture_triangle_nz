# Run from the repository root: Rscript --vanilla tests/validation.R
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")

expect_error <- function(expr, pattern) {
  message <- tryCatch({ force(expr); NULL }, error = conditionMessage)
  stopifnot(!is.null(message), grepl(pattern, message, fixed = TRUE))
}

valid <- data.frame(soil = " Sample A ", sand = 50, silt = 25, clay = 25)
stopifnot(validate_soil_data(valid)$soil == "Sample A")
stopifnot(identical(names(validate_soil_data(valid[c(4, 2, 1, 3)])), names(valid)))
expect_error(validate_soil_data(valid[FALSE, ]), "at least one")
expect_error(validate_soil_data(valid[-1]), "exactly these columns")
expect_error(validate_soil_data(transform(valid, extra = 1)), "no extra columns")
duplicate <- valid
names(duplicate)[2] <- "soil"
expect_error(validate_soil_data(duplicate), "unique")
for (name in c("", "  ", NA_character_)) {
  expect_error(validate_soil_data(transform(valid, soil = name)), "Sample names are required")
}
for (value in c(-10, 101, NA_real_, NaN, Inf, -Inf)) {
  expect_error(validate_soil_data(transform(valid, sand = value)), "finite values")
}
expect_error(validate_soil_data(transform(valid, sand = "50")), "numeric percentages")
expect_error(validate_soil_data(transform(valid, sand = 49)), "total 100%")
stopifnot(nrow(validate_soil_data(transform(valid, sand = 50 + 1e-10))) == 1)
expect_error(validate_soil_data(rbind(valid, transform(valid, clay = NA_real_))), "row(s): 2")
stopifnot(nrow(read_soil_csv("examples/soil_samples.csv")) == 3)

csv <- tempfile(fileext = ".csv")
writeLines(c("clay,soil,silt,sand", "25,Reordered,25,50"), csv)
stopifnot(read_soil_csv(csv)$sand == 50)
writeLines(c("soil,sand,silt,clay", "Broken,50,25"), csv)
expect_error(read_soil_csv(csv), "Could not read")
writeLines(c("soil,sand,silt,clay", '"Broken,50,25,25'), csv)
expect_error(read_soil_csv(csv), "Could not read")
writeLines(c("soil,sand,silt,clay", "Broken,50,25,25,extra"), csv)
expect_error(read_soil_csv(csv), "columns")
unlink(csv)
cat("Validation checks: PASS\n")

app_env <- new.env()
app <- source("soil_triangle.R", local = app_env)$value
shiny::testServer(app_env$server, {
  session$setInputs(dataset = "New Zealand")
  session$setInputs(sampleName = "Valid", sandValue = 50, siltValue = 25,
                    clayValue = 25, addManualDataBtn = 1)
  stopifnot(nrow(soil_data()) == 1)
  original <- soil_data()
  session$setInputs(sandValue = -10, siltValue = 60, clayValue = 50,
                    addManualDataBtn = 2)
  stopifnot(identical(soil_data(), original))
  session$setInputs(sandValue = NA_real_, addManualDataBtn = 3)
  stopifnot(identical(soil_data(), original))
  session$setInputs(fileUpload = list(datapath = normalizePath("examples/soil_samples.csv")))
  stopifnot(identical(soil_data(), original))
  session$setInputs(confirmImportBtn = 1)
  stopifnot(nrow(soil_data()) == 4)
  original <- soil_data()
  invalid_csv <- tempfile(fileext = ".csv")
  writeLines(c("soil,sand,silt,clay", "Invalid,50,text,25"), invalid_csv)
  session$setInputs(fileUpload = list(datapath = invalid_csv))
  stopifnot(identical(soil_data(), original))
  unlink(invalid_csv)
  session$setInputs(clearDataBtn = 1)
  stopifnot(nrow(soil_data()) == 0)
})
cat("Shiny validation integration checks: PASS\n")
