# Brazil: SiBCS 2013, eight texture subgroups

## Sources and identity

Scientific reference: Santos et al. (2013), *Sistema Brasileiro de
Classificação de Solos*, third revised and expanded edition. This is the
eight-class **subgrupamento textural**, separate from the detailed 13-class
triangle and five broad texture groups already available in the app.

Numerical geometry: **soiltexture 1.5.3**, `SiBCS13.TT`, by Julien Moeys and
contributors, with digitisation credited to José Lucas Safanelli and Alexandre
ten Caten. The [source is pinned to revision
db3bfb683b420989422690f3e18188b923740e40](https://github.com/cran/soiltexture/blob/db3bfb683b420989422690f3e18188b923740e40/R/soiltexture.R).
Only factual vertices and class membership are transcribed; no package
functions are bundled or executed. The source package identifies its licence
as AGPL (>=3); soiltexture is not a runtime dependency.

The contributors' primary implementation paper, ten Caten, Safanelli and Silva
(2015), [*Adequação do pacote soiltexture para classificação textural do solo
pela linguagem R*](https://www.eventossolos.org.br/cbcs2015/arearestrita/arquivos/1064.pdf),
identifies the 2013 scheme, eight classes and fractions. Tables 2 and 4 publish
ten example compositions and results; Figure 2b shows this triangle. These
were checked on 7 November 2026. The original 2013 handbook has not been
independently inspected in full; the implemented numerical authority is the
pinned package transcription, corroborated by its contributors' paper.

Selector: **Brazil (SiBCS) · 2013 · 8 classes**.
Stable export ID: `Brazil (SiBCS 2013, SiBCS13.TT 1.5.3, 8 classes)`.
Here `13` in `SiBCS13.TT` means **2013**, not the number of classes.

## Names, inputs and scope

| Plot code | Class name retained in results and CSV |
| --- | --- |
| MA | Muito argilosa |
| A | Argilosa |
| S | Siltosa |
| MeS | Média siltosa |
| MeA | Média argilosa |
| MeAr | Média arenosa |
| ArMe | Arenosa média |
| MAr | Muito arenosa |

Portuguese accents are retained. The plot uses the source codes, with an
expandable full-name key under About & methodology. MA and MAr differ.

Use fine-earth percentages (<2 mm): sand **0.05–2 mm**, silt
**0.002–0.05 mm** and clay **<0.002 mm**, totalling 100. These fractions are
stated in the contributors' paper and package metadata. Switching systems
cannot convert measurements. This view supplies texture only, not full SiBCS
taxonomy, horizon sequences, sand-size subclasses or coarse-fragment modifiers.

The file stores shared vertices in (silt %, clay %) coordinates and derives
sand by difference using the existing polygon helper. It does not combine
the app's other Brazilian definitions. The Média siltosa/Média arenosa
division joins (sand,clay) = (52.5,0) and (55,20)%; it is not a constant
52% sand line. Média argilosa has a shoulder at (47.5,25)%. These limits
retain the pinned transcription rather than substituting newer definitions.

## Boundaries and validation

Shared edges retain the common candidate policy. The paper's sample 4,
(sand,silt,clay) = (10,30,60)%, has candidates **Argilosa; Muito argilosa**
and no single assigned class, consistent with its published multiple result.
Pure sand, silt and clay have unique candidates Muito arenosa, Siltosa and
Muito argilosa. Exact scientific equality ownership is not newly asserted.

- `tests/fixtures/brazil_sibcs2013_8.csv` transcribes the paper's ten samples
  and results, covering all eight interiors plus its 60% clay boundary.
- `tests/brazil_sibcs2013_8.R` checks those cases, 10,000 reproducible random
  compositions against an analytical interpretation of the pinned segments,
  both sides of four subgroup-specific boundaries, corners, metadata, code
  key, existing Brazilian identities, Shiny output and CSV export.
- The transcription was compared with the pinned package source: all eight
  outlines agree. Continuous geometry checks found no material gap or
  positive-area overlap. Shared definition and rendering tests discover
  the new view automatically, including 5,151-point coverage.

The analytical and package checks establish implementation fidelity, not
independent validation of the original handbook's precise numerical limits.
Published cases come from the package contributors and corroborate that
implementation rather than form a wholly independent scientific oracle.

Example upload: [Brazil SiBCS 2013 samples](../../examples/brazil_sibcs2013_8_samples.csv).
See [the other Brazilian views](brazil.md) for their separate provenance.
