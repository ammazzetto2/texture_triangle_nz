# Germany: TGL85 1985, 14 classes

## Sources and identity

This is the historical German TGL 24300-05:1985-06, Aufnahme landwirtschaftlich genutzter Standorte texture triangle for **agricultural soils**.
Numerical geometry and class membership are transcribed from `DE.TGL85.TT` in
**soiltexture 1.5.3**, by Julien Moeys and contributors. The
[source is pinned to revision db3bfb683b420989422690f3e18188b923740e40](https://github.com/cran/soiltexture/blob/db3bfb683b420989422690f3e18188b923740e40/R/soiltexture.R#L1316).
Only factual vertices and class membership are transcribed; package functions
are not bundled or executed. The source package identifies its license as
AGPL (>=3).

The [package author's gallery](https://www.julienmoeys.info/2015/02/06/texture-triangle-gallery/)
provides the historical diagram and context. The original historical standard
has not been independently retrieved for this implementation; numerical
authority here is the pinned transcription. This is a separate option from
BK94 and the other historical German view, not a claim to represent a current
national standard or a full soil classification.

Selector: **Germany · TGL85 1985 (14 classes)**.
Stable export ID: `Germany (TGL85 1985, DE.TGL85.TT 1.5.3, 14 classes)`.
The year identifies the historical scheme; 1.5.3 identifies its numerical
transcription.

## Classes and display

| Code | German class name |
| --- | --- |
| rS | Reiner Sand |
| l''S | Sehr schwach lehmiger Sand |
| l'S | Schwach lehmiger Sand |
| lS | Stark lehmiger Sand |
| uS | Schluffiger Sand |
| U | Schluff |
| lU | Lehmiger Schluff |
| sL | Sandiger Lehm |
| L | Lehm |
| UL | Schlufflehm |
| uT | Schluffiger Ton |
| lT | Lehmiger Ton |
| sT | Sandiger Ton |
| T | Ton |

The plot uses codes. **About & methodology → Class label key** expands to
German names. Results and CSV exports retain both code and name; capitalization
of German names is made consistent in the app.

The codes `l''S` (two straight apostrophes), `l'S` (one) and `lS` (none)
identify three different classes. They are preserved literally, not converted
to a shared typographic prime or merged in the label key or CSV.

## Inputs and geometry

Use fine-earth percentages (<2 mm): **sand 0.063–2 mm**, **silt (Schluff)
0.002–0.063 mm**, **clay (Ton) <0.002 mm**, following the pinned definition.
Selecting another view does not convert laboratory measurements.

Shared vertices are recorded once as (silt %, clay %) pairs, with sand derived
by difference. The common equilateral renderer preserves compositions; the
source's right-triangle presentation is not a change in classification.

TGL85's upper Ton region begins above **50% clay**, compared with 45% in
SEA74. Its lower sand-region boundaries include distinct sloping limits and
apostrophe codes. The **18% clay** break is retained rather than replaced
with BK94's 17%. No geometry is inherited from the other German objects.

Shared edges retain the app's candidate policy. At 25% sand, 25% silt and
50% clay, the result is `boundary`, candidates lT and T, without a single
class. Pure clay and silt classify uniquely as T and U; pure sand receives
rS.

## Implementation checks

- `tests/fixtures/germany_tgl85.csv`: one interior per class.
- `tests/germany_tgl85.R`: all 14 cases, complete key, exact boundary and
  nearby values, corners, example CSV, source metadata, Shiny results and exports.
- Shared tests cover total area, 5,151-point coverage, gaps/overlaps,
  polygon-order independence and plot rendering.

These are implementation and regression checks. Independent package comparisons
and broader scientific validation remain deferred; soiltexture is not a
project dependency.

Example upload: `examples/germany_tgl85_samples.csv`.
