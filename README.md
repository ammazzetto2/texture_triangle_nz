# Soil texture triangle

An R Shiny app for plotting soil samples and assigning texture classes using
New Zealand, USDA, and Australian classification polygons.

Enter samples manually or upload a CSV, view their positions on a texture
triangle, and download the samples with their classifications.

## Run locally

Install R, then open R or RStudio in this repository's root folder. Install the
required packages once:

```r
install.packages(c("shiny", "ggplot2", "ggtern", "dplyr", "pracma"),
                 repos = "https://cloud.r-project.org")
```

Start the app from the same folder:

```r
shiny::runApp("soil_triangle.R")
```

The app opens in a browser. Stop it with Escape in RStudio or Ctrl+C in a
terminal. Package versions are not yet locked, so compatibility needs checking
when setting up a new environment.

For an isolated project-local package installation instead:

```r
dir.create(".R-library", showWarnings = FALSE)
.libPaths(c(normalizePath(".R-library"), .libPaths()))
install.packages(c("shiny", "ggplot2", "ggtern", "dplyr", "pracma"),
                 repos = "https://cloud.r-project.org")
shiny::runApp("soil_triangle.R")
```

Repeat the `.libPaths(...)` line in each new R session when using that local
library. The library is excluded from Git.

## Use the app

1. Open **Data Selection**, choose a classification system, enter a sample name
   and sand, silt, and clay percentages, then select **Add Data**.
2. Alternatively, open **Upload data** and upload a CSV in the format below.
3. View sample points on the triangle. Changing the classification system
   updates the triangle and the classifications used for download.
4. Select **Download Data** to export the samples with `classification` and
   `classification_system` columns.

Manual entries and uploaded samples share one dataset for the current app
session. Uploading appends samples. Either **Clear Data** button clears all
samples. Download data before closing the session if you want to keep it.

## CSV format

Use exactly these column names and order:

```csv
soil,sand,silt,clay
Sample A,50,25,25
Sample B,20,20,60
Sample C,90,5,5
```

A ready-to-upload file is available at
[`examples/soil_samples.csv`](examples/soil_samples.csv).

- `soil`: a sample name.
- `sand`, `silt`, `clay`: numeric percentages from 0 to 100, adding up to 100
  for each sample. Use percentages, not fractions between 0 and 1.
- Include all four columns, with no extra columns or missing values.
- Use a comma separator and a decimal point for fractional percentages.

The current input checks are incomplete. In particular, malformed files,
nonnumeric values, missing values, and extra columns may produce errors.
Totals are currently compared to 100 exactly, without a rounding tolerance.

## Scientific status

This repository is a prototype. The polygon coordinates and class names are
embedded in `soil_triangle.R`; authoritative source references and boundary
conventions still need to be documented and verified for each system.

Classification uses point-in-polygon checks in sand/clay coordinates. When a
sample matches more than one polygon, the last matching class in the current
iteration order wins. Boundary assignments therefore need explicit review.
Some exported class labels contain line breaks used for plot formatting.

Initial structural checks found that polygon vertices are within 0–1 and sum
to 1. The Australian polygons have a combined area of 0.50025 compared with
0.5 for the full triangle; the cause still needs investigation. Area totals
alone do not establish that a system has no gaps or overlaps.

## Repository layout

| Path | Purpose |
| --- | --- |
| `soil_triangle.R` | Current Shiny app, polygon data, classification, and exports |
| `WWW/` | Existing logo images; static asset serving needs verification |
| `examples/` | Example input data |
| `old_files/` | Earlier scripts, an R Markdown draft, and reference workbooks |

The files named `*_tests.R` in `old_files/` are historical app prototypes,
not an automated test suite. There is currently no automated test suite or
documented deployment procedure.

## Initial verification

On 5 November 2026, checks using R 4.6.0, Shiny 1.14.0, ggplot2 4.0.3,
ggtern 4.0.0, dplyr 1.2.1, and pracma 2.4.6 confirmed:

- The main app script parses and constructs a Shiny app object.
- Shiny server checks render all three classification plots and accept a valid
  manual sample.
- The example CSV has the required columns, valid ranges, and totals of 100.

Plot rendering emits warnings, including ignored `xarrow`, `yarrow`, and
`zarrow` labels. These checks do not establish visual correctness or cover
browser interactions, file uploads, downloads, or scientific accuracy.

## Planned improvements

1. Verify scientific sources, polygon geometry, and shared-boundary rules.
2. Separate data, validation, classification, plotting, and app code.
3. Add focused automated tests and reproducible dependency management.
4. Improve upload feedback, results display, and responsive layout.
5. Document deployment, licensing, and attribution before wider distribution.
