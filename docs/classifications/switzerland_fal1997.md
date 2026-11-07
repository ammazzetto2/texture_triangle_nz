# Switzerland: FAL 1997, 13 texture classes

## Primary source and edition

Brunner, J., Jäggli, F., Nievergelt, J. and Peyer, K. (1997), *Kartieren und
Beurteilen von Landwirtschaftsböden*, Schriftenreihe der FAL 24, ISBN
3-905608-14-8. The official [Agroscope publication record](https://ira.agroscope.ch/en-US/publication/17770)
provides the [full manual](https://ira.agroscope.ch/en-US/Page/Einzelpublikation/Download?einzelpublikationId=19386).

The implementation follows section **3.5**, Tables **3.5a and 3.5b**, and
Figure **3.5a** (section pages 3.5-1 and 3.5-2; PDF pages 34–35).
These pages were downloaded, rendered and inspected on 7 November 2026.
The table supplies numerical class limits, so the boundaries are derived
analytically rather than estimated from image pixels. No third-party polygon
dataset or package function is copied or required.

Selector: **Switzerland (FAL) · 1997 · 13 classes**.
Stable export ID: `Switzerland (FAL 1997, 13 classes)`.
This names the implemented edition and does not claim to implement all later
Swiss classification revisions or canton-specific mapping conventions.

## Inputs and scope

Use **mass percentages of mineral fine earth below 2 mm**, excluding organic
matter and coarse fragments, with:

- sand: 0.05–2 mm;
- silt: 0.002–0.05 mm;
- clay: <0.002 mm.

Table 3.5b explicitly uses mineral fine-earth weight percentages. The three
fractions must total 100. Whole-soil volume estimates, or percentages including
organic matter, cannot be used as though they were this mineral composition.
Switching systems does not convert or rebase measurements.

Only the 13 basic texture classes are assigned. Sand-size fractions, organic
content, coarse fragments, soil taxonomy and agricultural suitability require
additional measurements and are outside this view.

## Classes and geometry

Let C be clay and Z be silt, in percent. The following are **strict interior**
conditions. Boundary lines belong to all adjacent polygons for candidate
detection; the table below does not specify scientific equality ownership.

| Plot code | Full German name | Interior conditions |
| --- | --- | --- |
| S | Sand | C < 5; Z < 15 |
| uS | Schluffiger Sand | C < 5; 15 < Z < 50 |
| lS | Lehmiger Sand | 5 < C < 10; Z < 50 |
| lrS | Lehmreicher Sand | 10 < C < 15; Z < 50 |
| sL | Sandiger Lehm | 15 < C < 20; Z < 50 |
| L | Lehm | 20 < C < 30; Z < 50 |
| tL | Toniger Lehm | 30 < C < 40; Z < 50 |
| lT | Lehmiger Ton | 40 < C < 50; Z < 50 |
| T | Ton | C > 50 |
| sU | Sandiger Schluff | C < 10; 50 < Z < 70 |
| U | Schluff | C < 10; Z > 70 |
| lU | Lehmiger Schluff | 10 < C < 30; Z > 50 |
| tU | Toniger Schluff | 30 < C < 50; Z > 50 |

Results and exports retain code plus name. Plot codes have an expandable
full-name key. The equilateral display preserves the source compositions.
At 15% clay and 25% silt, for example, the result has candidates
`lrS · Lehmreicher Sand; sL · Sandiger Lehm`, status `boundary`, and no
single class. Pure sand, silt and clay have unique candidates S, U and T.

## Comparison and scientific review

The `SWISS` option in ggsoiltexture 1.1.1 uses a **ten-class Canton Zurich**
dataset. It merges three distinctions present in FAL 1997: S/uS, lrS/sL,
and sU/U. It is not the numerical source of this implementation. The source
manual's section 3.5 is used consistently for names and limits.

Specific source-review issues, including differences elsewhere in the manual,
the comparison dataset's attribution and unresolved equality conventions,
are recorded separately in `SCIENTIFIC_REVIEW_DRAFT.md`.

## Validation

- `tests/fixtures/switzerland_fal1997.csv`: a composition for each of the 13
  classes, expected from the primary numerical table.
- `tests/switzerland_fal1997.R`: all class fixtures, 10,000 reproducible random
  compositions checked against independent table-based rules, all 18 internal
  edge segments and both sides, corners, class key, fraction/source metadata,
  example CSV, Shiny results and exported classifications.
- Common schema, coverage, order-independence and rendering tests discover
  this definition automatically, including the 5,151-point composition grid.
- Continuous polygon checks verify validity, simplex coverage and the absence
  of positive-area overlaps. The class codes were visually inspected in the
  rendered triangle.

These checks establish implementation fidelity to the chosen source section.
They do not resolve every equality convention or validate laboratory methods.
Example upload: [Swiss samples](../../examples/switzerland_samples.csv).
