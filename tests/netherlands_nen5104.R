# Run from repository root: Rscript --vanilla tests/netherlands_nen5104.R
source("R/dependencies.R")
ensure_project_dependencies()
source("R/validation.R")
source("R/classification_systems.R")
source("R/classification.R")
system <- "Netherlands (NEN 5104 1989, 14 classes)"
cases <- read.csv("tests/fixtures/netherlands_nen5104.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
samples <- cases[c("soil", "sand", "silt", "clay")]
result <- classify_soil_data(samples, system)
stopifnot(identical(result$classification, cases$expected),
          all(result$classification_status == "classified"), length(unique(cases$expected)) == 14L)

# Analytical interpretation of the published mineral diagram, for interiors.
# This is not an assertion about national equality ownership or other diagrams.
reference <- function(p) {
  s <- p$sand; c <- p$clay
  code <- vapply(seq_along(s), function(i) {
    sand <- s[i]; clay <- c[i]
    if (clay > 50) return("Ks1")
    if (clay > 35) return("Ks2")
    if (clay > 25) return("Ks3")
    if (sand < 50) {
      if (clay + 0.34 * sand > 25) return("Ks4")
      return(if (sand < 15) "Lz1" else "Lz3")
    }
    if (clay > 17.5) return("Kz1")
    if (clay > 12) return("Kz2")
    if (clay > 8) return("Kz3")
    if (clay > 5 && sand > 82.5) return("Zk")
    if (sand > 90) return("Zs1")
    if (sand > 82.5) return("Zs2")
    if (sand > 67.5) return("Zs3")
    "Zs4"
  }, character(1))
  labels <- cases$expected
  names(labels) <- sub(" · .*", "", labels)
  unname(labels[code])
}
set.seed(5104)
random <- matrix(rexp(30000), ncol = 3)
random <- random / rowSums(random) * 100
p <- data.frame(sand = random[, 1], silt = random[, 2], clay = random[, 3])
polygons <- classification_polygons(system)
d <- classification_details(p, polygons)
stopifnot(all(d$classification_status == "classified"), identical(d$classification, reference(p)))

# Each internal segment, with split segments for the differently named classes.
edges <- data.frame(
  sand = c(20, 25, 60, 25, 65, 65, 60, 75, 90, 92.5, 85,
           90, 82.5, 82.5, 67.5, 50, 50, 50, 50, 15, 35, 7.5),
  clay = c(50, 35, 25, 25, 17.5, 12, 8, 8, 8, 5, 5,
           2, 2, 6, 4, 4, 10, 15, 20, 10, 13.1, 22.45),
  axis = c(rep("clay", 11), rep("sand", 9), "clay", "clay")
)
edges$silt <- 100 - edges$sand - edges$clay
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
junction <- classification_details(data.frame(sand = 50, clay = 8), polygons)
stopifnot(junction$classification_status == "boundary", is.na(junction$classification),
          length(strsplit(junction$classification_candidates, "; ", fixed = TRUE)[[1]]) == 4L)
stopifnot(identical(classify_points(data.frame(sand = c(100, 0, 0), clay = c(0, 100, 0)), polygons),
                    c("Zs1 · Zwak siltig zand", "Ks1 · Zwak siltige klei", "Lz1 · Zwak zandige leem")))
key <- classification_label_key(system)
definition <- classification_definition(system)
stopifnot(nrow(key) == 14L, !anyDuplicated(key$Label), setequal(key$Class, cases$expected),
          definition$display == "Netherlands (NEN 5104) · 1989 · 14 classes",
          definition$category == "Historic", system %in% classification_choices()$Historic,
          grepl("withdrawn", definition$source, fixed = TRUE),
          grepl("0.063", definition$fractions, fixed = TRUE))
example <- read.csv("examples/netherlands_samples.csv")
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
            grepl("NEN 5104", output$classificationReference$html, fixed = TRUE),
            grepl("0.063", output$systemRequirements$html, fixed = TRUE),
            grepl("Class label key", output$classificationReference$html, fixed = TRUE),
            !is.null(output$ternaryPlot))
  soil_data(samples[FALSE, ])
  session$flushReact()
  stopifnot(nrow(read.csv(output$downloadDataBtn)) == 0L)
})
cat("Netherlands NEN 5104: 14 classes, 10,000 analytical checks, 22 internal segments, Historic selector, key and CSV integration PASS\n")
