# Shared theme and semantic page structure. All assets and fonts work locally.
build_app_ui <- function() {
  bslib::page_fluid(
    title = "Soil Texture | Classification workspace",
    theme = bslib::bs_theme(
      version = 5, bg = "#f5f5ef", fg = "#25392f", primary = "#245744",
      secondary = "#67756b", success = "#245744", danger = "#9f4035",
      base_font = '"Segoe UI", system-ui, -apple-system, sans-serif',
      heading_font = '"Segoe UI", system-ui, -apple-system, sans-serif',
      "border-radius" = "0.5rem", "font-size-base" = "0.9375rem"
    ),
    tags$head(tags$link(rel = "stylesheet", href = "app.css"),
              tags$script(src = "edit-focus.js", defer = NA)),
    tags$a(class = "skip-link", href = "#classification-workspace", "Skip to texture workspace"),
    tags$div(class = "app-shell",
      tags$header(class = "app-header",
        tags$div(class = "brand",
          tags$div(class = "brand-mark", `aria-hidden` = "true", "△"),
          tags$div(tags$p(class = "eyebrow", "SOIL SCIENCE WORKSPACE"),
                   tags$h1("Soil Texture"))
        ),
        tags$p(class = "header-note", "Explore the composition beneath the surface.")
      ),
      tags$section(class = "workspace-bar", `aria-label` = "Workspace controls",
        tags$div(class = "classification-control",
          selectInput("dataset", "Classification system",
                      choices = classification_choices(),
                      selected = "New Zealand", selectize = FALSE)
        ),
        tags$div(class = "workspace-stats", `aria-live` = "polite", uiOutput("workspaceStats", inline = TRUE)),
        downloadButton("downloadDataBtn", "Download CSV", class = "btn-primary"),
        tags$div(class = "system-context", `aria-live` = "polite", uiOutput("systemRequirements"))
      ),
      tags$nav(class = "mobile-workspace-nav", `aria-label` = "Workspace shortcuts",
        tags$a(href = "#sample-entry", "Add samples"),
        tags$a(href = "#classification-workspace", "View results",
          onclick = "Shiny.setInputValue('openResults', Date.now(), {priority: 'event'});")),
      tags$main(class = "workspace-grid",
        tags$aside(id = "sample-entry", class = "sample-panel panel", `aria-label` = "Sample entry",
          tags$div(class = "panel-heading",
            tags$p(class = "eyebrow", "01 / YOUR DATA"),
            tags$h2("Add samples"),
            tags$p("Enter a composition or bring your own CSV.")
          ),
          tabsetPanel(id = "entryMode", type = "tabs",
            tabPanel("Manual entry", value = "manual",
              tags$div(class = "entry-content",
                textInput("sampleName", "Sample name", placeholder = "e.g. North paddock, 0–15 cm"),
                tags$div(class = "composition-inputs",
                  numericInput("sandValue", "Sand (%)", value = 50, min = 0, max = 100),
                  numericInput("siltValue", "Silt (%)", value = 25, min = 0, max = 100),
                  numericInput("clayValue", "Clay (%)", value = 25, min = 0, max = 100)
                ),
                tags$div(`aria-live` = "polite", uiOutput("compositionTotal")),
                tags$details(class = "remaining-helper", tags$summary("Calculate a remaining percentage"),
                  selectInput("remainderComponent", "Calculate", choices = c("Clay (%)" = "clay", "Silt (%)" = "silt", "Sand (%)" = "sand"), selectize = FALSE),
                  actionButton("calculateRemainderBtn", "Use 100 minus the other two", class = "btn-outline-primary")),
                tags$p(class = "entry-error", role = "alert", textOutput("manualError", inline = TRUE)),
                actionButton("addManualDataBtn", "Add sample", class = "btn-primary add-sample")
              )
            ),
            tabPanel("CSV upload", value = "upload",
              tags$div(class = "entry-content",
                radioButtons("csvFormat", "CSV contents",
                             choices = c("Samples (map columns)" = "samples",
                                         "Downloaded results (8 columns)" = "results"),
                             selected = "samples"),
                tags$p(class = "field-help", "Choose CSV contents, then select a file. Review the preview and choose Append or Replace before importing. Changing CSV contents clears the preview; select the file again."),
                fileInput("fileUpload", "Choose a CSV file", accept = ".csv",
                          buttonLabel = "Browse", placeholder = "No file selected"),
                tags$p(class = "field-help", "Map sample name, sand, silt and clay columns. Percentages must total 100; rounded totals are not automatically normalized."),
                tags$p(class = "entry-error", role = "alert", textOutput("uploadError", inline = TRUE)),
                uiOutput("uploadMapping"), uiOutput("uploadPreview"),
                conditionalPanel("input.csvFormat === 'results'",
                  tags$p(class = "field-help", "Downloaded results restore names and percentages only. Saved classifications are replaced using the currently selected system. Particle-size measurements are not converted; select a compatible system before uploading.")),
                downloadButton("downloadTemplateBtn", "Get CSV template", class = "btn-outline-primary")
              )
            )
          ),
          tags$div(class = "session-note",
            tags$p(class = "sample-feedback", role = "status", textOutput("sampleFeedback", inline = TRUE)),
            uiOutput("undoControl"),
            tags$p("Samples are saved only for this session. Use Download CSV before refreshing or closing this page. To restore them later, choose Downloaded results under CSV upload."),
            actionButton("clearDataBtn", "Clear all samples", class = "btn-clear")
          ),
          tags$details(class = "help-details",
            tags$summary("How to read your results"),
            tags$p("Each composition is a point on the triangle. The Results tab lists its class and candidate classes."),
            tags$p("A shared boundary or overlapping region can have more than one candidate. These samples are marked for review rather than assigned a single class.")
          ),
          tags$div(class = "sidebar-resources",
            tags$details(class = "about-details",
              tags$summary("About & methodology"),
              tags$div(class = "about-content",
                uiOutput("classificationReference"),
                tags$p("A known overlap remains in the Australian data. Source verification of the original NZ, USDA, and Australian polygons is ongoing."),
                tags$p("Boundary and overlap reporting is a software policy. It does not resolve the underlying scientific conventions."),
                tags$a("View methodology notes", href = "methodology.html", target = "_blank", rel = "noopener")
              )
            ),
            tags$a("Contact Josie Mazzetto", class = "sidebar-contact",
                   href = "mailto:josiane.lopesmazzetto@lincoln.ac.nz"),
            tags$img(class = "sidebar-logo", src = "branding/lincoln_uni.jpg", alt = "Lincoln University")
          )
        ),
        tags$section(id = "classification-workspace", tabindex = "-1", class = "visual-panel panel", `aria-label` = "Classification workspace",
          tags$div(class = "panel-heading visual-heading",
            tags$div(tags$p(class = "eyebrow", "02 / EXPLORE"), tags$h2("Texture workspace")),
            tags$span(class = "sample-key", tags$span(class = "sample-dot", `aria-hidden` = "true"), "Your samples")
          ),
          tabsetPanel(id = "workspaceView", type = "tabs",
            tabPanel("Triangle", value = "triangle",
              tags$div(class = "plot-options",
                checkboxInput("showSampleLabels", "Sample labels", value = TRUE),
                checkboxInput("avoidLabelOverlap", "Hide overlapping labels", value = TRUE),
                actionButton("enlargePlotBtn", "Enlarge", class = "btn-outline-primary"),
                actionButton("classKeyBtn", "Class key", class = "btn-outline-primary"),
                downloadButton("downloadPlotBtn", "PNG", class = "btn-outline-primary")),
              tags$div(class = "plot-selection", uiOutput("plotSelection")),
              tags$div(class = "plot-frame", plotOutput("ternaryPlot", height = "100%", width = "100%")),
              tags$p(class = "plot-caption", "Sand, silt, and clay as a percentage of the sample. Region colours distinguish texture classes.")
            ),
            tabPanel("Results", value = "results",
              tags$div(class = "results-content",
                tags$p(class = "results-summary", `aria-live` = "polite", textOutput("resultsSummary", inline = TRUE)),
                tags$div(class = "results-controls",
                  tags$div(class = "results-search-sort",
                    textInput("sampleSearch", "Search samples", placeholder = "Sample name contains…"),
                    selectInput("resultsSort", "Sort by", choices = c("Entry order" = "input", "Sample name" = "soil",
                      "Sand (%)" = "sand", "Silt (%)" = "silt", "Clay (%)" = "clay", "Class" = "classification",
                      "Status" = "classification_status", "Candidate classes" = "classification_candidates"), selectize = FALSE),
                    selectInput("resultsPageSize", "Rows per page", choices = c(25, 50, 100), selected = 25, selectize = FALSE)),
                  tags$div(class = "results-flags",
                    checkboxInput("sortDescending", "Descending order", value = FALSE),
                    checkboxInput("reviewOnly", "Only samples needing review", value = FALSE)),
                  tags$p(class = "field-help", `aria-live` = "polite", textOutput("resultsFilterSummary", inline = TRUE))),
                tags$div(class = "results-table", tabindex = "0", `aria-label` = "Sample results; scroll horizontally for more columns", uiOutput("resultsTable")),
                tags$div(class = "results-pagination", uiOutput("resultsPagination", inline = TRUE)),
                tags$details(class = "results-help field-help", tags$summary("Results help"),
                  tags$p("Use View, Edit or Delete beside a sample name. Undo in the sample panel restores the latest change. A dash means no single class was assigned; review the status and candidate classes."))
              )
            )
          )
        )
      )
    )
  )
}

build_plain_table <- function(data) {
  tags$table(class = "table table-sm",
    tags$thead(tags$tr(lapply(names(data), function(name) tags$th(scope = "col", name)))),
    tags$tbody(lapply(seq_len(nrow(data)), function(i) tags$tr(lapply(data[i, , drop = FALSE], function(value) tags$td(as.character(value)))))))
}

build_system_requirements <- function(definition) {
  # Show the measurement sentence verbatim; detailed scope notes remain in About.
  fractions <- if (is.null(definition$fractions)) {
    "Requirements not yet documented for these polygons; check source methodology against your laboratory fractions."
  } else {
    sentence <- strsplit(definition$fractions, ". ", fixed = TRUE)[[1]][1]
    if (endsWith(sentence, ".")) sentence else paste0(sentence, ".")
  }
  tagList(
    tags$p(class = "system-selected", definition$display),
    tags$p(tags$strong("Measurements: "), fractions),
    tags$p(class = "system-note", "Changing systems does not convert measurements."),
    if (is.null(definition$source)) tags$p(class = "system-warning", "Source verification pending for these project polygons."),
    if (identical(definition$id, "Australian")) tags$p(class = "system-warning", "Known Sand / Sandy Loam overlap: some samples have multiple candidate classes.")
  )
}

build_results_table <- function(results, revision = NULL, row_indices = seq_len(nrow(results))) {
  stopifnot(length(row_indices) == nrow(results))
  if (!nrow(results)) {
    return(tags$div(class = "empty-state", tags$span(class = "empty-symbol", `aria-hidden` = "true", "△"),
      tags$h3("Your samples will appear here"),
      tags$p("Add your first sample or upload a CSV to explore its texture class.")))
  }
  labels <- c(classified = "Classified", boundary = "Boundary", overlap = "Overlap", unclassified = "Unclassified")
  tags$table(class = "table sample-results",
    tags$caption(class = "visually-hidden", "Soil sample percentages and classification results"),
    tags$thead(tags$tr(lapply(names(results), function(name) tags$th(scope = "col", name)))),
    tags$tbody(lapply(seq_len(nrow(results)), function(i) {
      row <- results[i, ]
      status <- row$Status
      cells <- lapply(names(row), function(name) {
        if (name == "Status") {
          assigned <- row$Class != "—"
          label <- if (status == "boundary" && assigned) "Boundary (assigned)" else labels[[status]]
          explanation <- switch(status,
            boundary = if (assigned) "This point lies on an edge but matches only one class. A class is assigned, so it is not included in the review count." else
              "This point matches more than one region at a boundary. Check the candidate classes and the selected system's boundary conventions. No single class is assigned.",
            overlap = "This point is inside overlapping class regions. Check the candidate classes and methodology notes; the definitions need review. No single class is assigned.",
            unclassified = "No class region matches this point. Check the measurements, particle-size definitions and selected system, then consult the methodology notes.",
            NULL)
          tags$td(tags$span(class = paste("status-badge", paste0("status-", status)), label),
            if (!is.null(explanation)) tags$details(class = "result-explanation",
              tags$summary("What this means"), tags$p(explanation)))
        } else {
          value <- row[[name]]
          if (is.numeric(value)) value <- format(value, trim = TRUE, scientific = FALSE, digits = 8)
          actions <- if (name == "Sample" && !is.null(revision)) {
            tags$div(class = "sample-row-actions", lapply(c("View", "Edit", "Delete"), function(action) {
              tags$button(type = "button", class = paste("btn btn-sm", if (action == "Delete") "btn-outline-danger" else "btn-outline-primary"),
                `aria-label` = paste(action, "sample", row_indices[i], value),
                `data-action` = tolower(action), `data-row` = row_indices[i], `data-revision` = revision,
                onclick = sprintf("Shiny.setInputValue('%sSample', {row: Number(this.dataset.row), revision: Number(this.dataset.revision)}, {priority: 'event'});", tolower(action)),
                action)
            }))
          }
          tags$td(value, actions)
        }
      })
      tags$tr(cells)
    }))
  )
}
