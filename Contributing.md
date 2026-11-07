# Contributing

Thank you for helping improve Soil Texture Triangle. Contributions can include
bug fixes, usability improvements, documentation, source verification and
additional texture classifications.

## Before you start

Read the [README](README.md), [classification methodology](docs/classification.md)
and any source notes relevant to your change. For a new classification or a
substantial interface change, open an
[issue](https://github.com/ammazzetto2/texture_triangle_nz/issues) first to
outline the problem, proposed scope and available evidence.

Keep each pull request focused. Separate scientific definition changes from
unrelated interface or formatting changes so reviewers can assess them clearly.

## Report a problem

Include the following in a bug report:

- What you expected and what happened.
- Steps to reproduce the issue, including the selected classification view.
- A small, non-sensitive sample CSV or composition when relevant.
- Your R version, operating system and browser; include `sessionInfo()` for
  dependency or runtime problems.
- Error messages and, for visual problems, a screenshot where useful.

For scientific discrepancies, identify the source, edition, page/table/figure,
particle-size cutoffs and an example composition. Distinguish a transcription
error from a different national scheme, source edition or equality convention.
Do not include confidential sample data or credentials in issues or commits.

## Set up a development copy

1. Fork the repository on GitHub.
2. Clone your fork and create a branch:

   ```sh
   git clone https://github.com/YOUR-USERNAME/texture_triangle_nz.git
   cd texture_triangle_nz
   git switch -c feature/describe-your-change
   ```

3. Install R 4.1 or newer and start the app from the repository root:

   ```sh
   Rscript run_app.R
   ```

Missing R packages are installed into `.R-library/`. Do not commit that folder,
R session files, generated plots or editor state. Dependency versions are not
yet locked; report the environment used to validate your changes.

## Make and verify changes

Follow the existing module structure and code style. Keep country-specific
geometry and metadata in `R/classifications/`, rather than adding special cases
to the shared classifier or renderer. Preserve stable export IDs unless a
migration is explicitly justified and documented.

Run checks relevant to your change while developing, then run the complete
suite before submitting code or classification changes:

```sh
Rscript --vanilla tests/run_all.R
```

For example, an individual comparison check can be run with:

```sh
Rscript --vanilla tests/japan_isss.R
```

Add meaningful regression coverage for changed behaviour. Documentation-only
changes generally need link, example and formatting checks rather than a full
app test run. For interface changes, inspect the affected workflow at desktop
and narrow widths, including keyboard operation. Include screenshots in the
pull request when they help reviewers understand the result.

## Add or correct a classification

Follow the [classification maintenance guide](docs/adding-classifications.md).
A contribution should include:

- The named scheme and edition or clearly labelled reference year.
- Source citations with page, table or figure numbers and coordinate provenance.
- Particle-size limits, percentage denominator and excluded components.
- A definition using the existing schema, a sample CSV, source notes and
  independently justified expected classifications.
- Checks for class interiors, shared boundaries, gaps/overlaps and integration
  with rendering and exports, appropriate to the change.

A package match alone does not establish scientific authority. Document
uncertainties and conflicting sources. Do not silently alter boundaries,
assign shared equalities arbitrarily, normalise input values or treat a view
switch as a particle-size conversion. Methods requiring unavailable fractions
or additional soil information need an explicit input design before inclusion.

Retain citations and license notices for external material. Check permission
before adding source code, datasets, figures or branding from another project;
this project's MIT license does not replace their terms.

## Submit a pull request

Push your branch to your fork and open a pull request against the repository's
default branch. Use a concise title describing the final change. The description
should explain the problem, resulting behaviour, validation performed and any
remaining limitations. Link related issues with `Closes #123` when appropriate.

You can use this description template:

```md
## Summary

Describe the problem and what this change does.

## Validation

List the checks run and their results, or explain why a check was not run.

## Sources and limitations

For scientific changes, cite the edition and relevant pages, explain input
requirements, and record unresolved questions. For other changes, include
material limitations or omit this section.

## Related issues

Closes #123
```

Mark incomplete work as a draft. Address review comments with focused updates
and rerun affected checks. If the scope changes, update the title and description
to match the final implementation. Maintainers may request changes before
merging; a submitted pull request is not a guarantee of acceptance.

## Contribution licensing

Submit original contributions under the project's [MIT License](Licensing.md).
Ensure you have the right to contribute the material and identify third-party
content and its terms. Preserve existing acknowledgements and source notices.
