# Adding and maintaining texture classifications

## Organisation

```text
R/
  classifications/             # One definition per system/edition/view
    new_zealand.R
    usda.R
    australia.R
    brazil_13.R
    brazil_groups.R
    canada.R
    fao_1974.R
    uk_tin037.R
    france_geppa.R
    germany_bk94.R
    belgium.R
  classification_systems.R     # Discovery, definition schema, polygon helper
  classification.R             # Shared point classification and export schema
  plotting.R                   # Shared renderer; no country-specific branches
  ui.R                         # UI consumes the discovered registry
tests/
  fixtures/
    brazil.csv                 # Independent reference compositions and classes
    canada.csv
    fao_1974.csv
    uk_tin037.csv
    france_geppa.csv
    germany_bk94.csv
    belgium.csv
  brazil.R                     # Country-specific scientific checks
  canada.R
  fao_1974.R
  uk_tin037.R
  france_geppa.R
  germany_bk94.R
  belgium.R
  definitions.R                # Geometry/schema checks for every discovered view
  plotting.R                   # Rendering checks for every discovered view
  run_all.R                    # Discovers and runs test scripts in separate R sessions
docs/
  classifications/
    brazil.md
    canada.md
    fao_1974.md
    uk_tin037.md
    france_geppa.md
    germany_bk94.md
    belgium.md
  classification.md            # Shared boundary policy and legacy issues
  adding-classifications.md    # This guide
```

The original three polygon datasets were moved without changing their numeric
coordinates or class labels. Every existing view also retains its export ID,
colour mapping, and label settings. The old monolithic data files were removed
so there is only one authoritative definition for each view.

## Definition contract

Each `R/classifications/*.R` file returns one list. Its local variables do not
leak into another definition. Use `canada.R` as a readable starting point.

| Field | Purpose |
| --- | --- |
| `id` | Stable exported identifier, including edition for newly sourced systems |
| `display` | Unique short label in the app selector |
| `order` | Numeric selector order; independent of filenames |
| `clockwise` | Axis progression direction |
| `data` | Polygon rows: numeric `Sand`, `Silt`, `Clay` fractions and character `Label` |
| `colours` | One named hex colour per canonical class label |
| `label_size` | Optional default class-label size, in mm; defaults to 4 |
| `label_overrides` | Optional named class settings: `text`, `angle`, and/or `size` |
| `source` | Publication, edition, and figure/page description |
| `source_url` | Primary source link shown in the app |
| `fractions` | Laboratory particle-size definitions and relevant units |

Source fields must be supplied together. The legacy definitions deliberately
omit them because provenance remains under review; a newly added system should
always document its source and fractions. Unknown or duplicate fields, missing
colours, malformed coordinates, and label overrides for nonexistent classes
fail at startup with the offending filename.

`texture_polygons()` converts a named list of `(sand %, clay %)` vertex pairs
to the common fractional data schema. It derives silt by difference. List
vertices in polygon-edge order; do not sort them by component value.

Keep canonical class names in `Label`. Use `label_overrides$text` for display-only
line wrapping, so new CSV class names remain clean. Palette and override keys
use labels with repeated whitespace collapsed to single spaces; this also
supports the original legacy plot labels. The loader adds `definition_file`
for diagnostics; definitions do not need to set it themselves.

Dense triangles can use short codes in `label_overrides$text` while retaining
full names in `Label` for results and exports. `classification_label_key()`
automatically supplies an expandable full-name key under About & methodology
when display labels differ beyond ordinary line wrapping. Germany's BK94
file demonstrates this; no country-specific UI logic is needed.

## Workflow for another system

1. Establish the primary publication, edition, fraction cutoffs, texture class
   names, and exact polygon limits. A country name alone is not a specification.
2. Add one definition file with all geometry, source metadata, colours, and label
   settings. It is automatically discovered by the loader, UI, classifier,
   exports, and common rendering tests. No central country list needs editing.
3. Add independent reference compositions in `tests/fixtures/<system>.csv` and
   a `tests/<system>.R` script covering every class and important limits.
   The runner discovers that test script automatically.
4. Document derivation, boundary behavior, limitations, and sources in
   `docs/classifications/<system>.md`; add a normal four-column sample CSV in
   `examples/` if helpful. Update the public methodology summary as needed.
5. Run `Rscript --vanilla tests/run_all.R`. Inspect rendered previews at the
   app's usual plot size; text being present does not guarantee it is unclipped
   or readable.

Preserve existing IDs when moving files or adjusting display styling. A new
scientific edition or substantially different view should get its own ID so
exported results remain traceable. Do not derive one country's definition from
another country's mutable object, even when their present boundaries coincide.

## Shared checks and limits

Every discovered definition is checked at startup for its schema, finite
fractional coordinates, per-vertex totals, minimum polygon size, label settings,
and complete colours. Common tests add positive geometry/area checks,
whole-percentage grid coverage, polygon-order independence, and class-label
rendering. The original Australian area excess and overlap are an explicit,
documented legacy exception, not a default allowed for new systems.

Country reference tests remain important: generic shape checks cannot establish
scientific correctness. Interior comparisons use independent analytical rules;
the app's shared-edge candidate policy intentionally leaves ambiguous borders
without a single class. Changes to that policy belong in the shared classifier
with explicit tests and documentation, rather than hidden country branches.
