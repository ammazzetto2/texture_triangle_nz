# Germany: SEA74 1974, 13 classes

## Sources and identity

This is the historical German Standortserkundungsanweisung (SEA 1974) texture triangle for **forest soils**.
Numerical geometry and class membership are transcribed from `DE.SEA74.TT` in
**soiltexture 1.5.3**, by Julien Moeys and contributors. The
[source is pinned to revision db3bfb683b420989422690f3e18188b923740e40](https://github.com/cran/soiltexture/blob/db3bfb683b420989422690f3e18188b923740e40/R/soiltexture.R#L1262).
Only factual vertices and class membership are transcribed; package functions
are not bundled or executed. The source package identifies its license as
AGPL (>=3).

The [package author's gallery](https://www.julienmoeys.info/2015/02/06/texture-triangle-gallery/)
provides the historical diagram and context. The original historical standard
has not been independently retrieved for this implementation; numerical
authority here is the pinned transcription. This is a separate option from
BK94 and the other historical German view, not a claim to represent a current
national standard or a full soil classification.

Selector: **Germany · SEA74 1974 (13 classes)**.
Stable export ID: `Germany (SEA74 1974, DE.SEA74.TT 1.5.3, 13 classes)`.
The year identifies the historical scheme; 1.5.3 identifies its numerical
transcription.

## Classes and display

| Code | German class name |
| --- | --- |
| L | Lehm |
| stL | Sandig-toniger Lehm |
| sL | Sandiger Lehm |
| S | Sand |
| alS | Anlehmiger Sand |
| lS | Lehmiger Sand |
| T | Ton |
| uT | Schluffiger Ton |
| lT | Lehmiger Ton |
| sT | Sandiger Ton |
| U | Schluff |
| UL | Schlufflehm |
| lU | Lehmiger Schluff |

The plot uses codes. **About & methodology → Class label key** expands to
German names. Results and CSV exports retain both code and name; capitalization
of German names is made consistent in the app.

## Inputs and geometry

Use fine-earth percentages (<2 mm): **sand 0.063–2 mm**, **silt (Schluff)
0.002–0.063 mm**, **clay (Ton) <0.002 mm**, following the pinned definition.
Selecting another view does not convert laboratory measurements.

Shared vertices are recorded once as (silt %, clay %) pairs, with sand derived
by difference. The common equilateral renderer preserves compositions; the
source's right-triangle presentation is not a change in classification.

The SEA74 transcription deliberately uses an **18% clay** break, rather than
substituting BK94's 17%. Its source explicitly documents this difference.
The upper Ton region begins above **45% clay**. TGL85 instead uses a 50%
clay break and different lower sand classes. No geometry is inherited from
the other German objects.

Shared edges retain the app's candidate policy. At 30% sand, 25% silt and
45% clay, the result is `boundary`, candidates lT and T, without a single
class. Pure clay and silt classify uniquely as T and U; pure sand receives
S.

## Implementation checks

- `tests/fixtures/germany_sea74.csv`: one interior per class.
- `tests/germany_sea74.R`: all 13 cases, complete key, exact boundary and
  nearby values, corners, example CSV, source metadata, Shiny results and exports.
- Shared tests cover total area, 5,151-point coverage, gaps/overlaps,
  polygon-order independence and plot rendering.

These are implementation and regression checks. Independent package comparisons
and broader scientific validation remain deferred; soiltexture is not a
project dependency.

Example upload: `examples/germany_sea74_samples.csv`.
