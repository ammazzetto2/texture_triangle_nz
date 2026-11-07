# From the repository root: Rscript --vanilla benchmarks/csv_workspace.R [rows]
# Each timing covers server-side work for one synthetic CSV in one R process.
args <- commandArgs(trailingOnly = TRUE)
rows <- if (length(args)) as.numeric(args[1]) else 5000
stopifnot(length(args) <= 1L, is.finite(rows), rows >= 1, rows == floor(rows))
source("soil_triangle.R")

run_benchmark <- function(rows) {
  set.seed(42)
  sand <- sample.int(1001, rows, replace = TRUE) - 1L
  clay <- floor(runif(rows) * (1001 - sand))
  samples <- data.frame(soil = sprintf("Paddock %06d", seq_len(rows)),
    sand = sand / 10, silt = (1000 - sand - clay) / 10, clay = clay / 10)
  csv <- tempfile(fileext = ".csv")
  chart <- tempfile(fileext = ".png")
  on.exit(unlink(c(csv, chart)), add = TRUE)
  write.csv(samples, csv, row.names = FALSE)
  read_time <- system.time(raw <- read_upload_table(csv))
  preview_time <- system.time(review <- inspect_upload(raw, default_upload_mapping(raw)))
  stopifnot(!nrow(review$issues), nrow(review$samples) == rows)
  class_time <- system.time(result <- classify_soil_data(review$samples, "New Zealand"))
  stopifnot(nrow(result) == rows)
  chart_time <- system.time({
    plot <- build_soil_plot(review$samples, "New Zealand", avoid_overlap = TRUE)
    ggplot2::ggsave(chart, plot, width = 8, height = 6, dpi = 100, bg = "white")
  })
  stopifnot(file.size(chart) > 0)
  cat(sprintf("%d rows, %d CSV bytes, New Zealand, 800 x 600 PNG, labels enabled\n",
    rows, file.size(csv)))
  print(data.frame(stage = c("Read CSV", "Inspect upload", "Classify", "Draw chart"),
    seconds = unname(c(read_time["elapsed"], preview_time["elapsed"],
      class_time["elapsed"], chart_time["elapsed"]))), row.names = FALSE)
}

run_benchmark(rows)
