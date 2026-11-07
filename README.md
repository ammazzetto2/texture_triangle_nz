# Soil Texture Triangle

Explore soil composition, plot samples on texture triangles, and classify them
using **22 current and historic views** in an R Shiny workspace.

Enter samples manually or import a CSV, inspect ambiguous classifications,
and export results or a high-resolution chart.

[Quick start](#quick-start) · [Supported systems](#supported-classifications) ·
[User guide](docs/user-guide.md) · [Contributing](Contributing.md) ·
[MIT license](Licensing.md)

## Features

- **Multiple classification systems:** country-specific and international
  triangles, with edition labels, source notes and class-name keys.
- **Reviewed CSV imports:** column mapping, validation previews, downloadable
  error reports, and append or replace options.
- **Editable samples:** manual entry, a remaining-percentage calculator,
  row-level edits and deletion, and single-step undo.
- **Transparent results:** classes, boundary candidates, overlaps and
  unclassified samples, with search, sorting and review filters.
- **Chart tools:** sample highlighting, label controls, enlarged charts and
  3000 × 2700 pixel PNG downloads.
- **CSV exports:** every sample's composition, classification system, result
  status and candidate classes.

## Quick start

Install **R 4.1 or newer**, clone this repository, and run from its root folder:

```sh
git clone https://github.com/ammazzetto2/texture_triangle_nz.git
cd texture_triangle_nz
Rscript run_app.R
```

Alternatively, open the project folder in R or RStudio and run:

```r
source("run_app.R")
```

Startup checks for `shiny`, `bslib`, `ggplot2`, `ggtern`, `dplyr` and `pracma`.
Missing packages are installed from CRAN into the Git-ignored `.R-library/`
folder; available, loadable packages are reused. First-time installation needs
internet access and may require system build tools. Dependency versions are
not yet locked.

RStudio opens the app in a browser; terminal startup prints a local URL.
Stop the app with Escape in RStudio or Ctrl+C in the terminal.

## Basic workflow

1. Choose a classification system and check its particle-size requirements.
2. Enter a sample or upload a CSV, review the preview, and confirm the import.
3. Inspect the **Triangle** and **Results** tabs. Use **need review** to find
   samples without a single assigned class.
4. Download your results as CSV or save the chart as PNG.

Samples remain in the current session. Export your data before closing it.
See the [user guide](docs/user-guide.md) for import modes, editing, undo,
chart controls and results navigation.

### Input format

Use percentages from 0 to 100, with sand + silt + clay totalling 100 per row:

```csv
soil,sand,silt,clay
Sample A,50,25,25
Sample B,20,20,60
Sample C,90,5,5
```

Start with the [example CSV](examples/soil_samples.csv) or download the template
inside the app. Custom CSV columns can be mapped during import. Exported
results can also be reopened; classifications are recalculated using the
currently selected system.

**Switching systems does not convert measurements.** Particle-size cutoffs
and sample bases vary between systems. Use measurements compatible with the
selected view. Values are not automatically normalised or rounded; input totals
use a numerical tolerance of `1e-8` percentage points.

## Supported classifications

The selector groups views under **Current** and **Historic**, alphabetically.
These groups organise the app; consult each source note for its edition and
scope. A **reference year** identifies a cited publication, not necessarily
the origin of the stored polygons. Counts refer to texture classes, groups
or grouped regions, rather than full soil taxonomies.

| System / view | Edition or reference | Classes / groups | Source and scope |
| --- | --- | --- | --- |
| New Zealand | 1995 reference | 11 classes | [Legacy review](docs/classification.md) |
| USDA | 1951 reference | 12 classes | [Legacy review](docs/classification.md) |
| Australia | 2018 reference | 11 classes | [Known geometry issues](docs/classification.md) |
| Brazil — SiBCS | 2013 reference | 13 classes | [Brazil notes](docs/classifications/brazil.md) |
| Brazil — Lemos & Santos | 1996 reference | 5 groups | [Brazil notes](docs/classifications/brazil.md) |
| Brazil — SiBCS texture subgroups | 2013 | 8 classes | [Eight-class view](docs/classifications/brazil_sibcs2013_8.md) |
| Canada — CSSC | 1998 | 13 classes | [Canadian notes](docs/classifications/canada.md) |
| UK — TIN037 | 2008 | 11 classes | [Mineral-soil scope](docs/classifications/uk_tin037.md) |
| France — GEPPA | 1963 | 17 classes | [GEPPA notes](docs/classifications/france_geppa.md) |
| France — Aisne/Jamagne | 1967 reference | 15 classes | [Aisne/Jamagne notes](docs/classifications/france_aisne.md) |
| Germany — BK94 | 1994 | 31 classes | [BK94 notes](docs/classifications/germany_bk94.md) |
| Belgium | 1984 reference | 7 classes | [Bilingual class names](docs/classifications/belgium.md) |
| Europe — HYPRES | 1999 reference | 5 classes | [Mineral texture groups](docs/classifications/europe_hypres.md) |
| Romania — SRTS | 2003 | 15 regions | [Grouped sand-size subclasses](docs/classifications/romania_srts2003.md) |
| ISSS — also used in Japan | 1984 reference | 12 classes | [Japanese-source comparison](docs/classifications/isss.md) |
| Poland — PTG | 2008 | 16 classes | [Polish notes](docs/classifications/poland_ptg2008.md) |
| Switzerland — FAL | 1997 | 13 classes | [Swiss mineral-soil scope](docs/classifications/switzerland_fal1997.md) |
| FAO–UNESCO **(Historic)** | 1974 | 3 groups | [Soil Map of the World groups](docs/classifications/fao_1974.md) |
| Germany — SEA74 **(Historic)** | 1974 | 13 classes | [Forest-soil scheme](docs/classifications/germany_sea74.md) |
| Germany — TGL85 **(Historic)** | 1985 | 14 classes | [Agricultural-soil scheme](docs/classifications/germany_tgl85.md) |
| USDA — Whitney **(Historic)** | 1911 | 8 classes | [Historical fractions and labels](docs/classifications/usda_1911.md) |
| Netherlands — NEN 5104 **(Historic; mineral only)** | 1989 | 14 classes | [Withdrawn standard and exclusions](docs/classifications/netherlands_nen5104.md) |

The Swiss FAL view is distinct from the ten-class Zurich variant. The Japanese
international-method geometry is covered by ISSS; the separate Japanese
five-class method is not included. The Dutch view implements the withdrawn
NEN 5104 mineral triangle, excluding organic-matter and gravel classifications;
it does not implement today's ISO 14688/Dutch supplements.

## Scientific status and limitations

This is a **research prototype**. Source review is ongoing, particularly for
the original New Zealand, USDA and Australian polygons. Their particle-size
requirements are not yet documented in the app definitions. The Australian
geometry contains confirmed overlaps, including Sand / Sandy Loam.

The app reports ambiguity explicitly:

| Status | Meaning |
| --- | --- |
| `classified` | One polygon interior matches. |
| `boundary` | The sample lies on an edge or vertex. One candidate receives its class; multiple candidates are listed without a single assigned class. |
| `overlap` | Multiple polygon interiors match; candidates are listed without choosing a class. |
| `unclassified` | No polygon matches. |

Shared-boundary handling is an app convention, not a claim that every source
uses the same equality rules. Polygon order never resolves an ambiguous result.
Automated geometry and integration tests do not, by themselves, establish
scientific accuracy.

Read the [classification policy and known issues](docs/classification.md),
[edition-year evidence](docs/classification-years.md), and
[system-specific source notes](docs/classifications/).

## Documentation

| Guide | Contents |
| --- | --- |
| [User guide](docs/user-guide.md) | Sample entry, CSV imports, editing, results and chart tools |
| [Classification methodology](docs/classification.md) | Boundary policy, provenance and scientific limitations |
| [Adding a classification](docs/adding-classifications.md) | Definition schema, source requirements and verification |
| [Workspace quality](docs/workspace-quality.md) | Tested behaviour and remaining manual coverage |
| [Contributing](Contributing.md) | Issues, development setup and pull requests |

## Development and tests

Run the automated checks from the repository root:

```sh
Rscript --vanilla tests/run_all.R
```

The runner discovers test scripts and executes them in separate R sessions.
Checks cover validation, imports, classification geometry, source-based
reference cases, rendering and Shiny integration. Run an individual check with,
for example, `Rscript --vanilla tests/japan_isss.R`. Tests use the same dependency
setup as the app.

| Path | Purpose |
| --- | --- |
| `run_app.R` | Local launcher and dependency setup |
| `soil_triangle.R` | Shiny server and application entry point |
| `R/classifications/` | Per-view polygons, metadata, colours and labels |
| `R/` | Shared classification, validation, import, plotting and UI modules |
| `tests/` | Automated checks and reference fixtures |
| `examples/` | Ready-to-upload sample CSVs |
| `docs/` | User, scientific and maintenance documentation |
| `www/` | Local styles, methodology page and branding assets |

Contributions are welcome. Read [Contributing.md](Contributing.md) before
opening an issue or pull request, especially for changes to scientific
boundaries or measurement conventions.

## References and acknowledgements

We acknowledge **Julien Moeys and the contributors to soiltexture**,
*Functions for Soil Texture Plot, Classification and Transformation*,
R package version 1.5.3 (2024).
[Package documentation](https://cran.r-project.org/package=soiltexture) ·
[DOI: 10.32614/CRAN.package.soiltexture](https://doi.org/10.32614/CRAN.package.soiltexture).

The package is a reference for texture-system comparisons and a documented
numerical source for several views. It is not a runtime dependency. Original
source publications, transcription versions and contributors are acknowledged
in the [classification notes](docs/classifications/). Acknowledgement does not
establish that every polygon or equality rule agrees with the package.

## License

Original project code and documentation are available under the
[MIT License](Licensing.md). Third-party packages, reference materials and
branding retain their respective licenses and rights; see
[licensing and attribution notes](Licensing.md#third-party-materials).
