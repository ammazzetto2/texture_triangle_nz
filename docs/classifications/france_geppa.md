# France: GEPPA 17 classes (1963)

## Sources

Scientific reference: GEPPA (1963), *Travaux de la commission cartographie*,
Annexe 4, *Expression de la texture des sols, détermination et dénomination de
classes en relation avec un diagramme granulométrique*.

The diagram and its 17-class legend are reproduced in Figure 3 of Denis Baize's
[Granulométrie et diagrammes de texture, INRAE, 2018](https://mots-agronomie.inrae.fr/index.php?title=Granulom%C3%A9trie_et_diagrammes_de_texture).
That article also supplies the historical reference. The original five-page
1963 publication was not independently retrieved for this implementation.

Numerical geometry: the `FR.GEPPA.TT` vertex transcription in **soiltexture
1.5.3**, by Julien Moeys and contributors. Its [source is pinned to revision
db3bfb683b420989422690f3e18188b923740e40](https://github.com/cran/soiltexture/blob/db3bfb683b420989422690f3e18188b923740e40/R/soiltexture.R#L616).
Only factual coordinates and class membership were transcribed; no package
functions are bundled or executed. The package source identifies its license
as AGPL (>=3). The original class names and codes follow INRAE's figure.

This is an implementation of that published numerical transcription, not a
claim of newly verified exact limits from the original 1963 document. Some
vertices have decimal approximations, particularly at intersections of sloping
boundaries. We retain that precision and common shared vertices, rather than
inventing rounded horizontal boundaries. Broader comparison against the
soiltexture package is explicitly deferred; it is not a project dependency.

## Identity and scope

Selector: **France · GEPPA 17 classes (1963)**.
Stable export ID: `France (GEPPA 1963, 17 classes)`.

This is GEPPA's detailed triangle, not the separate French Aisne/Jamagne
system or its four- and six-group simplifications. The usual right-triangle
representation is shown in the app's shared equilateral layout. The fractions
and class memberships are preserved by the coordinate transformation.

| Code | French class name |
| --- | --- |
| AA | Argile lourde |
| A | Argileux |
| As | Argile sableuse |
| Als | Argile limono-sableuse |
| Al | Argile limoneuse |
| AS | Argilo-sableux |
| LAS | Limon argilo-sableux |
| La | Limon argileux |
| Sa | Sable argileux |
| Sal | Sable argilo-limoneux |
| Lsa | Limon sablo-argileux |
| L | Limon |
| S | Sableux |
| SS | Sable |
| Sl | Sable limoneux |
| Ls | Limon sableux |
| LL | Limon pur |

Exports preserve both the code and French name, for example
`As · Argile sableuse`. Codes are case-sensitive: `As` and `AS` identify
different classes. Display wrapping does not change exported names.

## Inputs and boundaries

Use fine-earth percentages (<2 mm): sand 0.05–2 mm, silt 0.002–0.05 mm,
and clay <0.002 mm. This matches the fractions in the published diagram.
Selecting another system cannot convert laboratory fractions.

`R/classifications/france_geppa.R` stores vertices in the source's
(silt %, clay %) coordinates, derives sand by difference, then uses the shared
polygon helper. Shared vertices are defined once within the file.

Shared edges retain the common candidate policy. For example, 60% sand,
25% silt and 15% clay returns `boundary`, candidates Sa and Sal, without a
single classification. Pure sand, clay and silt have unique candidates SS,
AA and LL respectively. Boundary detection tolerance is numerical and does
not represent laboratory uncertainty or precision of the source drawing.

## Checks included with this addition

- `tests/fixtures/france_geppa.csv`: one composition inside each of 17 classes.
- `tests/france_geppa.R`: those interiors, case-sensitive identities, a shared
  edge and nearby compositions, corners, example CSV, metadata, Shiny results
  and CSV exports.
- Shared tests automatically cover area, 5,151-point coverage, gaps/overlaps,
  polygon-order independence and warning-free plot rendering.

These are implementation and regression checks. Independent package-wide
comparison and a broader scientific validation exercise remain future work.
Example upload: `examples/france_samples.csv`.
