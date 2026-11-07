# ISSS: 12 texture classes

## Sources and identity

Numerical geometry: `ISSS.TT` in **soiltexture 1.5.3**, by Julien Moeys and
contributors. The source credits Wei Shangguan and cites Verheye, W. and
Ameryckx, J. (1984), *Mineral fractions and classification of soil texture*,
Pedologie, 34(2), 215–225. The [numerical source is pinned to revision
db3bfb683b420989422690f3e18188b923740e40](https://github.com/cran/soiltexture/blob/db3bfb683b420989422690f3e18188b923740e40/R/soiltexture.R#L1146).
Only factual vertices and class membership are transcribed; no package
functions are bundled or executed. The source package identifies its license
as AGPL (>=3).

The [package author's published triangle gallery](https://www.julienmoeys.info/2015/02/06/texture-triangle-gallery/)
shows the ISSS diagram and identifies it as the International Society of Soil
Science triangle. The original 1984 article has not been independently
retrieved for this implementation. Numerical authority here is the pinned
ISSS.TT transcription, rather than a claim of independently verified original
publication limits.

Selector: **ISSS (also used in Japan) · 1984 reference · 12 classes**.
Stable export ID: `ISSS (ISSS.TT 1.5.3, 12 classes)`.
The version identifies the numerical transcription, not a scientific
publication year. This option is distinct from USDA and the Romanian view.

## Classes and display

| Code | English class name |
| --- | --- |
| HCl | Heavy clay |
| SaCl | Sandy clay |
| LCl | Light clay |
| SiCl | Silty clay |
| SaClLo | Sandy clay loam |
| ClLo | Clay loam |
| SiClLo | Silty clay loam |
| LoSa | Loamy sand |
| Sa | Sand |
| SaLo | Sandy loam |
| Lo | Loam |
| SiLo | Silt loam |

The plot uses these codes. **About & methodology → Class label key** expands
to full English names. Results and CSV exports preserve both, for example
`LCl · Light clay`. Capitalization of names is made consistent in this app.

## Inputs and scope

Use fine-earth percentages (<2 mm): **sand 0.02–2 mm**, **silt 0.002–0.02 mm**,
and **clay <0.002 mm**, following ISSS.TT's fraction limits. Changing systems
does not convert laboratory measurements. ISSS is both associated with a
particle-size convention and the name of this specific classification;
choosing a 0.02 mm cutoff alone does not make every triangle an ISSS triangle.

This option supplies mineral texture classes only, not a full soil taxonomy.
For this transcription, Heavy clay begins above 45% clay, while lower clay
bands distinguish light, sandy and silty classes. It is not obtained by
changing the particle-size metadata on the USDA polygons.

`R/classifications/isss.R` stores shared vertices once in (silt %, clay %)
coordinates, derives sand by difference, and uses the common renderer.
It has no runtime dependency on another system or on soiltexture.

Shared edges retain the common candidate policy. At 30% sand, 25% silt and
45% clay, the result is `boundary`, candidates HCl and LCl, without a single
class. Pure sand, clay and silt classify uniquely as Sa, HCl and SiLo.

## Implementation checks

- `tests/fixtures/isss.csv`: an interior composition for each class.
- `tests/isss.R`: those 12 cases, complete code/full-name key, a shared boundary
  and nearby values, corners, example CSV, metadata, Shiny results and exports.
- Shared tests automatically cover total area, 5,151-point coverage,
  gaps/overlaps, polygon-order independence and rendering.

These are implementation and regression checks. Independent package comparison
remains deferred; Japanese-source geometry comparison is documented below.
Soiltexture is not a project dependency.

Example upload: `examples/isss_samples.csv`.

## Japanese international-method comparison

The Japanese **international method (国際法)** is represented here by the
existing ISSS view. The selector now says **also used in Japan**; its stable
export ID and geometry are unchanged. The selector is a native dropdown,
so this is a visible discovery label rather than a separate search control
or duplicate classification.

The [Hokkaido Research Organization manual](https://www.hro.or.jp/agricultural/center/research-topics/bunseki2012.html),
*Analysis Methods for Soil and Crop Nutrition Diagnosis 2012*, corrected
chapter III (23 April 2013), supplies a numerical decision key in
[Table 2, printed p34 / PDF p6](https://www.hro.or.jp/upload/13654/3v2.pdf).
`tests/japan_isss.R` reconstructs convex regions from that key rather than
copying package vertices. All 12 closed regions match the app; checks cover
18 distinct vertices, region edges and 10,000 reproducible interior samples.
The manual's equality assignments differ from the app's shared-candidate
policy: matching geometry does not imply matching exact-boundary results.

Japanese codes differ from the package plot codes:

| Japanese code | Japanese name | App code |
| --- | --- | --- |
| HC | 重埴土 | HCl |
| SC | 砂質埴土 | SaCl |
| LiC | 軽埴土 | LCl |
| SiC | シルト質埴土 | SiCl |
| SCL | 砂質埴壌土 | SaClLo |
| CL | 埴壌土 | ClLo |
| SiCL | シルト質埴壌土 | SiClLo |
| LS | 壌質砂土 | LoSa |
| S | 砂土 | Sa |
| SL | 砂壌土 | SaLo |
| L | 壌土 | Lo |
| SiL | シルト質壌土 | SiLo |

[NARO's research summary and Figures 1–2](https://www.naro.go.jp/project/results/4th_laboratory/tarc/2020/tarc20_s02.html)
corroborate Japanese use, particle-size cutoffs and the 12-region diagram.
This does not make ISSS a complete Japanese soil taxonomy or establish one
exclusive national texture scheme.

The separate **five-class Japanese Agricultural Sciences method** is not
an ISSS grouping. Its different clay cutoff and sample-mass denominator
need a separate input convention; research and unresolved source details are
recorded in `SCIENTIFIC_REVIEW_DRAFT.md`. It has not been added to the app.
