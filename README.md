# Soil texture triangle

An R Shiny app for plotting soil samples and assigning texture classes using
New Zealand, USDA, Australian, Brazilian, and Canadian classification polygons.

Enter samples manually or upload a CSV, view their positions on a texture
triangle, and download the samples with their classifications.

## Run locally

Install R (4.1 or newer), then open R or RStudio in this repository's root folder and run:

```r
source("run_app.R")
```

Or start from a terminal in the repository root:

```sh
Rscript run_app.R
```

Startup automatically checks for `shiny`, `bslib`, `ggplot2`, `ggtern`, `dplyr`, and
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

1. Choose the shared **Classification system** at the top of the workspace.
2. Under **Add samples**, use **Manual entry** to enter a name and sand, silt,
   and clay percentages, then select **Add sample**. The live composition total
   indicates whether the percentages add up to 100.
3. Alternatively, use **CSV upload**. **Get CSV template** provides the required
   header; add sample rows before uploading it.
4. Explore **Triangle**, or open **Results** to review classes, labelled status
   badges, and candidate classes. The top bar counts samples that need review
   because they have no single assigned class. On narrow screens, scroll the
   table horizontally to see all columns.
5. Select **Download CSV** to export all current samples and classification
   details. **Sample labels** on the Triangle tab can be turned off for crowded
   datasets; the points remain visible.

Manual entries and uploaded samples share one dataset for the current session.
Uploading appends samples. **Clear all samples** clears the dataset. Download
results before closing the session if you want to keep them.

The interface uses a shared Bootstrap 5 theme, system fonts, and local styles
and branding assets, with no external font requests. The desktop workspace fits
the browser height: the triangle resizes and long results scroll inside their
panel. On smaller screens the layout stacks and normal page scrolling keeps
controls readable. **About & methodology** in the left panel links to local notes
covering classification behavior and the known Australian polygon overlap.

## Brazilian classifications

Brazil has two options: **13 classes** and **5 groups**, both based on SiBCS
2025. Labels are in Portuguese and exports identify the edition and view.
The selected Brazilian source and particle-size definitions appear under
**About & methodology**. Use fine-earth percentages measured with the stated
fractions; changing the selector does not convert laboratory measurements.
See [Brazilian source and validation notes](docs/classifications/brazil.md) and
[example Brazilian samples](examples/brazil_samples.csv).

## Canadian classification

**Canada · 13 classes** uses the Canadian System of Soil Classification, third
edition (1998), with AAFC numerical class definitions. It includes Heavy Clay
above 60% clay. Shared boundaries retain the app's candidate-class policy.
See [Canadian source and validation notes](docs/classifications/canada.md) and
[example Canadian samples](examples/canada_samples.csv).

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
stored per view in `R/classifications/`. Provenance for the original three
systems remains under review; Brazil and Canada have separate source notes.
The shared boundary policy is a software convention for every view.

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
| `soil_triangle.R` | Shiny server and shared download handler |
| `R/ui.R` | Page structure, Bootstrap theme, and accessible results table |
| `R/classifications/` | One definition per view: polygons, metadata, colours, and label settings |
| `R/classification.R` | Shared classification and export preparation |
| `R/classification_systems.R` | Definition discovery, schema validation, and polygon construction helper |
| `R/plotting.R` | Ternary plot construction, labels, and styling |
| `R/validation.R` | Shared manual-entry and CSV validation |
| `tests/validation.R` | Validation and Shiny integration checks |
| `tests/classification.R` | Classification, geometry, and download checks |
| `tests/brazil.R`, `tests/canada.R` | Country-specific analytical references and integration checks |
| `tests/fixtures/` | Independent reference compositions and expected classes |
| `tests/definitions.R` | Schema, discovery, and geometry checks for every definition |
| `tests/results.R` | Results table, summary, template, and export consistency checks |
| `tests/plotting.R` | Rendered text, graphics, and Shiny plot checks |
| `www/` | Stylesheet, methodology page, and branding assets served by Shiny |
| `examples/` | Example input data |
| `docs/classification.md` | Classification policy, source review, and known geometry issues |
| `docs/classifications/` | Country/view-specific source and validation notes |
| `docs/adding-classifications.md` | Definition schema and steps for adding another system |
| `old_files/` | Earlier scripts, an R Markdown draft, and reference workbooks |

The files named `*_tests.R` in `old_files/` are historical app prototypes,
not an automated test suite. A deployment procedure is not yet documented.

## Run checks

From the repository root (missing app dependencies are installed automatically):

```sh
Rscript --vanilla tests/run_all.R
```

The runner discovers test scripts and runs each in a separate R session.
Individual scripts, such as `Rscript --vanilla tests/canada.R`, can also be run.

The script uses base R assertions and Shiny's `testServer()`; no separate test
package is needed. It checks valid samples, invalid values and schemas, malformed
CSV input, floating-point tolerance, and preservation of session data after
rejected input. It uses the same dependency setup as the app.

The dependency checks simulate installation and failure paths without downloads
or changes to your actual R library paths.

Classification checks cover every class's vertex mean, example samples, export
columns, empty exports, boundary candidates, overlap detection, polygon-order independence, grid coverage, and the shared Shiny
download handler under all three systems. These are regression checks of the
current polygons, not validation against authoritative scientific references.

Results checks verify the empty state, ambiguous results, system switching,
export consistency, CSV template schema, clearing, and safe display of sample
names as text. They also check the live composition total and status badges.

Plotting checks build and draw all three systems with samples and with an empty
dataset. They check the rendered graphics for every class label, sample name,
and axis label, and fail on rendering warnings or messages. They also exercise
the Shiny plot output. Class and sample text use explicit identity positioning
for compatibility with ggplot2 4 and ggtern 4. Crowded sample labels may still
overlap; automatic label collision avoidance is not implemented. Sample labels can be hidden without removing points.

## Adding another classification

Add a definition in `R/classifications/`, independent reference fixtures and
tests, and a source note under `docs/classifications/`. The app, shared renderer,
exports, and common tests discover it automatically; the classifier needs no
country-specific code. Follow [the maintenance guide](docs/adding-classifications.md)
for the field contract, validation requirements, and workflow.

## Initial verification

On 5 November 2026, checks using R 4.6.0, Shiny 1.14.0, ggplot2 4.0.3,
ggtern 4.0.0, dplyr 1.2.1, and pracma 2.4.6 confirmed:

- The main app script parses and constructs a Shiny app object.
- Shiny server checks render all three classification plots and accept a valid
  manual sample.
- The example CSV has the required columns, valid ranges, and totals of 100.

The initial plotting warnings and dropped text layers have since been fixed.
The plotting checks now confirm warning-free rendering with visible text layers
on the versions listed above; rendered previews of all three systems were
visually inspected. Subsequent integration checks cover valid and rejected
uploads, results, the CSV download handler, and plotting. These checks do not
establish scientific accuracy or complete browser coverage.

## Planned improvements

1. Verify scientific sources, polygon geometry, and shared-boundary rules.
2. Separate data, validation, classification, plotting, and app code.
3. Add focused automated tests and reproducible dependency management.
4. Improve upload feedback, results display, and responsive layout.
5. Document deployment, licensing, and attribution before wider distribution.
