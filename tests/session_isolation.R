# Interleave two sessions in a single R process, as on a shared Shiny worker.
source("R/dependencies.R")
ensure_project_dependencies()
app_env <- new.env()
source("soil_triangle.R", local = app_env)

open_session <- function() {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    app_env$server(session$input, session$output, session)
    session$setInputs(dataset = "New Zealand", addManualDataBtn = 0, undoDataBtn = 0)
  })
  session
}

check_sessions <- function() {
  alice <- open_session()
  on.exit(alice$close(), add = TRUE)
  bob <- open_session()
  on.exit(bob$close(), add = TRUE)
  add <- function(session, name) shiny::withReactiveDomain(session, {
    session$setInputs(sampleName = name, sandValue = 50, siltValue = 25,
                      clayValue = 25, addManualDataBtn = 1)
  })
  exported_names <- function(session) shiny::withReactiveDomain(session, {
    shiny::isolate(read.csv(session$getOutput("downloadDataBtn"))$soil)
  })

  add(alice, "North paddock")
  add(bob, "South paddock")
  stopifnot(identical(exported_names(alice), "North paddock"),
            identical(exported_names(bob), "South paddock"))
  shiny::withReactiveDomain(alice, alice$setInputs(undoDataBtn = 1))
  stopifnot(length(exported_names(alice)) == 0L,
            identical(exported_names(bob), "South paddock"))
}

check_sessions()
cat("Independent sessions: interleaved entry, undo and CSV export PASS\n")
