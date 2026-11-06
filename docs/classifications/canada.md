# Canada: 13 texture classes

## Source and edition

- [The Canadian System of Soil Classification, third edition (1998)](https://sis.agr.gc.ca/cansis/taxa/cssc3/index.html)
- [Chapter 17, Figure 42: Soil texture classes triangle](https://sis.agr.gc.ca/cansis/taxa/cssc3/chpt17.html)
- [AAFC glossary: texture, class limits, and Heavy Clay](https://sis.agr.gc.ca/cansis/glossary/t/index.html)

The diagram and numerical definitions were reviewed on 6 November 2026.
The polygons are an original implementation of those published definitions;
no third-party software or digitised package dataset is copied or required.

## Supported view

The option is **Canada · 13 classes**, exported as
`Canada (CSSC 1998, 13 classes)`:

Heavy Clay, Clay, Silty Clay, Sandy Clay, Clay Loam, Silty Clay Loam,
Sandy Clay Loam, Loam, Sandy Loam, Silt Loam, Silt, Loamy Sand, and Sand.

Heavy Clay covers compositions above 60% clay. The main boundaries use the
published analytical limits, including 7%, 12%, 27%, 28%, and 52%, rather than
rounding the small reference image. The polygons are defined independently in
`R/classifications/canada.R`; they do not depend on the Brazilian or original
USDA data objects. Plot wrapping and English title capitalisation do not alter
the underlying class distinctions.

Only the main texture classes are supported. Sand-size subclasses, coarse
fragment modifiers, organic-soil qualifications, and full Canadian soil
taxonomy require additional information beyond sand/silt/clay percentages.

## Laboratory fractions

Enter mass percentages of the fine-earth fraction (<2 mm). Chapter 17 lists
sand grades down to 0.05 mm, silt as 0.05–0.002 mm, and clay as ≤0.002 mm.
The three input percentages must total 100. Selecting Canada does not convert
measurements made using another particle-size convention.

## Shared-edge policy

The app continues to report candidate classes on shared polygon edges, rather
than applying a country-specific inequality tie-break. For example, exactly
60% clay with 20% sand and 20% silt returns `boundary`, candidates
`Clay; Heavy Clay`, and no single classification. Values on either side of
that boundary classify as Clay or Heavy Clay. Pure clay classifies as Heavy
Clay; pure sand and silt classify as Sand and Silt.

This policy is documented software behavior, not a claim that the source uses
the same tie-breaking convention at every boundary.

## Checks

- `tests/fixtures/canada.csv`: an independent reference composition per class.
- `tests/canada.R`: those 13 cases, 10,000 reproducible random compositions
  compared against analytical definitions, selected boundaries, metadata,
  results, empty downloads, and versioned Shiny CSV exports.
- `tests/definitions.R`: area, class centers, whole-percentage grid coverage,
  and order independence for all discovered definitions.
- `tests/plotting.R`: all class/axis/sample labels and warning-free rendering.

An upload example is available in `examples/canada_samples.csv`. The sample at
exactly 60% clay intentionally demonstrates the shared-boundary behavior.
