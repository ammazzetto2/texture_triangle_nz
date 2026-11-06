# Poland: PTG 2008, 16 texture classes

## Sources and year

Primary source: Polish Society of Soil Science, *Klasyfikacja uziarnienia
gleb i utworów mineralnych – PTG 2008*, Roczniki Gleboznawcze 60(2), 2009,
pp. 5–16 ([official publication](https://ssa.ptgleb.pl/wp-content/uploads/pdf/2009-60-2/2009-60-2-s-5-16.pdf)).
The resolution was adopted on **5 March 2008**; 2009 is the publication year,
not the scheme's name. Table 1 gives fractions, Table 2 gives texture names
and limits, and Figure 1 (printed p. 9 / PDF p. 5) shows the 16-class triangle.

Numerical geometry is transcribed from **soiltexture 1.5.3**, `PTG_2008.TT`,
by Julien Moeys and contributors. Unlike its main source file, the package
stores the Polish schemes in a separate binary data file:
[pinned triangles.rds, revision db3bfb683b420989422690f3e18188b923740e40](https://github.com/cran/soiltexture/blob/db3bfb683b420989422690f3e18188b923740e40/inst/triangles.rds).
The static data were read without installing the package or executing its
classifier. Only factual vertices and region membership are transcribed;
package functions are not bundled. The source package identifies its license
as AGPL (>=3). Polish diacritics follow the official publication.

## Identity and scope

Selector: **Poland (PTG) · 2008 · 16 classes**.
Stable export ID: `Poland (PTG 2008, PTG_2008.TT 1.5.3, 16 classes)`.
It appears in the Current group and participates in alphabetical ordering.

This is PTG 2008, not the older `PL.TT` (PTG 1956–1959), Musierowicz 1956,
BN 1978 or agronomic 1990 schemes also present in soiltexture. Those use
different classes and particle-size conventions and need separate definitions.
The app implements the main triangle only: additional sand-size subdivisions,
coarse-fragment classes and full Polish soil taxonomy are excluded.

## Classes

| Code | Polish name |
| --- | --- |
| ic | Ił ciężki |
| iz | Ił zwykły |
| ipy | Ił pylasty |
| ip | Ił piaszczysty |
| gi | Glina ilasta |
| gpyi | Glina pylasto-ilasta |
| gpi | Glina piaszczysto-ilasta |
| gz | Glina zwykła |
| pyi | Pył ilasty |
| pyg | Pył gliniasty |
| gl | Glina lekka |
| gp | Glina piaszczysta |
| pyz | Pył zwykły |
| pg | Piasek gliniasty |
| ps | Piasek słabogliniasty |
| pl | Piasek luźny |

The plot uses Polish codes. **About & methodology → Class label key** expands
to full names. Results and CSV exports preserve both code and name, including
diacritics, for example `pl · Piasek luźny`. Parenthetical USDA equivalents
from the package's labels are not used as Polish class codes or inferred as
another system's classifications.

## Inputs and geometry

Use mass percentages of fine earth (<2 mm): **sand (piasek) 0.05–2 mm**,
**silt (pył) 0.002–0.05 mm**, **clay (ił) <0.002 mm**. Older Polish schemes
can instead use a 0.1 mm sand/silt cutoff and 0.02 mm clay/silt cutoff;
measurements under those conventions cannot simply be uploaded as PTG 2008.
Switching systems does not convert laboratory fractions.

`R/classifications/poland_ptg2008.R` stores shared vertices once in
(silt %, clay %) coordinates and derives sand by difference. There is no
runtime dependency on soiltexture, its binary data or another app definition.

Shared edges retain the app's candidate policy. At 20% sand, 20% silt and
60% clay, the result is `boundary`, candidates ic and iz, without a single
class. Pure sand, clay and silt classify uniquely as pl, ic and pyz.

## Implementation checks

- `tests/fixtures/poland_ptg2008.csv`: an interior for each class.
- `tests/poland_ptg2008.R`: those 16 cases, containment of rendered class labels, full-name key, accented CSV round
  trips, a boundary and nearby values, corners, example CSV, source metadata
  and Shiny integration.
- Shared tests automatically check area, 5,151-point coverage, gaps/overlaps,
  polygon-order independence, rendering and alphabetically grouped selection.

These are implementation and regression checks. Broader independent scientific
validation and package comparisons remain deferred; soiltexture is not a
project dependency.

Example upload: `examples/poland_samples.csv`.

The `gp` region is concave, so its vertex average is inside neighbouring `gl`.
Its definition specifies a display-only label position (70% sand, 5% clay),
inside `gp`. Polygon coordinates and classifications are unchanged by this
label override.
