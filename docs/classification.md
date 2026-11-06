# Classification behavior and source review

## Current software policy

The app discovers per-view definitions from `R/classifications/`. The original
NZ, USDA, and Australian coordinates are preserved there alongside the
source-derived Brazilian and Canadian definitions.
The following is a transparent software policy, not a claim that the exact
boundary conventions of all supported scientific systems have been verified.

| Matches | Classification | Status |
| --- | --- | --- |
| One polygon interior | That class | `classified` |
| One polygon edge, no other polygon | That class | `boundary` |
| Shared edge or vertex with multiple candidates | `NA` | `boundary` |
| More than one polygon interior | `NA` | `overlap` |
| No polygon | `NA` | `unclassified` |

If a point is on one polygon's edge and inside another, it is also reported
as a shared boundary with no single class. If more than one interior matches,
`overlap` takes precedence. No match is selected by polygon iteration order.

`classification_candidates` lists matching class labels in sorted order,
separated by `; `. Labels retain their existing plot line breaks. An empty
candidate field means there was no match. The CSV retains `classification`
and `classification_system` and adds `classification_status` and
`classification_candidates`.

Edge detection measures distance to each polygon segment in the sand/clay
coordinate plane, using a tolerance of `1e-10` in fraction units. This is a
numerical tolerance, not a buffer for uncertain laboratory measurements.
Points within it are treated as on the edge; percentages are never adjusted.

## Verified software examples

- Pure sand and pure clay classify as Sand and Clay in the original three systems.
  Canada uses Heavy Clay for pure clay; Brazil uses its Portuguese class names.
- Pure silt is Silt in the existing NZ and USDA polygons, and Silty Loam in the
  existing Australian polygons. The latter is a property of this dataset and
  still needs scientific verification.
- NZ 20% sand, 20% silt, 60% clay lies on the Clay / Loamy Clay boundary.
- Australian 90.5% sand, 1.3% silt, 8.2% clay lies inside both Sand and Sandy
  Loam. It is now exported with status `overlap`, both candidates, and no single
  classification. Previously the last polygon silently won.

All vertices are in range and sum to one. The combined polygon area is 0.5 for
NZ and USDA and 0.50025 for Australia, compared with 0.5 for the full triangle.
The Australian overlap remains in the plot and data; coordinates have not
been changed without confirming their intended source.

Whole-percentage sampling covers 5,151 compositions per system without an
unmatched sample. This sampling and area totals do not prove that there are
no small gaps or additional overlaps between grid points.

## References reviewed

Reviewed on 5 November 2026. These are reference leads, not established
provenance for the repository's original coordinate arrays.

- [Manaaki Whenua — Soil description](https://soils.landcareresearch.co.nz/topics/soil-classification/soil-description)
  explains texture estimation and includes a texture triangle. It points to
  the Soil Description Handbook for New Zealand. The intended handbook edition
  for this app's original data has not been established.
- [USDA NRCS — Soil Texture Calculator](https://www.nrcs.usda.gov/resources/education-and-teaching-materials/soil-texture-calculator)
  provides official texture calculation resources and downloadable workbooks.
  This app has not yet been checked against their calculation logic.
- [SoilsWest — How To Test Soil Texture](https://soilqualityknowledgebase.org.au/soil-texture/)
  publishes an Australian texture diagram attributed to Pluske, Boggs and
  Leopold (2018), *Soil Quality: 2 Integrated Soil Management*. It does not
  establish the provenance or exact coordinates of this repository's polygons.

## Remaining scientific work

The two Brazilian views added on 6 November 2026 have separate source and
validation notes in [Brazilian classifications](classifications/brazil.md). Both use SiBCS
2025 and retain the shared-boundary candidate policy described above. The
Canadian source and validation notes are in [Canadian classification](classifications/canada.md).
The remaining provenance work below concerns the original three systems.

1. Identify the original diagram, edition, and particle-size definitions for
   each system, including the reference workbooks in `old_files/excel/`.
2. Compare every coordinate and class label against those sources. In
   particular, investigate the Australian Sand / Loamy Sand / Sandy Loam region.
3. Establish source-backed inequalities for assigning exact shared boundaries
   when a single-class result is required.
4. Add independent reference samples and exhaustive geometry checks before
   describing the data as scientifically verified.

## FAO–UNESCO map groups

The historical three-group view is sourced to the 1974 Soil Map of the World
legend. Its definition, fraction convention, step boundary and checks are
recorded in [FAO–UNESCO source notes](classifications/fao_1974.md).

## UK mineral-soil classes

The 11-class UK view follows Natural England TIN037 (first edition, 2008).
Its 0.06 mm sand/silt cutoff differs from several other views. See
[UK source and validation notes](classifications/uk_tin037.md) for scope,
polygon derivation and checks.
