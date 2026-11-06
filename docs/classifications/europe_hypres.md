# Europe: HYPRES five mineral texture classes

## Sources and identity

Scientific background: [European Commission ESDAC, HYPRES metadata](https://esdac.jrc.ec.europa.eu/ESDB_Archive/ESDBv2/popup/hy_meta.htm).
This describes five mineral texture classes used with the European Soil Map,
plus additional topsoil/subsoil and organic categories in the wider HYPRES
database. The [Wösten et al. (1999) publication record](https://research.wur.nl/en/publications/development-and-use-of-a-database-of-hydraulic-properties-of-euro/)
provides the original database study and DOI.

Numerical geometry: `HYPRES.TT` in **soiltexture 1.5.3**, by Julien Moeys and
contributors. The [source is pinned to revision
db3bfb683b420989422690f3e18188b923740e40](https://github.com/cran/soiltexture/blob/db3bfb683b420989422690f3e18188b923740e40/R/soiltexture.R#L374).
Only factual polygon limits are transcribed; no package functions are bundled
or executed. The source package identifies its license as AGPL (>=3).
The original HYPRES report's numerical diagram has not been independently
retrieved for this implementation. Package-wide comparison remains deferred.

Selector: **Europe (HYPRES) · 1999 reference · 5 classes**.
Stable export ID: `Europe (HYPRES.TT 1.5.3, 5 classes)`.
The version identifies the numerical transcription, not a claimed scientific
publication year or latest edition of the European Soil Map.

## Classes and scope

The following limits describe strict polygon interiors, in percentages.

| Class | Limits |
| --- | --- |
| Coarse | Clay below 18%, sand above 65% |
| Medium | Clay below 35%, sand above 15%, outside the coarse region |
| Medium fine | Clay below 35%, sand below 15% |
| Fine | Clay between 35% and 60% |
| Very fine | Clay above 60% |

The coarse/medium edge has a step: a 65% sand segment below 18% clay and an
18% clay segment up to the outer edge at 82% sand. The medium/medium-fine
edge follows **15% sand**, not a fixed silt percentage.

This is a five-class mineral texture view. It does not identify organic
horizons, distinguish topsoil from subsoil or estimate hydraulic properties.
Those require additional information and models beyond three percentages.
It is separate from the app's **FAO–UNESCO 1974 three-group** triangle:
HYPRES adds Medium fine and Very fine regions. Neither option is an alias
for the other, and the legacy package alias `FAO50.TT` is not exposed as
another duplicate selector option.

## Inputs and boundaries

Use fine-earth percentages (<2 mm): sand **0.05–2 mm**, silt **0.002–0.05 mm**,
and clay **<0.002 mm**, as specified in the ESDAC metadata. Switching systems
does not convert laboratory fractions.

`R/classifications/europe_hypres.R` records independent polygon coordinates
in (sand %, clay %) pairs. It does not depend on the app's FAO or country
objects. Five full English labels fit on the standard equilateral plot;
only display wrapping is applied to Medium fine, so no code key is needed.

Shared edges retain the app's candidate policy. For example, 20% sand,
20% silt and 60% clay returns `boundary`, candidates Fine and Very fine,
without a single class. The vertex at 15% sand and 35% clay has three
candidates. Pure sand, clay and silt classify uniquely as Coarse, Very fine
and Medium fine respectively.

## Implementation checks

- `tests/fixtures/europe_hypres.csv`: interiors for each class, both sides of
  the coarse step, and a silt-rich composition.
- `tests/europe_hypres.R`: those cases, all six internal edge segments and
  nearby values, the three-class vertex, corners, metadata, example CSV,
  Shiny results and exports.
- Shared tests automatically check total area, 5,151-point coverage,
  gaps/overlaps, polygon-order independence and plot rendering.

These are implementation and regression checks. Independent package comparison
and broader scientific validation remain future work; soiltexture is not a
project dependency.

Example upload: `examples/europe_hypres_samples.csv`.
