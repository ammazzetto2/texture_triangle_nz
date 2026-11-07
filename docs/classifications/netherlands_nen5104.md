# Netherlands: NEN 5104:1989, 14 mineral texture classes

## Sources and edition

The implementation follows Figure 2 of [Rijkswaterstaat, Indelen in grondsoorten](https://loket.rijkswaterstaat.nl/procedures/publicatie/indelen-in-grondsoorten)
(version November 2021). It is corroborated by [RIVM report 711701049/2008](https://www.rivm.nl/bibliotheek/rapporten/711701049.pdf),
Figure 5-1 and Table 5-13 on printed page 65 (PDF page 66).
The fractions are described on printed page 64. The [KIVI geotechnical reader](https://kivi.nl/_Resources/Persistent/6/8/a/e/68aeb91675496925881415274b0545b4651f0983/Reader%20Geotechniek%20voor%20het%20HBO.pdf),
PDF page 72, Figure 3.2.4 (credited to Deltares), also supplies the numerical
sand-axis divisions. These reproductions were inspected on 7 November 2026.

[NEN's official record](https://www.nen.nl/nen-5104-1989-nl-6461) identifies
NEN 5104:1989 and withdrawal on 20 August 2020. The full paid standard was
not inspected. This implementation therefore documents its public source
reproductions and does not assert current-standard conformity.

Selector: **Netherlands (NEN 5104) · 1989 · 14 classes**, under **Historic**.
Export ID: `Netherlands (NEN 5104 1989, 14 classes)`.
No package polygon dataset is copied or required; `NL.TT` is not an option
in the reviewed soiltexture 1.5.3 reference.

## Inputs and scope

Use mass percentages of the mineral fraction below 2 mm, totalling 100%:

- sand: 0.063–2 mm;
- silt: 0.002–0.063 mm;
- clay (lutum): below 0.002 mm.

The separate organic-matter and gravel classifications require additional
measurements and are excluded. Switching views does not convert particle-size
measurements. The RIVM figure's shaded four-group model overlay is also
excluded; this view implements its 14 underlying NEN regions.

## Geometry and labels

S and C denote sand and clay percentages. Conditions below describe strict
interiors; they do not assign scientific ownership of exact equalities.

| Code | Dutch name | Interior conditions |
| --- | --- | --- |
| Ks1 | Zwak siltige klei | C > 50 |
| Ks2 | Matig siltige klei | 35 < C < 50 |
| Ks3 | Sterk siltige klei | 25 < C < 35 |
| Ks4 | Uiterst siltige klei | S < 50; C < 25; C + 0.34S > 25 |
| Kz1 | Zwak zandige klei | S > 50; 17.5 < C < 25 |
| Kz2 | Matig zandige klei | S > 50; 12 < C < 17.5 |
| Kz3 | Sterk zandige klei | S > 50; 8 < C < 12 |
| Lz1 | Zwak zandige leem | S < 15; C + 0.34S < 25 |
| Lz3 | Sterk zandige leem | 15 < S < 50; C + 0.34S < 25 |
| Zk | Kleiig zand | S > 82.5; 5 < C < 8 |
| Zs1 | Zwak siltig zand | S > 90; C < 5 |
| Zs2 | Matig siltig zand | 82.5 < S < 90; C < 5 |
| Zs3 | Sterk siltig zand | 67.5 < S < 82.5; C < 8 |
| Zs4 | Uiterst siltig zand | 50 < S < 67.5; C < 8 |

All conditions are clipped to the physical simplex S + C ≤ 100. The sloping
clay/leem line joins (S,C) = (50,8) and (0,25). Its intersection with S = 15
is C = 19.9, derived analytically rather than rounded from pixels.
Plot codes link to Dutch names in the class key. Results and exports retain
both. Shared boundaries list adjacent candidates without choosing one class.

## Validation and review

The Dutch test covers all 14 class fixtures, 10,000 reproducible compositions
against an analytical interpretation, all 22 internal segments and points on
both sides, corners, a four-class junction, selector metadata, class key,
example upload, Shiny results and CSV export. Common schema, grid coverage,
order-independence and rendering checks discover this definition automatically.
Continuous geometry checks assess polygon validity, coverage and overlaps.

The analytical checks test the chosen transcription; they are not an
independent validation of the national standard. Unresolved equality rules,
source limitations and an inconsistent experimental BRO text reference are
recorded in `SCIENTIFIC_REVIEW_DRAFT.md`.

Example upload: [Dutch samples](../../examples/netherlands_samples.csv).
