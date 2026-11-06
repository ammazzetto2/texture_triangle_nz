# Belgium: seven texture classes

## Sources and identity

The Belgian mineral-soil texture triangle has seven main classes, represented
by Z, S, P, L, A, E and U. The Flemish government's [field guide for describing
soils, section 4.7.1, Table 4.10 and Figure 4.8](https://publicaties.onroerenderfgoed.be/HAOE-29-BeschrijvenBodems/04_bodembeschrijving.html#fig-04-08)
provides Dutch names, the diagram and a worked composition. Its section 5.1.1
separates these mineral classes from other soil-map symbols.

Numerical geometry and French/Dutch labels are transcribed from `BE.TT` in
**soiltexture 1.5.3**, by Julien Moeys and contributors. The [source is pinned
to revision db3bfb683b420989422690f3e18188b923740e40](https://github.com/cran/soiltexture/blob/db3bfb683b420989422690f3e18188b923740e40/R/soiltexture.R#L928).
Only factual coordinates and class membership are transcribed; package
functions are not bundled or executed. The source package identifies its
license as AGPL (>=3). The French spelling `léger` retains its accent here.

Selector: **Belgium · 7 classes**.
Stable export ID: `Belgium (BE.TT 1.5.3, 7 classes)`.
The version identifies the numerical transcription; it is not a publication
year or an asserted edition of the Belgian classification. No earlier
original numerical publication has been independently retrieved here.

## Classes, display and scope

| Code | French | Dutch |
| --- | --- | --- |
| U | Argile lourde | Zware klei |
| E | Argile | Klei |
| A | Limon | Leem |
| L | Limon sableux | Zandleem |
| P | Limon sableux léger | Licht zandleem |
| S | Sable limoneux | Lemig zand |
| Z | Sable | Zand |

The triangle shows standard codes. **About & methodology → Class label key**
expands to show the French and Dutch names. Results and CSV exports preserve
both languages, for example `P · Limon sableux léger / Licht zandleem`.
The shared key implementation requires no Belgium-specific UI code.

This view classifies only mineral texture. It does not infer the drainage,
profile development, stoniness or other attributes needed for a complete
Belgian soil-map code. Peat and special landscape units are excluded.

## Inputs and polygon representation

Use fine-earth percentages (<2 mm): sand **0.05–2 mm**, silt **0.002–0.05 mm**,
and clay **<0.002 mm**. The Dutch term `leem` and French `limon` describe the
silt fraction here. The fractions are shown in the official diagram; the
package transcription uses the same cutoffs. Changing systems does not
convert laboratory measurements.

`R/classifications/belgium.R` stores the transcribed vertices once in
(silt %, clay %) coordinates and derives sand by difference. The common
renderer uses the app's standard axis orientation; it preserves compositions
and class memberships. Decimal limits such as 8.75%, 11.25% and the bends
between L and E are retained rather than rounded.

Shared edges retain the common candidate policy. At 50% sand, 45% silt and
5% clay, the app reports `boundary`, candidates L and P, without a single
class. Pure sand, clay and silt have unique candidates Z, U and A.

## Implementation checks

- `tests/fixtures/belgium.csv`: one interior composition per class, including
  the official guide's L example (30% sand, 60% silt, 10% clay).
- `tests/belgium.R`: those cases, bilingual labels and accented CSV round trips,
  the full-name key, an exact boundary and nearby values, corners, examples,
  source metadata and Shiny integration.
- Shared tests cover area, 5,151-point coverage, gaps/overlaps, order independence
  and plot rendering.

These are implementation and regression checks. Independent package comparisons
and broader scientific validation remain deferred. The soiltexture package is
not a project dependency.

Example upload: `examples/belgium_samples.csv`.
