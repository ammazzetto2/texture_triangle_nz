# Workspace quality checks

Checked on 7 November 2026. These checks cover software behaviour and usability,
not scientific verification of the classification polygons.

## Automated coverage

Run `Rscript --vanilla tests/run_all.R` from the repository root.
`tests/workspace_quality.R` exercises 1,000 coincident samples: pagination keeps
25 visible rows, CSV export retains all 1,000, literal searches find a long name
containing HTML characters without executing markup, and the selected chart
point keeps its full name when ordinary sample labels are hidden. This is a
correctness fixture, not a throughput benchmark or supported-size guarantee.

## Browser checks performed

- Tab followed by Enter activates the skip link and focuses the workspace.
- The accessibility tree exposes the chart's system, sample count and direction
  to the equivalent Results table.
- At 320 × 640 CSS pixels, the toolbar controls stack without overlapping and
  the document has no horizontal overflow.
- At 800 × 500 CSS pixels, the page scrolls and the workspace retains space.
  This checks short-window reflow; it does not replace actual browser zoom tests.
- The muted text colour on the toolbar has calculated sRGB contrast 4.71:1
  (previously 4.19:1). Primary green on white is 8.33:1. Status badge text/background
  pairs checked exceed 5:1. This is a targeted palette check, not a full audit.

## Remaining manual coverage

- Test VoiceOver and NVDA announcements, forms, tab navigation and dialogs.
- Test actual 200% and 400% browser zoom, increased text size and forced colours.
- Repeat keyboard-only entry, CSV mapping/error review and Results row actions
  in Safari, Firefox and Chromium, including focus after dynamic updates.
- Exercise larger real datasets on target hardware. All points are still plotted;
  coincident points overlap and long chart labels can be clipped. Hide labels and
  use the Results table for exact names and values.
