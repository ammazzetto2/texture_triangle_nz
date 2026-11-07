# Run from repository root: Rscript --vanilla tests/switzerland_fal1997.R
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")
system <- "Switzerland (FAL 1997, 13 classes)"
cases <- read.csv("tests/fixtures/switzerland_fal1997.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status == "classified"), length(unique(cases$expected)) == 13L)

# Independent analytical reading of FAL Table 3.5b for strict interiors.
# Endpoint ownership below is not asserted as a scientific equality policy.
reference <- function(p) {
  c <- p$clay; z <- p$silt
  ifelse(c > 50, "T · Ton",
    ifelse(z > 50,
      ifelse(c < 10, ifelse(z > 70, "U · Schluff", "sU · Sandiger Schluff"),
        ifelse(c < 30, "lU · Lehmiger Schluff", "tU · Toniger Schluff")),
      ifelse(c < 5, ifelse(z < 15, "S · Sand", "uS · Schluffiger Sand"),
        ifelse(c < 10, "lS · Lehmiger Sand",
          ifelse(c < 15, "lrS · Lehmreicher Sand",
            ifelse(c < 20, "sL · Sandiger Lehm",
              ifelse(c < 30, "L · Lehm",
                ifelse(c < 40, "tL · Toniger Lehm", "lT · Lehmiger Ton"))))))))
}
set.seed(1997)
random <- matrix(rexp(30000), ncol = 3)
random <- random / rowSums(random) * 100
p <- data.frame(sand = random[, 1], silt = random[, 2], clay = random[, 3])
polygons <- classification_polygons(system)
d <- classification_details(p, polygons)
stopifnot(all(d$classification_status == "classified"), identical(d$classification, reference(p)))

# Every internal boundary family, including the three distinctions missing
# from the ten-class ggsoiltexture Zurich data.
edges <- rbind(
  data.frame(clay = c(5, 10, 15, 20, 30, 40, 50), silt = 25, axis = "clay"),
  data.frame(clay = c(10, 30), silt = 65, axis = "clay"),
  data.frame(clay = c(2.5, 7.5, 12.5, 17.5, 25, 35, 45), silt = 50, axis = "sand"),
  data.frame(clay = c(2.5, 5), silt = c(15, 70), axis = "sand")
)
edges$sand <- 100 - edges$silt - edges$clay
ed <- classification_details(edges, polygons)
stopifnot(all(ed$classification_status == "boundary"), all(is.na(ed$classification)))
for (i in seq_len(nrow(edges))) {
  sides <- edges[rep(i, 2), ]
  if (edges$axis[i] == "sand") sides$sand <- sides$sand + c(-0.001, 0.001)
  else sides$clay <- sides$clay + c(-0.001, 0.001)
  sides$silt <- 100 - sides$sand - sides$clay
  sd <- classification_details(sides, polygons)
  stopifnot(all(sd$classification_status == "classified"),
            identical(sd$classification, reference(sides)), length(unique(sd$classification)) == 2L)
}
corners <- data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0))
stopifnot(identical(classify_points(corners, polygons), c("S · Sand", "T · Ton", "U · Schluff")))
key <- classification_label_key(system)
stopifnot(nrow(key) == 13L, !anyDuplicated(key$Label), setequal(key$Class, cases$expected),
          key$Class[key$Label == "lrS"] == "lrS · Lehmreicher Sand",
          classification_definition(system)$display == "Switzerland (FAL) · 1997 · 13 classes",
          system %in% classification_choices()$Current)
example <- read.csv("examples/switzerland_samples.csv")
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
            identical(results_table()$Class, cases$expected),
            grepl("FAL 24", output$classificationReference$html, fixed = TRUE),
            grepl("mineral fine earth", output$systemRequirements$html, fixed = TRUE),
            grepl("0.05", output$systemRequirements$html, fixed = TRUE),
            grepl("Class label key", output$classificationReference$html, fixed = TRUE),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("Swiss FAL 1997: 13 primary-source classes, 10,000 analytical checks, boundaries, key, examples and CSV integration PASS\n")
