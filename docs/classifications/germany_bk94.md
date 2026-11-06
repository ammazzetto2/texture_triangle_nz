# Germany: BK94, 31 texture classes (1994)

## Sources and edition

Scientific reference: AG Boden (1994), *Bodenkundliche Kartieranleitung*,
fourth edition, Hannover. This view implements **BK94**, not a claim to
represent later German editions or DIN classifications.

Numerical geometry and class-code membership are transcribed from
`DE.BK94.TT` in **soiltexture 1.5.3**, by Julien Moeys and contributors.
The [source is pinned to revision db3bfb683b420989422690f3e18188b923740e40](https://github.com/cran/soiltexture/blob/db3bfb683b420989422690f3e18188b923740e40/R/soiltexture.R#L680).
Only factual coordinates and class membership are transcribed; package functions
are not bundled or executed. The source package identifies its license as
AGPL (>=3). Capitalization of German class names is made consistent in this app.

The University of Münster's [Hypersoil: Bodenart](https://www.hypersoil.uni-muenster.de/0/03/06.htm)
provides supporting fraction definitions, terminology and a simplified diagram
citing AG Boden (1994). That simplified illustration is background, not the
numerical authority for all 31 polygons. The original 1994 book has not been
independently retrieved for this implementation.

As with the French addition, wider comparisons against the soiltexture
package remain deferred. It is not a project dependency. Basic implementation
checks below do not substitute for independent scientific verification.

## Identity, display and input convention

Selector: **Germany · BK94 31 classes (1994)**.
Stable export ID: `Germany (BK94 1994, 31 classes)`.

Use fine-earth percentages (<2 mm): **sand 0.063–2 mm**, **silt (Schluff)
0.002–0.063 mm**, **clay (Ton) <0.002 mm**. The 0.063 mm sand/silt cutoff is
not interchangeable with the 0.05 mm or 0.06 mm systems in other app views.
Changing the selector does not convert laboratory measurements.

The original numerical coordinates are stored as (silt %, clay %) pairs,
with sand derived by difference. Shared vertices are specified once inside
`R/classifications/germany_bk94.R`. The app uses its standard equilateral
layout, preserving the input compositions and polygon memberships.

With 31 regions, the plot uses standard short codes. **About & methodology →
Class label key** expands to show every code and German name. Results and CSV
exports preserve both, for example `Ss · Reiner Sand`. The key is generated
from definition metadata; it is not a Germany-specific UI branch.

## Classes

| Code | German class name |
| --- | --- |
| Ss | Reiner Sand |
| Su2 | Schwach schluffiger Sand |
| Sl2 | Schwach lehmiger Sand |
| Sl3 | Mittel lehmiger Sand |
| St2 | Schwach toniger Sand |
| Su3 | Mittel schluffiger Sand |
| Su4 | Stark schluffiger Sand |
| Slu | Schluffig-lehmiger Sand |
| Sl4 | Stark lehmiger Sand |
| St3 | Mittel toniger Sand |
| Ls2 | Schwach sandiger Lehm |
| Ls3 | Mittel sandiger Lehm |
| Ls4 | Stark sandiger Lehm |
| Lt2 | Schwach toniger Lehm |
| Lts | Sandig-toniger Lehm |
| Ts4 | Stark sandiger Ton |
| Ts3 | Mittel sandiger Ton |
| Uu | Reiner Schluff |
| Us | Sandiger Schluff |
| Ut2 | Schwach toniger Schluff |
| Ut3 | Mittel toniger Schluff |
| Uls | Sandig-lehmiger Schluff |
| Ut4 | Stark toniger Schluff |
| Lu | Schluffiger Lehm |
| Lt3 | Mittel toniger Lehm |
| Tu3 | Mittel schluffiger Ton |
| Tu4 | Stark schluffiger Ton |
| Ts2 | Schwach sandiger Ton |
| Tl | Lehmiger Ton |
| Tu2 | Schwach schluffiger Ton |
| Tt | Reiner Ton |

## Boundaries and checks

Shared edges retain the common candidate policy. At 25% sand, 10% silt and
65% clay, the app returns `boundary`, candidates Ts2 and Tt, without a single
class. Pure sand, clay and silt have unique candidates Ss, Tt and Uu.

- `tests/fixtures/germany_bk94.csv`: a reference interior for each class.
- `tests/germany_bk94.R`: these 31 interiors, the code/full-name key, nearby
  values on either side of a boundary, corners, examples, metadata, Shiny
  results and CSV exports.
- Shared tests discover this definition automatically and check polygon area,
  5,151-point coverage, gaps/overlaps, order independence and plot rendering.

These are implementation and regression checks. Independent package comparisons
and broader scientific validation are future work.

Example upload: `examples/germany_samples.csv`.
