# Soil texture triangle

An R Shiny app for plotting soil samples and assigning texture classes using
New Zealand, USDA, and Australian classification polygons.

Enter samples manually or upload a CSV, view their positions on a texture
triangle, and download the samples with their classifications.

## Run locally

Install R, then open R or RStudio in this repository's root folder and run:

```r
source("run_app.R")
```

Or start from a terminal in the repository root:

```sh
Rscript run_app.R
```

Startup automatically checks for `shiny`, `ggplot2`, `ggtern`, `dplyr`, and
`pracma`. Missing packages and their required dependencies are installed from
CRAN into `.R-library/` inside this project. Already available, loadable packages
are reused. The local library is added to R's library paths for the session and
is excluded from Git. No manual package installation is needed.

R itself must already be installed. An internet connection is required when
packages are missing; source package installations may also require system
build tools. With dependencies installed, startup does not need to download
packages. Package versions are not yet locked, so this setup automates
installation but does not guarantee identical environments across computers.

In RStudio the app opens in a browser. Terminal startup prints a local URL to
open. Stop it with Escape in RStudio or Ctrl+C in a terminal. The main app also
runs the dependency check when sourced directly.

## Use the app

1. Open **Data Selection**, choose a classification system, enter a sample name
   and sand, silt, and clay percentages, then select **Add Data**.
2. Alternatively, open **Upload data** and upload a CSV in the format below.
   **Download CSV template** provides the required header; add sample rows
   before uploading it.
3. View sample points on the triangle. Changing the classification system
   updates the triangle, the Results table, and downloaded classifications.
4. Open **Results** to review percentages, class, status, and candidate classes.
   The summary counts samples without a single assigned class. A dash in the
   Class column means no single class was assigned; inspect the candidates.
   On narrow screens, scroll the table horizontally to see all columns.
5. Select **Download Data** in either input tab to export all samples and their
   full classification details. Both buttons export the same current results.

Manual entries and uploaded samples share one dataset for the current app
session. Uploading appends samples. Either **Clear Data** button clears all
samples. Download data before closing the session if you want to keep it.

## CSV format

Use exactly these column names (the order may vary):

```csv
soil,sand,silt,clay
Sample A,50,25,25
Sample B,20,20,60
Sample C,90,5,5
```

A ready-to-upload file is available at
[`examples/soil_samples.csv`](examples/soil_samples.csv).

- `soil`: a nonblank sample name. Surrounding whitespace is removed.
- `sand`, `silt`, `clay`: numeric percentages from 0 to 100, adding up to 100
  for each sample. Use percentages, not fractions between 0 and 1.
- Include all four columns, with no extra columns or missing values.
- Use a comma separator and a decimal point for fractional percentages.

Manual entries and uploads use the same validation rules. Missing or duplicate
columns, extra columns, empty tables, blank sample names, nonnumeric percentages,
missing or infinite values, and percentages outside 0–100 are rejected. Invalid
totals report sample row numbers (excluding the CSV header). Rejected input
leaves existing samples intact; an upload is accepted only if all rows are valid.

Totals use an absolute tolerance of `1e-8` percentage points to accommodate
floating-point arithmetic. Values are not normalized or rounded automatically.
This tolerance does not accommodate laboratory measurement or rounding error.

## Scientific status

This repository is a prototype. The polygon coordinates and class names are
stored in `R/classification_data.R`; authoritative source references and boundary
conventions still need to be documented and verified for each system.

Classification now reports uncertainty explicitly. A unique polygon match receives
that class, including outer edges and pure-component corners. Shared boundaries
and overlapping regions receive no single class (`NA`) and list all candidate
classes. Downloads include `classification_status` (`classified`, `boundary`,
`overlap`, or `unclassified`) and `classification_candidates` in addition to the
original columns. Polygon order never resolves an ambiguous result.

The original coordinates have not changed. The Australian polygons still have a
confirmed Sand / Sandy Loam overlap. Sources, numerical tolerances, examples,
limitations, and remaining verification work are documented in
[`docs/classification.md`](docs/classification.md).

## Repository layout

| Path | Purpose |
| --- | --- |
| `run_app.R` | Launcher with automatic dependency setup |
| `R/dependencies.R` | Shared package checks and installation |
| `soil_triangle.R` | Shiny UI, server, plotting, and download handlers |
| `R/classification_data.R` | Polygon coordinates and class labels |
| `R/classification.R` | Shared classification and export preparation |
| `R/validation.R` | Shared manual-entry and CSV validation |
| `tests/validation.R` | Validation and Shiny integration checks |
| `tests/classification.R` | Classification, geometry, and download checks |
| `tests/results.R` | Results table, summary, template, and export consistency checks |
| `WWW/` | Existing logo images; static asset serving needs verification |
| `examples/` | Example input data |
| `docs/classification.md` | Classification policy, source review, and known geometry issues |
| `old_files/` | Earlier scripts, an R Markdown draft, and reference workbooks |

The files named `*_tests.R` in `old_files/` are historical app prototypes,
not an automated test suite. A deployment procedure is not yet documented.

## Run checks

From the repository root (missing app dependencies are installed automatically):

```sh
Rscript --vanilla tests/validation.R
Rscript --vanilla tests/dependencies.R
Rscript --vanilla tests/classification.R
Rscript --vanilla tests/results.R
```

The script uses base R assertions and Shiny's `testServer()`; no separate test
package is needed. It checks valid samples, invalid values and schemas, malformed
CSV input, floating-point tolerance, and preservation of session data after
rejected input. It uses the same dependency setup as the app.

The dependency checks simulate installation and failure paths without downloads
or changes to your actual R library paths.

Classification checks cover every class's vertex mean, example samples, export
columns, empty exports, boundary candidates, overlap detection, polygon-order independence, grid coverage, and both Shiny
download handlers under all three systems. These are regression checks of the
current polygons, not validation against authoritative scientific references.

Results checks verify the empty state, ambiguous results, system switching,
export consistency, CSV template schema, clearing, and safe display of sample
names as text.

## Initial verification

On 5 November 2026, checks using R 4.6.0, Shiny 1.14.0, ggplot2 4.0.3,
ggtern 4.0.0, dplyr 1.2.1, and pracma 2.4.6 confirmed:

- The main app script parses and constructs a Shiny app object.
- Shiny server checks render all three classification plots and accept a valid
  manual sample.
- The example CSV has the required columns, valid ranges, and totals of 100.

Plot rendering emits warnings, including ignored `xarrow`, `yarrow`, and
`zarrow` labels. These checks do not establish visual correctness or cover
browser interactions or scientific accuracy. Subsequent integration checks
cover valid and rejected uploads and both CSV download handlers.

## Planned improvements

1. Verify scientific sources, polygon geometry, and shared-boundary rules.
2. Separate data, validation, classification, plotting, and app code.
3. Add focused automated tests and reproducible dependency management.
4. Improve upload feedback, results display, and responsive layout.
5. Document deployment, licensing, and attribution before wider distribution.
