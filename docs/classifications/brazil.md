# Brazilian texture classifications

Three Brazilian views are available. This page documents the detailed
13-class view and five broad groups, both implemented from SiBCS 2025.
The separate **Brazil (SiBCS) · 2013 · 8 classes** option implements the
2013 texture subgroups using soiltexture's `SiBCS13.TT` transcription; see
[eight-class source and validation notes](brazil_sibcs2013_8.md).

## Selector reference years

The 13-class selector uses **2013** (SiBCS), and the five-group
selector uses **1996** (Lemos and Santos). These reference dates are
separate from the 2025 manual used to construct the current polygons.

- [SiBCS 2013 publication record](https://binagri.agro.gov.br/cgi-bin/koha/opac-detail.pl?biblionumber=79006)
- [IBGE Manual técnico de pedologia, Figure 10](https://biblioteca.ibge.gov.br/visualizacao/livros/liv37318.pdf)
  reproduces the five groups with the attribution “Adaptado de Lemos e Santos (1996)”.

The display changes do not relabel the implemented geometry as a verified
transcription of either earlier edition. Export identifiers retain their
2025 implementation provenance.

## Implementation source and edition

Both options use *Sistema Brasileiro de Classificação de Solos* (SiBCS),
6th revised and expanded edition, Santos et al., Embrapa, 2025.

- [Publication record](https://www.infoteca.cnptia.embrapa.br/handle/doc/1176834)
- [Full manual](https://www.infoteca.cnptia.embrapa.br/infoteca/bitstream/doc/1176834/2/Sistema-Brasileiro-de-Classificacao-de-Solos-2025.pdf)
- Printed page 54: particle fractions and the stated adaptation of USDA (2017).
- Printed page 55, Figure 1.1: the detailed texture triangle.
- Printed pages 55–56, Figure 1.2: five texture groups and their definitions.

The implementation was checked against these pages on 6 November 2026.
Neither the manual nor its artwork is bundled with the app.

## Detailed view: 13 classes

The source specifies USDA (2017) with an additional very-clayey class. The app
implements the published base definitions and splits clay above 60%, with the
Portuguese names shown in Figure 1.1:

Muito argilosa, Argila, Argilossiltosa, Argiloarenosa, Francoargilosa,
Franco-argilossiltosa, Franco-argiloarenosa, Franca, Francoarenosa,
Francossiltosa, Silte, Areia franca, and Areia.

The exact base limits, including 7%, 12%, 27%, 28%, and 52%, come from
[USDA Soil Survey Manual (2017), printed pages 122–125](https://www.nrcs.usda.gov/sites/default/files/2022-09/The-Soil-Survey-Manual.pdf).
Polygon vertices were derived from those definitions and compared visually
with the SiBCS diagram. No third-party software or digitised polygon dataset
was copied. The existing USDA option retains its original project coordinates;
it is not used to generate the Brazilian data.

## Grouped view: five groups

The following analytical definitions are expressed in percentages; the source
uses g/kg (divide by ten to obtain percentage points).

| Group | Published definition |
| --- | --- |
| Muito argilosa | Clay >60% |
| Argilosa | Clay from 35% to 60% |
| Arenosa | Sand minus clay >70 percentage points |
| Siltosa | Clay <35% and sand ≤15% |
| Média | Clay <35% and sand >15%, excluding Areia and Areia franca |

The Arenosa boundary combines the two sandy detailed classes. The other
groups have their own boundaries, so the grouped diagram is constructed
independently rather than by merging all detailed classes mechanically.

This option is the five-group view, not the older eight-class scheme named
`SiBCS13.TT` in some software (where “13” refers to 2013).

## Fractions and units

Use mass percentages of the fine-earth fraction (<2 mm):

- Sand: 0.05 to <2 mm.
- Silt: 0.002 to <0.05 mm.
- Clay: <0.002 mm.

The three values must total 100. Do not upload g/kg as percentages. Changing
the classification selector does not convert particle-size measurements from
another laboratory convention.

## Boundaries and exports

Both views retain the app's common software policy: shared polygon boundaries
list candidate classes and leave the single classification as `NA`. Thus a
sample exactly at 60% clay can list both Argila/Argilosa and Muito argilosa.
This deliberately differs from selecting one side using the source's exact
inequality conventions. Numerical edge tolerance remains `1e-10` in fraction
coordinates. Unique outer boundaries and pure-component corners receive a
single class.

The CSV `classification_system` records the edition and view:

- `Brazil (SiBCS 2025, 13 classes)`
- `Brazil (SiBCS 2025, 5 groups)`

Class labels retain their Portuguese spelling. Plot line wrapping does not
insert line breaks into the new Brazilian CSV labels.

## Validation

`tests/brazil.R` checks representative classes, all three pure-component
corners, selected shared boundaries, polygon area, order independence, source
metadata, and versioned Shiny exports. It compares interior assignments for
5,151 whole-percentage compositions and 10,000 reproducible random
compositions against independent analytical definitions. Sampled points have
no unmatched locations or interior overlaps. Sampling is not a formal proof
of exhaustive polygon topology.

`tests/plotting.R` also renders both views with and without samples, checks
all class and axis labels, and rejects rendering warnings or messages.
