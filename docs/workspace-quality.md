# Workspace quality checks

Local checks through 8 November 2026 cover software behaviour and usability.

## Automated coverage

All 36 test scripts passed on 8 November 2026. To repeat the run, execute
`Rscript --vanilla tests/run_all.R` from the repository root.
`tests/workspace_quality.R` exercises 1,000 coincident samples: pagination keeps
25 visible rows, CSV export retains all 1,000, literal searches find a long name
containing HTML characters without executing markup, and the selected chart
point keeps its full name when ordinary sample labels are hidden. This is a
correctness fixture, not a throughput benchmark or supported-size guarantee.

The [session isolation test](../tests/session_isolation.R) interleaves two mock
Shiny sessions in one R process. Each session exports only its own sample.
Undoing an addition in one session preserves the other session’s export.

## Local performance

Both benchmarks use synthetic CSVs and the New Zealand system. The local
measurements below cover 25,000 rows.

| Measurement | Before the classification change | After |
|---|---:|---:|
| Classify all rows in R | 2.992 s | 0.086 s |
| Confirm import to classified count on one live worker | 2.968–3.049 s | 0.092 s |
| Second session adds a sample during that import | 2.872–2.954 s | 0.088 s |

Run `Rscript --vanilla benchmarks/csv_workspace.R 25000` from the repository
root to time parsing, validation, classification and drawing the chart. For the
two-session check, start the app on a local port and run
`node benchmarks/shared_worker.mjs PORT` with Node 22 or later. The second
session sent its add request about 100 ms after confirmation in the two earlier
runs and 10 ms after confirmation in the later run. The live benchmark measures
server feedback. Browser rendering and network latency need measurement on the
deployment host.

## Browser checks performed

- Tab followed by Enter activates the skip link and focuses the workspace.
- The accessibility tree exposes the chart's system, sample count and direction
  to the equivalent Results table.
- Opening the sample editor focused the name field. Cancel and Save returned
  focus to the row’s Edit button, including after a rename.
- Renaming a sample so it fell outside the active search, or deleting the final
  sample, left keyboard focus in the Results region after the table refreshed.
- Correcting the clay mapping with the keyboard changed the CSV status from
  one invalid row to three rows ready for import and enabled the import button.
  Focus stayed on the mapping selector.
- At 320 × 640 CSS pixels, the toolbar controls stack without overlapping and
  the document has no horizontal overflow.
- At 800 × 500 CSS pixels, the page scrolls and the workspace retains space.
  This checks short-window reflow; it does not replace actual browser zoom tests.
- The muted text colour on the toolbar has calculated sRGB contrast 4.71:1
  (previously 4.19:1). Primary green on white is 8.33:1. Status badge text/background
  pairs checked exceed 5:1. This is a targeted palette check, not a full audit.

## Checks for the deployed app

- Test VoiceOver and NVDA announcements, forms, tab navigation and dialogs.
- Test actual 200% and 400% browser zoom, increased text size and forced colours.
- Repeat keyboard-only entry, CSV mapping/error review and Results row actions
  in Firefox and Chromium, including focus after dynamic updates.
- In two browser sessions on the deployment host, import a representative CSV
  in one while adding a sample in the other. Record time until Results and
  the chart appear, and time until the second session receives confirmation.
  Check each session’s CSV contains its own samples, then restore a download
  into a fresh session and compare names and percentages.
- Inspect dense charts with representative data. All points are still plotted;
  coincident points overlap and long chart labels can be clipped. Hide labels and
  use the Results table for exact names and values.
