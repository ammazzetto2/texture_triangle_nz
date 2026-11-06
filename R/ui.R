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
    tags$head(tags$link(rel = "stylesheet", href = "app.css")),
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
        downloadButton("downloadDataBtn", "Download CSV", class = "btn-primary")
      ),
      tags$main(class = "workspace-grid",
        tags$aside(class = "sample-panel panel", `aria-label` = "Sample entry",
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
                actionButton("addManualDataBtn", "Add sample", class = "btn-primary add-sample")
              )
            ),
            tabPanel("CSV upload", value = "upload",
              tags$div(class = "entry-content",
                fileInput("fileUpload", "Choose a CSV file", accept = ".csv",
                          buttonLabel = "Browse", placeholder = "No file selected"),
                tags$p(class = "field-help", "Include soil, sand, silt, and clay columns. Percentages must total 100 for every sample."),
                downloadButton("downloadTemplateBtn", "Get CSV template", class = "btn-outline-primary")
              )
            )
          ),
          tags$div(class = "session-note",
            tags$p(class = "sample-feedback", role = "status", textOutput("sampleFeedback", inline = TRUE)),
            uiOutput("undoControl"),
            tags$p("Samples stay in this session. Download your results before closing."),
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
        tags$section(class = "visual-panel panel", `aria-label` = "Classification workspace",
          tags$div(class = "panel-heading visual-heading",
            tags$div(tags$p(class = "eyebrow", "02 / EXPLORE"), tags$h2("Texture workspace")),
            tags$span(class = "sample-key", tags$span(class = "sample-dot", `aria-hidden` = "true"), "Your samples")
          ),
          tabsetPanel(id = "workspaceView", type = "tabs",
            tabPanel("Triangle", value = "triangle",
              tags$div(class = "plot-options", checkboxInput("showSampleLabels", "Sample labels", value = TRUE)),
              tags$div(class = "plot-frame", plotOutput("ternaryPlot", height = "100%", width = "100%")),
              tags$p(class = "plot-caption", "Sand, silt, and clay as a percentage of the sample. Region colours distinguish texture classes.")
            ),
            tabPanel("Results", value = "results",
              tags$div(class = "results-content",
                tags$p(class = "results-summary", `aria-live` = "polite", textOutput("resultsSummary", inline = TRUE)),
                tags$div(class = "results-table", tabindex = "0", `aria-label` = "Sample results; scroll horizontally for more columns", uiOutput("resultsTable")),
                tags$p(class = "field-help", "Use Edit or Delete beside a sample name. Undo in the sample panel restores the latest change. A dash means no single class was assigned; review the status and candidate classes.")
              )
            )
          )
        )
      )
    )
  )
}

build_results_table <- function(results, revision = NULL) {
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
          tags$td(tags$span(class = paste("status-badge", paste0("status-", status)), labels[[status]]))
        } else {
          value <- row[[name]]
          if (is.numeric(value)) value <- format(value, trim = TRUE, scientific = FALSE, digits = 8)
          actions <- if (name == "Sample" && !is.null(revision)) {
            tags$div(class = "sample-row-actions", lapply(c("Edit", "Delete"), function(action) {
              tags$button(type = "button", class = paste("btn btn-sm", if (action == "Edit") "btn-outline-primary" else "btn-outline-danger"),
                `aria-label` = paste(action, "sample", i, value),
                `data-row` = i, `data-revision` = revision,
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
