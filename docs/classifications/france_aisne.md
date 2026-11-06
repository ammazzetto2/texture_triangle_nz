# France: Aisne/Jamagne, modified 15-class triangle

## Sources and identity

Scientific and historical reference: Denis Baize, [Granulométrie et diagrammes
de texture, INRAE (2018), Figure 2](https://mots-agronomie.inrae.fr/index.php?title=Granulom%C3%A9trie_et_diagrammes_de_texture).
The article identifies Jamagne (1967) as the origin of the Aisne diagram and
notes later modifications, including the distinction between LS and LMS.
This view implements the **modified 15-class form**, not a claim to reproduce
the original 1967 edition unchanged. The original historical publication has
not been independently retrieved here.

Numerical geometry and codes are transcribed from `FR.AISNE.TT` in
**soiltexture 1.5.3**, by Julien Moeys and contributors. The [source is pinned
to revision db3bfb683b420989422690f3e18188b923740e40](https://github.com/cran/soiltexture/blob/db3bfb683b420989422690f3e18188b923740e40/R/soiltexture.R#L558).
Only factual coordinates and class membership are transcribed; package
functions are not bundled or executed. The source package identifies its
license as AGPL (>=3). French accents in `léger` follow INRAE's legend.

Selector: **France (Aisne/Jamagne) · 1967 reference · 15 classes**.
Stable export ID: `France (Aisne-Jamagne, FR.AISNE.TT 1.5.3, 15 classes)`.
The version identifies the numerical transcription, not an original scientific
publication year. This ID is distinct from the app's GEPPA option.

## Classes and scope

| Code | French name |
| --- | --- |
| ALO | Argile lourde |
| A | Argile |
| AL | Argile limoneuse |
| AS | Argile sableuse |
| LA | Limon argileux |
| LAS | Limon argilo-sableux |
| LSA | Limon sablo-argileux |
| SA | Sable argileux |
| LM | Limon moyen |
| LMS | Limon moyen sableux |
| LS | Limon sableux |
| SL | Sable limoneux |
| S | Sable |
| LL | Limon léger |
| LLS | Limon léger sableux |

The plot uses the standard codes for readability. **About & methodology →
Class label key** expands to show French names. Results and exports retain
both code and name, for example `LLS · Limon léger sableux`.
`ALO` uses the letter O. `LAS` and `LSA` are distinct classes.

This is a texture-only classification, separate from the GEPPA 17-class
triangle. Neither view determines a full soil taxonomic classification or
infers organic matter, drainage, sampling depth or other profile attributes.

## Inputs and geometry

Use fine-earth percentages (<2 mm): sand **0.05–2 mm**, silt **0.002–0.05 mm**,
and clay **<0.002 mm**. These cutoffs match the numerical transcription and
the fraction convention described by INRAE. Changing systems does not convert
laboratory measurements.

`R/classifications/france_aisne.R` defines shared vertices once in
(silt %, clay %) pairs and derives sand by difference. The app's standard
equilateral layout preserves those compositions and polygon memberships.
There are no runtime dependencies on the GEPPA definition or soiltexture.

The shared-edge candidate policy applies. At 30% sand, 25% silt and 45% clay,
the app reports `boundary`, candidates A and ALO, without a single class.
Pure sand, clay and silt have unique candidates S, ALO and LL respectively.

## Implementation checks

- `tests/fixtures/france_aisne.csv`: one interior per class plus INRAE's
  worked Figure 2 example (15% sand, 50% silt, 35% clay), in AL.
- `tests/france_aisne.R`: these interiors, French names and accented CSV round
  trips, the complete key, a boundary and nearby values, corners, examples,
  metadata and Shiny integration.
- Shared tests automatically cover area, 5,151-point coverage, gaps/overlaps,
  polygon-order independence and rendering.

These are implementation and regression checks. Independent package comparison
and broader scientific validation remain deferred; soiltexture is not a
project dependency.

Example upload: `examples/france_aisne_samples.csv`.
