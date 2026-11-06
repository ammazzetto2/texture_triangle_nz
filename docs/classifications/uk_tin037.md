# UK mineral soils: 11 classes (TIN037, 2008)

## Source and scope

Primary reference: [Natural England Technical Information Note TIN037,
Soil texture, first edition, 21 February 2008](https://publications.naturalengland.org.uk/file/83081).
Figure 1 and Table 1 on page 1 define the triangle and particle-size fractions;
Table 2 on page 2 lists the class names. The note attributes the system to the
former Soil Survey of England and Wales.

The app implements only the 11 main mineral-soil classes. Organic mineral,
peat and calcareous soil classifications in the note's appendix are excluded,
as are sand-size prefixes and medium/heavy clay-loam subdivisions. Sand, silt
and clay alone cannot determine these modifiers. The app does not test organic
matter or carbonate content to establish sample suitability.

Selector: **UK (TIN037) · 2008 · 11 classes**.
Stable export ID: `UK (TIN037 2008, 11 classes)`.

## Particle-size convention

Use percentages of sand **0.06–2 mm**, silt **0.002–0.06 mm** and clay
**<0.002 mm**, totalling 100. These are the fractions printed in TIN037, not a
rounded display of the 0.05 mm cutoff used by several other app options.
Switching the selector cannot convert measurements between these conventions.
The selected source and fraction description appear under About & methodology.

## Polygon derivation

`R/classifications/uk_tin037.R` contains independent coordinates read from
Figure 1's labelled straight boundaries. The following equations describe
strict interiors; all values are percentages. Write sand as S, silt as Z and
clay as C.

| Class | Interior limits |
| --- | --- |
| Sand | Z + 1.5C < 15 |
| Loamy Sand | Z + 1.5C > 15 and Z + 2C < 30 |
| Sandy Loam | C < 18, S > 50, Z + 2C > 30 |
| Sandy Silt Loam | C < 18, 20 < S < 50 |
| Silt Loam | C < 18, S < 20 |
| Sandy Clay Loam | 18 < C < 30, S > 50 |
| Clay Loam | 18 < C < 35, 20 < S < 50, and either C < 30 or Z > 20 |
| Silty Clay Loam | 18 < C < 35, S < 20 |
| Sandy Clay | C > 30, S > 45, and either S > 50 or Z < 20 |
| Clay | C > 35, S < 45, Z < 45 |
| Silty Clay | C > 35, Z > 45 |

The short Sandy Clay/Clay Loam segment joins (50% sand, 30% clay) to
(45% sand, 35% clay), following constant 20% silt. It is not a continuation
of the 50% sand boundary. This feature, the 30% clay division, and Sandy Silt
Loam distinguish this view from USDA. No geometry is imported from another
country's definition.

As in other views, polygons include their edges for candidate detection.
Shared edges return `boundary`, all candidates and no single class. Unique
outer corners classify as Sand, Clay and Silt Loam.

## Verification

- `tests/fixtures/uk_tin037.csv` supplies interiors for all 11 classes plus
  compositions on either side of the short Sandy Clay/Clay Loam shoulder.
- `tests/uk_tin037.R` compares 10,000 reproducible random compositions against
  an independent analytical interpretation of the diagram. It also checks
  all 15 internal edges and nearby values on both sides, corners, source/fraction
  metadata, Shiny results and CSV exports.
- Shared tests automatically cover geometry, full triangle area, 5,151 grid
  compositions, absence of gaps/overlaps, polygon-order independence and
  warning-free rendering.

An upload example is available at `examples/uk_samples.csv`.
