# Run from the repository root: Rscript --vanilla tests/brazil_sibcs2013_8.R
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")
system <- "Brazil (SiBCS 2013, SiBCS13.TT 1.5.3, 8 classes)"
cases <- read.csv("tests/fixtures/brazil_sibcs2013_8.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status[-4] == "classified"),
          result$classification_status[4] == "boundary",
          result$classification_candidates[4] == "Argilosa; Muito argilosa",
          length(unique(na.omit(cases$expected))) == 8L)

# An analytical interpretation of the pinned transcription's sloping segments,
# not an independent certification of the original handbook's inequalities.
reference <- function(p) {
  s <- p$sand; z <- p$silt; c <- p$clay
  ifelse(c > 60, "Muito argilosa",
    ifelse(c >= 35, "Argilosa",
      ifelse(s < 15, "Siltosa",
        ifelse(z + 1.5 * c < 15, "Muito arenosa",
          ifelse(z + 2 * c < 30, "Arenosa média",
            ifelse(c < 20 & s > 52.5 + c / 8, "Média arenosa",
              ifelse(c >= 20 & ((c < 25 & s + 1.5 * c > 85) |
                                  (c >= 25 & s > 47.5)), "Média argilosa", "Média siltosa")))))))
}
set.seed(2013)
random <- matrix(rexp(30000), ncol = 3)
random <- random / rowSums(random) * 100
p <- data.frame(sand = random[, 1], silt = random[, 2], clay = random[, 3])
polygons <- classification_polygons(system)
d <- classification_details(p, polygons)
stopifnot(all(d$classification_status == "classified"), identical(d$classification, reference(p)))

# Exercise both sides of the subgroup-specific sloping and vertical edges.
boundaries <- data.frame(soil = c("Low clay slope", "Middle slope", "Middle vertical", "Silty limit"),
                         sand = c(53.75, 52, 47.5, 15), clay = c(10, 22, 30, 20))
boundaries$silt <- 100 - boundaries$sand - boundaries$clay
bd <- classify_soil_data(boundaries, system)
stopifnot(all(bd$classification_status == "boundary"), all(is.na(bd$classification)))
for (i in seq_len(nrow(boundaries))) {
  sides <- boundaries[rep(i, 2), ]; sides$sand <- sides$sand + c(-0.001, 0.001)
  sides$silt <- 100 - sides$sand - sides$clay
  sd <- classify_soil_data(sides, system)
  stopifnot(all(sd$classification_status == "classified"),
            identical(sd$classification, reference(sides)),
            length(unique(sd$classification)) == 2L)
}
stopifnot(identical(classify_points(data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0)), polygons),
                    c("Muito arenosa", "Muito argilosa", "Siltosa")))
key <- classification_label_key(system)
stopifnot(nrow(key) == 8L, !anyDuplicated(key$Label),
          key$Class[key$Label == "MeAr"] == "Média arenosa", key$Class[key$Label == "MAr"] == "Muito arenosa",
          classification_definition(system)$display == "Brazil (SiBCS) · 2013 · 8 classes",
          system %in% classification_choices()$Current,
          length(classification_polygons("Brazil (SiBCS 2025, 13 classes)")) == 13L,
          length(classification_polygons("Brazil (SiBCS 2025, 5 groups)")) == 5L)
example <- read.csv("examples/brazil_sibcs2013_8_samples.csv", fileEncoding = "UTF-8")
stopifnot(identical(classify_soil_data(example, system)$classification_status,
                    c("classified", "classified", "classified", "boundary")))

app_env <- new.env()
source("soil_triangle.R", local = app_env)
shiny::testServer(app_env$server, {
  soil_data(samples)
  session$setInputs(dataset = system)
  exported <- read.csv(output$downloadDataBtn, fileEncoding = "UTF-8")
  stopifnot(isTRUE(all.equal(exported, classify_soil_data(samples, system), check.attributes = FALSE)),
            all(exported$classification_system == system),
            grepl("SiBCS13.TT", output$classificationReference$html, fixed = TRUE),
            grepl("0.05", output$systemRequirements$html, fixed = TRUE),
            grepl("Class label key", output$classificationReference$html, fixed = TRUE),
            all(vapply(key$Class, function(label) grepl(label, output$classificationReference$html, fixed = TRUE), logical(1))),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("Brazil SiBCS 2013: published cases, eight classes, subgroup edges, 10,000 analytical checks, key and CSV integration PASS\n")
