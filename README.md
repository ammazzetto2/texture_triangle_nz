# Soil texture triangle

An R Shiny app for plotting soil samples and assigning texture classes using
20 current and historic classification views, including New Zealand, USDA,
Australian, Brazilian, and Canadian polygons.

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
   The toolbar shows the selected system's documented particle-size requirements
   and reminds you that switching systems does not convert measurements. Where
   requirements are undocumented, the app says so; original project polygons
   retain their source-verification notice. Australia also shows its known overlap.
2. Under **Add samples**, use **Manual entry** to enter a name and sand, silt,
   and clay percentages, then select **Add sample**. The live composition total
   indicates whether the percentages add up to 100 and shows any difference.
   Errors appear inline. **Calculate a remaining percentage** fills the chosen
   component with 100 minus the other two; it does not normalize all values.
3. Alternatively, use **CSV upload**. **Get CSV template** provides the required
   header; add sample rows before uploading it. Map columns, review the preview,
   choose Append or Replace, then select **Import reviewed samples**. Selecting
   a file alone does not change the workspace.
   To reopen an exported results CSV, choose **Downloaded results (8 columns)**
   before selecting the file. Names and percentages are restored; classifications
   are recalculated using the currently selected system. Choose a system compatible
   with your laboratory fractions: importing does not convert measurements.
4. Explore **Triangle**, or open **Results** to review classes, labelled status
   badges, and candidate classes. The top bar counts samples that need review
   because they have no single assigned class. On narrow screens, scroll the
   table horizontally to see all columns.
   Click **need review** to open Results with **Only samples needing review**
   enabled. Turn off the filter to see all rows. **What this means** explains
   boundary, overlap and unclassified statuses. **Boundary (assigned)** means
   an edge point has one matching class and is excluded from the review count.
   Filtering does not change the triangle or CSV export, which still include
   all samples. Edit, Delete and Undo remain available for filtered rows.
5. Select **Download CSV** to export all current samples and classification
   details. **Sample labels** on the Triangle tab can be turned off for crowded
   datasets; the points remain visible.

### Chart tools

- **Enlarge** opens a larger chart using the current label controls and highlight.
- **PNG** downloads a 3000 × 2700 pixel chart with the system name and current
  highlight. All samples are included, even when Results is filtered.
- **Class key** opens plot labels and full class names beside the chart workflow.
- **Hide overlapping labels** suppresses colliding sample labels while keeping
  all points. It does not move points or prevent collisions with class labels.
  Turn it off to show every sample label.
- **View** beside a Results row highlights that exact sample with a blue ring,
  bold label and composition summary. This also works with duplicate names and
  filtered results. The highlighted label stays visible when other labels are
  hidden. **Clear highlight** removes the selection. Changes to sample data,
  including Undo, clear the highlight so it cannot move to another row.

### Results navigation

Search sample names using a case-insensitive, literal substring. **Sort by**
orders names, percentages, classes, status or candidates; **Descending order**
reverses the direction. Missing classes remain last. **Entry order** returns to
the original row sequence. Search combines with the review filter; clicking the
top **need review** count clears the name search.

Results show 25 rows per page by default, with 50 and 100 available. Use
**Previous** and **Next** to browse. Changing search, sorting, page size, review
filter or classification system returns to page one. View, Edit and Delete
always target the original sample, regardless of table order. Exports and the
triangle include all samples. Mobile screens have sticky **Add samples** and
**View results** shortcuts.

Manual entries and uploaded samples share one dataset for the current session.
Importing appends samples by default; **Replace all current samples** replaces
the dataset when the reviewed import is submitted. **Clear all samples** clears the dataset. **Undo**
restores the dataset before the latest successful add, upload, edit, delete, or clear (one
level, within this session). Invalid input leaves that undo available. Manual
entry clears the sample name after success and rejects an identical name and
composition already in the dataset; use distinct names for replicate samples.
CSV uploads preserve all supplied rows, including duplicates. Download
results before closing the session if you want to keep them.

In **Results**, use **Edit** beside a sample name to correct its name or
percentages, then **Save changes**. Invalid edits stay in the editor with an
explanation; **Cancel** leaves the sample unchanged. **Delete** removes only
that row, even when multiple samples have the same name. Both edits and deletes
can be undone using the sample panel. Changes update the triangle, results and
CSV download together.

The interface uses a shared Bootstrap 5 theme, system fonts, and local styles
and branding assets, with no external font requests. The desktop workspace fits
the browser height: the triangle resizes and long results scroll inside their
panel. On smaller screens the layout stacks and normal page scrolling keeps
controls readable. **About & methodology** in the left panel links to local notes
covering classification behavior and the known Australian polygon overlap.

## Brazilian classifications

Brazil has three options: **13 classes** (2013 reference), **8 classes**
(SiBCS 2013 texture subgroups), and **5 groups** (1996 reference).
The 13-class and five-group geometry implementations are sourced to SiBCS
2025; the eight-class view follows `SiBCS13.TT` in soiltexture 1.5.3.
Labels are in Portuguese and exports identify the edition and view.
The selected Brazilian source and particle-size definitions appear under
**About & methodology**. Use fine-earth percentages measured with the stated
fractions; changing the selector does not convert laboratory measurements.
See [Brazilian source and validation notes](docs/classifications/brazil.md) and
[example Brazilian samples](examples/brazil_samples.csv).

**Brazil (SiBCS) · 2013 · 8 classes** is the separate texture-subgroup
triangle, with source codes linked to full Portuguese names in the class key.
The `13` in `SiBCS13.TT` means 2013, not 13 classes. See
[eight-class source and validation notes](docs/classifications/brazil_sibcs2013_8.md)
and [example samples](examples/brazil_sibcs2013_8_samples.csv).

## Canadian classification

**Canada (CSSC) · 1998 · 13 classes** uses the Canadian System of Soil Classification, third
edition (1998), with AAFC numerical class definitions. It includes Heavy Clay
above 60% clay. Shared boundaries retain the app's candidate-class policy.
See [Canadian source and validation notes](docs/classifications/canada.md) and
[example Canadian samples](examples/canada_samples.csv).

## FAO–UNESCO texture groups

**FAO–UNESCO · 1974 · 3 groups** implements Coarse, Medium and Fine from the
original Soil Map of the World legend. This is the historical map grouping,
with an 18% clay step and 35% clay fine limit, rather than the later detailed
FAO texture triangle. See [source and validation notes](docs/classifications/fao_1974.md)
and [example samples](examples/fao_1974_samples.csv).

## UK mineral-soil classification

**UK (TIN037) · 2008 · 11 classes** follows Natural England's mineral-soil
triangle, including Sandy Silt Loam. Its **0.06 mm sand/silt cutoff** differs
from the 0.05 mm convention used by several other views; switching systems
cannot convert laboratory fractions. Organic, peat and calcareous variants
are excluded. See [UK source and validation notes](docs/classifications/uk_tin037.md)
and [example samples](examples/uk_samples.csv).

## French GEPPA classification

**France (GEPPA) · 1963 · 17 classes** uses French class codes and names,
including distinct case-sensitive codes such as `As` and `AS`. The source's
right-triangle compositions use the app's usual equilateral display.
Inputs use a 0.05 mm sand/silt cutoff. See [French source and implementation
notes](docs/classifications/france_geppa.md), including the pinned coordinate
transcription and deferred package comparison, and [example samples](examples/france_samples.csv).

## German BK94 classification

**Germany (BK94) · 1994 · 31 classes** implements the fourth-edition German
texture triangle. Short codes keep its 31 regions readable; expand **Class
label key** under **About & methodology** for German names. Results and exports
retain both code and name. Inputs require a **0.063 mm sand/silt cutoff**;
switching views cannot convert laboratory fractions. See [German source and
implementation notes](docs/classifications/germany_bk94.md) and [example samples](examples/germany_samples.csv).

## Belgian classification

**Belgium · 1984 reference · 7 classes** implements the Belgian mineral-soil triangle using
codes Z, S, P, L, A, E and U. The expandable class label key and exports retain
French and Dutch names. Inputs use a **0.05 mm sand/silt cutoff**. The export
ID identifies the numerical transcription version. See [Belgian source and
implementation notes](docs/classifications/belgium.md) and [example samples](examples/belgium_samples.csv).

## European HYPRES classification

**Europe (HYPRES) · 1999 reference · 5 classes** provides Coarse, Medium, Medium fine, Fine and
Very fine mineral texture classes. It is separate from the FAO–UNESCO 1974
three-group option. Inputs use a **0.05 mm sand/silt cutoff**; organic horizons,
topsoil/subsoil distinctions and hydraulic-property estimates are outside this
view. See [HYPRES source and implementation notes](docs/classifications/europe_hypres.md)
and [example samples](examples/europe_hypres_samples.csv).

## French Aisne/Jamagne classification

**France (Aisne/Jamagne) · 1967 reference · 15 classes** implements the modified detailed Aisne
triangle as a separate option from GEPPA. Plot codes link to full French
names in the expandable key; exports retain both. Inputs use a **0.05 mm
sand/silt cutoff**. See [Aisne/Jamagne source and implementation notes](docs/classifications/france_aisne.md)
and [example samples](examples/france_aisne_samples.csv).

## Romanian SRTS 2003 texture view

**Romania (SRTS) · 2003 · 15 regions** uses Romanian codes and names. Three
regions combine coarse/medium/fine sand subclasses because the input totals
cannot distinguish them. Inputs require a **0.02 mm sand/silt cutoff**;
switching views cannot convert laboratory fractions. See [Romanian source,
grouping and implementation notes](docs/classifications/romania_srts2003.md)
and [example samples](examples/romania_samples.csv).

## ISSS classification

**ISSS · 1984 reference · 12 classes** adds a separate international texture triangle, including
Heavy clay and Light clay. Plot codes link to full English names in the key;
results and exports retain both. Inputs require a **0.02 mm sand/silt cutoff**.
This is a distinct classification, not USDA with different fraction metadata.
See [ISSS source and implementation notes](docs/classifications/isss.md) and
[example samples](examples/isss_samples.csv).

## Historical German classifications

Two additional German options are available separately from BK94:

- **Germany (SEA74) · 1974 · 13 classes** — historical forest-soil triangle.
- **Germany (TGL85) · 1985 · 14 classes** — historical agricultural-soil triangle.

Both use a **0.063 mm sand/silt cutoff**, with distinct geometries and codes.
TGL85 preserves the difference between `l''S`, `l'S` and `lS`. Code keys and
exports retain German names. See [SEA74 notes](docs/classifications/germany_sea74.md)
and [TGL85 notes](docs/classifications/germany_tgl85.md), plus
[SEA74 samples](examples/germany_sea74_samples.csv) and [TGL85 samples](examples/germany_tgl85_samples.csv).

## Historical USDA 1911 classification

**USDA (Whitney) · 1911 · 8 classes** is separate from the existing USDA option.
Its historical fractions use **clay <0.005 mm**, silt 0.005–0.05 mm and sand
0.05–2 mm; switching views cannot convert modern measurements. Source labels
are retained, including a documented silt-side `SaCL` naming issue awaiting
historical review. See [USDA 1911 source and implementation notes](docs/classifications/usda_1911.md)
and [example samples](examples/usda_1911_samples.csv).

## Polish PTG classification

**Poland (PTG) · 2008 · 16 classes** implements the PTG 2008 triangle, adopted
in 2008 and published in 2009. Plot codes link to Polish names in the key;
exports preserve diacritics. Inputs require a **0.05 mm sand/silt cutoff**.
This is separate from the older Polish schemes also found in soiltexture.
See [Polish source and implementation notes](docs/classifications/poland_ptg2008.md)
and [example samples](examples/poland_samples.csv).

## CSV format

The template uses these column names (the order may vary):

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
- In **Samples (map columns)** mode, choose four distinct source columns for
  the sample name and percentages. Other columns are explicitly listed as
  excluded in the preview. Headers must be nonblank and unique.
- Use a comma separator and a decimal point for fractional percentages.

**Downloaded results (8 columns)** mode accepts exactly the four sample columns
plus `classification`, `classification_system`, `classification_status`, and
`classification_candidates`, in any order. The four saved classification fields
are discarded, and current results are recalculated. This restores sample data,
not the previous system selection or undo history. Both modes offer Append and
Replace, with single-step Undo after import.
Sample names such as `001` and `NA` are preserved as text.

The preview shows the first 10 rows and up to 25 issues. **Download all errors**
exports every issue with its sample row number (excluding the header), field,
original value and explanation. Correct the source file and select it again;
no subset of an invalid file is imported. Changing CSV contents clears the staged
preview and requires selecting the file again.

Manual entries and uploads use the same measurement validation rules. Invalid
mappings, empty tables, blank sample names, nonnumeric percentages,
missing or infinite values, and percentages outside 0–100 are rejected. Invalid
totals report sample row numbers (excluding the CSV header). Rejected input
leaves existing samples intact; an upload is accepted only if all rows are valid.
The internal `read_soil_csv()` helper retains its strict four/eight-column schema
for programmatic callers; the interactive preview handles custom column mapping.

Totals use an absolute tolerance of `1e-8` percentage points to accommodate
floating-point arithmetic. Values are not normalized or rounded automatically.
This tolerance does not accommodate laboratory measurement or rounding error.

## Scientific status

This repository is a prototype. The polygon coordinates and class names are
stored per view in `R/classifications/`. Provenance for the original three
systems remains under review; Brazil, Canada, FAO–UNESCO, the UK, France, Germany, Belgium, HYPRES, Romania and ISSS have separate source notes.
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

## References and acknowledgements

We acknowledge Julien Moeys and the contributors to
**soiltexture: Functions for Soil Texture Plot, Classification and Transformation**
(R package, version 1.5.3, 2024),
[DOI: 10.32614/CRAN.package.soiltexture](https://doi.org/10.32614/CRAN.package.soiltexture).
Its [documentation and tutorial](https://cran.r-project.org/package=soiltexture)
are reference resources for comparing texture systems and particle-size
conventions. See the [classification reference notes](docs/classification.md#soiltexture-reference-and-acknowledgement)
for the scope of this comparison. A citation does not establish that this app's
original polygons or boundary assignments agree with the package.

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
| `tests/<system>.R` | System-specific reference cases and integration checks |
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
download handler under the original three systems. These are regression checks of the
current polygons, not validation against authoritative scientific references.

Results checks verify the empty state, ambiguous results, system switching,
export consistency, CSV template schema, clearing, and safe display of sample
names as text. They also check the live composition total and status badges.

Plotting checks build and draw the original three systems with samples and with an empty
dataset. They check the rendered graphics for every class label, sample name,
and axis label, and fail on rendering warnings or messages. They also exercise
the Shiny plot output. Class and sample text use explicit identity positioning
for compatibility with ggplot2 4 and ggtern 4. Crowded sample labels may still
overlap class labels; optional suppression reduces sample-to-sample label collisions.
Sample labels can also be hidden without removing points.

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

## Completed workspace improvements

The app separates definitions, validation, import inspection, classification,
plotting and UI code. Automated regression checks cover these modules and the
Shiny server. The workspace includes reversible sample edits, reviewed CSV
imports with column mapping and error downloads, search/sort/pagination, chart
highlighting and PNG export, and responsive layouts.

Keyboard users can skip to the workspace and focus scrollable results and CSV
preview tables. Chart images describe their system and sample count and direct
users to the equivalent Results table. Status labels supplement colour.

See [workspace quality checks](docs/workspace-quality.md) for the tested scope
and outstanding manual coverage.

## Remaining work

- Verify scientific sources, legacy polygon geometry and boundary conventions.
- Lock dependency versions and document reproducible deployment.
- Resolve licensing and attribution before wider distribution.
- Complete testing with assistive technology and across browsers. Semantic HTML
  and automated checks do not establish screen-reader compatibility or WCAG
  conformance. Large datasets can still make classification and chart rendering
  slow; pagination limits table rows, not the number of plotted samples. Hide
  sample labels for dense charts and use Results for exact values and long names.

The classification selector separates **Current** and **Historic** views and
sorts each group alphabetically. The Historic group contains FAO–UNESCO 1974,
SEA74, TGL85 and USDA 1911. Export IDs and the New Zealand default are unchanged.

Selector labels consistently show **main name (scheme) · year · class/group
count**. `Year unverified` marks definitions without an established edition
year; reference years are explicitly labelled. Romania retains `15 regions`
because its sand-size subclasses are grouped.

The five previously undated options now show verified **reference publication
years**: New Zealand 1995, USDA 1951, Belgium 1984, Aisne/Jamagne 1967 and
Australia 2018. These do not establish the exact provenance of legacy polygon
coordinates. See [year evidence and limitations](docs/classification-years.md).
