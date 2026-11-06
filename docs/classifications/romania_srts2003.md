# Romania: SRTS 2003 texture view, 15 regions

## Sources and identity

Numerical geometry: `ROM.TT`, labelled **SRTS 2003**, in **soiltexture 1.5.3**,
by Julien Moeys and contributors. The Romanian definition credits a 2010
contribution by Bogdan Rosca, Romanian Academy, Iași. The [source is pinned
to revision db3bfb683b420989422690f3e18188b923740e40](https://github.com/cran/soiltexture/blob/db3bfb683b420989422690f3e18188b923740e40/R/soiltexture.R#L1201).
Only factual vertices and class membership are transcribed; no package
functions are bundled or executed. The source package identifies its license
as AGPL (>=3).

Supporting Romanian reference: [USAMV Bucharest, Pedologia, section 7.1.1,
Table 7.1, printed/PDF page 39](https://horticultura-bucuresti.ro/site-vechi/images/pdf/Pedologia.pdf#page=39).
This table supplies Romanian terminology, fraction cutoffs and sand-size
subclasses. It attributes the textural table to ICPA methodology (1987);
it is supporting background, not independent proof of the exact ROM.TT
polygon limits or a reproduction of the original 2003 publication. The
original SRTS 2003 publication has not been independently retrieved here.

Selector: **Romania · SRTS 2003 (15 regions)**.
Stable export ID: `Romania (SRTS 2003, ROM.TT 1.5.3, 15 regions)`.
The edition and numerical transcription are both identified. This is a
texture view, not a complete implementation of Romanian soil taxonomy.

## Regions and grouped sand subclasses

| Code | Romanian name |
| --- | --- |
| AF | Argilă fină |
| AA | Argilă medie |
| AP | Argilă prăfoasă |
| AL | Argilă lutoasă |
| TP | Lut argilo-prăfos |
| TT | Lut argilos mediu |
| TN | Argilă nisipoasă |
| LP | Lut prăfos |
| LL | Lut mediu |
| LN | Lut nisipo-argilos |
| SP | Praf |
| SS | Lut nisipos prăfos |
| SG+SM+SF | Lut nisipos |
| UG+UM+UF | Nisip lutos |
| NG+NM+NF | Nisip |

ROM.TT combines each set of coarse, medium and fine sand subclasses into one
region. Choosing among G, M and F would require information about the internal
sand-size distribution, which the app does not collect. The combined codes
are therefore preserved in the plot, key, results and exports; no individual
subclass is inferred. The app calls this **15 regions** rather than implying
that it implements every detailed SRTS subclass separately.

The plot uses codes. **About & methodology → Class label key** expands to
Romanian names, with diacritics retained in results and CSV exports.

## Inputs and numerical limits

Use fine-earth percentages (<2 mm): **sand (nisip) 0.02–2 mm**, **silt (praf)
0.002–0.02 mm**, **clay (argilă) <0.002 mm**. The 0.02 mm sand/silt cutoff
is different from the 0.05, 0.06 and 0.063 mm options in other views. Selecting
this system does not convert laboratory fractions.

`R/classifications/romania_srts2003.R` stores common vertices once in
(silt %, clay %) coordinates and derives sand by difference. The shared
renderer preserves compositions in the standard equilateral layout.

The continuous polygon limits follow the pinned ROM.TT transcription,
including 5%, 12%, 20%, 33%, 45%, 60% and 70% clay breaks. Supporting printed
tables use integer reporting intervals (for example 61–70 and >71) and
occasionally 32/33 silt wording. Those are not silently substituted for the
continuous polygon geometry. Independent reconciliation with the original
publication is part of future scientific verification.

Shared edges retain the app's candidate policy. At 15% sand, 15% silt and
70% clay, the result is `boundary`, candidates AA and AF, with no single
class. Pure sand, clay and silt classify uniquely as NG+NM+NF, AF and SP.

## Implementation checks

- `tests/fixtures/romania_srts2003.csv`: an interior for every region.
- `tests/romania_srts2003.R`: those cases, combined sand codes, the Romanian
  key and accented CSV round trips, a boundary and nearby values, corners,
  example CSV, metadata and Shiny integration.
- Shared tests automatically cover area, 5,151-point coverage, gaps/overlaps,
  polygon-order independence and plot rendering.

These are implementation and regression checks. Broader scientific validation
and package comparisons remain deferred; soiltexture is not a project dependency.

Example upload: `examples/romania_samples.csv`.
