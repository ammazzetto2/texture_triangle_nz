# User guide

See the [README](../README.md#quick-start) for installation and startup.

## Use the app

1. Choose the shared **Classification system** at the top of the workspace.
   The toolbar shows the selected system's documented particle-size requirements
   and reminds you that switching systems does not convert measurements. Where
   requirements are undocumented, the app says so; original project polygons
   retain their source-verification notice. Australia also shows its known overlap.
2. Under **Add samples**, use **Manual entry** to enter a name and sand, silt,
   and clay percentages, then select **Add sample**. The live composition total
   indicates whether the percentages add up to 100 and shows any difference.
   Errors appear inline. **Calculate a remaining percentage** fills the chosen
   component with 100 minus the other two; it does not normalize all values.
3. Alternatively, use **CSV upload**. **Get CSV template** provides the required
   header; add sample rows before uploading it. Map columns, review the preview,
   choose Append or Replace, then select **Import reviewed samples**. Selecting
   a file alone does not change the workspace.
   To reopen an exported results CSV, choose **Downloaded results (8 columns)**
   before selecting the file. Names and percentages are restored; classifications
   are recalculated using the currently selected system. Choose a system compatible
   with your laboratory fractions: importing does not convert measurements.
4. Explore **Triangle**, or open **Results** to review classes, labelled status
   badges, and candidate classes. The top bar counts samples that need review
   because they have no single assigned class. On narrow screens, scroll the
   table horizontally to see all columns.
   Click **need review** to open Results with **Only samples needing review**
   enabled. Turn off the filter to see all rows. **What this means** explains
   boundary, overlap and unclassified statuses. **Boundary (assigned)** means
   an edge point has one matching class and is excluded from the review count.
   Filtering does not change the triangle or CSV export, which still include
   all samples. Edit, Delete and Undo remain available for filtered rows.
5. Select **Download CSV** to export all current samples and classification
   details. **Sample labels** on the Triangle tab can be turned off for crowded
   datasets; the points remain visible.

### Chart tools

- **Enlarge** opens a larger chart using the current label controls and highlight.
- **PNG** downloads a 3000 × 2700 pixel chart with the system name and current
  highlight. All samples are included, even when Results is filtered.
- **Class key** opens plot labels and full class names beside the chart workflow.
- **Hide overlapping labels** suppresses colliding sample labels while keeping
  all points. It does not move points or prevent collisions with class labels.
  Turn it off to show every sample label.
- **View** beside a Results row highlights that exact sample with a blue ring,
  bold label and composition summary. This also works with duplicate names and
  filtered results. The highlighted label stays visible when other labels are
  hidden. **Clear highlight** removes the selection. Changes to sample data,
  including Undo, clear the highlight so it cannot move to another row.

### Results navigation

Search sample names using a case-insensitive, literal substring. **Sort by**
orders names, percentages, classes, status or candidates; **Descending order**
reverses the direction. Missing classes remain last. **Entry order** returns to
the original row sequence. Search combines with the review filter; clicking the
top **need review** count clears the name search.

Results show 25 rows per page by default, with 50 and 100 available. Use
**Previous** and **Next** to browse. Changing search, sorting, page size, review
filter or classification system returns to page one. View, Edit and Delete
always target the original sample, regardless of table order. Exports and the
triangle include all samples. Mobile screens have sticky **Add samples** and
**View results** shortcuts.

Manual entries and uploaded samples share one dataset for the current session.
Importing appends samples by default; **Replace all current samples** replaces
the dataset when the reviewed import is submitted. **Clear all samples** clears the dataset. **Undo**
restores the dataset before the latest successful add, upload, edit, delete, or clear (one
level, within this session). Invalid input leaves that undo available. Manual
entry clears the sample name after success and rejects an identical name and
composition already in the dataset; use distinct names for replicate samples.
CSV uploads preserve all supplied rows, including duplicates. Download
results before closing the session if you want to keep them.

In **Results**, use **Edit** beside a sample name to correct its name or
percentages, then **Save changes**. Invalid edits stay in the editor with an
explanation; **Cancel** leaves the sample unchanged. **Delete** removes only
that row, even when multiple samples have the same name. Both edits and deletes
can be undone using the sample panel. Changes update the triangle, results and
CSV download together.

The interface uses a shared Bootstrap 5 theme, system fonts, and local styles
and branding assets, with no external font requests. The desktop workspace fits
the browser height: the triangle resizes and long results scroll inside their
panel. On smaller screens the layout stacks and normal page scrolling keeps
controls readable. **About & methodology** in the left panel links to local notes
covering classification behavior and the known Australian polygon overlap.

## CSV format

The template uses these column names (the order may vary):

```csv
soil,sand,silt,clay
Sample A,50,25,25
Sample B,20,20,60
Sample C,90,5,5
```

A ready-to-upload file is available at
[`examples/soil_samples.csv`](../examples/soil_samples.csv).

- `soil`: a nonblank sample name. Surrounding whitespace is removed.
- `sand`, `silt`, `clay`: numeric percentages from 0 to 100, adding up to 100
  for each sample. Use percentages, not fractions between 0 and 1.
- In **Samples (map columns)** mode, choose four distinct source columns for
  the sample name and percentages. Other columns are explicitly listed as
  excluded in the preview. Headers must be nonblank and unique.
- Use a comma separator and a decimal point for fractional percentages.

**Downloaded results (8 columns)** mode accepts exactly the four sample columns
plus `classification`, `classification_system`, `classification_status`, and
`classification_candidates`, in any order. The four saved classification fields
are discarded, and current results are recalculated. This restores sample data,
not the previous system selection or undo history. Both modes offer Append and
Replace, with single-step Undo after import.
Sample names such as `001` and `NA` are preserved as text.

The preview shows the first 10 rows and up to 25 issues. **Download all errors**
exports every issue with its sample row number (excluding the header), field,
original value and explanation. Correct the source file and select it again;
no subset of an invalid file is imported. Changing CSV contents clears the staged
preview and requires selecting the file again.

Manual entries and uploads use the same measurement validation rules. Invalid
mappings, empty tables, blank sample names, nonnumeric percentages,
missing or infinite values, and percentages outside 0–100 are rejected. Invalid
totals report sample row numbers (excluding the CSV header). Rejected input
leaves existing samples intact; an upload is accepted only if all rows are valid.
The internal `read_soil_csv()` helper retains its strict four/eight-column schema
for programmatic callers; the interactive preview handles custom column mapping.

Totals use an absolute tolerance of `1e-8` percentage points to accommodate
floating-point arithmetic. Values are not normalized or rounded automatically.
This tolerance does not accommodate laboratory measurement or rounding error.

