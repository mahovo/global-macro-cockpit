# app.R — Global Macro Cockpit (local, live edition)
#
# A registry-driven, multi-provider monitoring board. Series are defined in
# instructions/sources.yaml (plus instructions/sources_global.yaml); the ingestion
# layer (R/fetch.R + R/fetchers/*) resolves them to tidy-long data; this app lays
# them out along the transmission chain (R/views.R) with one tile per series.
# Tabs fetch lazily (Shiny suspends hidden outputs), matching the spec's
# fetch-on-view model. Built for single-user local use; the public website is a
# static build of the same tiles (scripts/build_site.R).
#
# Run from the project root:  Rscript -e 'shiny::runApp(launch.browser = TRUE)'
# Set FRED_API_KEY to use the official FRED API (recommended).

library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)

# --- load ingestion + presentation layers (fetchers first) ------------------
# The R files contain UTF-8 text (dashes, bullets, sigma). R/utf8.R switches the
# session to a UTF-8 locale if needed, then everything is read as UTF-8.
source("R/utf8.R")
for (f in list.files("R/fetchers", pattern = "\\.R$", full.names = TRUE)) source(f, encoding = "UTF-8")
for (f in c("R/utils_cache.R", "R/registry.R", "R/transforms.R", "R/fetch.R",
            "R/assess.R", "R/display.R", "R/views.R", "R/help.R", "R/tiles.R",
            "R/licensing.R")) {
  source(f, encoding = "UTF-8")
}

REGISTRY <- load_registry()
META     <- REGISTRY$meta
LIC      <- load_licenses()   # credit line per series, shared with the public build

# Resolution statuses from the validation report (ok / manual / pending). The app
# renders ok + manual tiles; pending sources are counted, not shown.
load_statuses <- function() {
  path <- "instructions/registry_coverage.csv"
  if (!file.exists(path)) return(character(0))
  d <- utils::read.csv(path, stringsAsFactors = FALSE)
  stats::setNames(d$status, d$id)
}
STATUSES <- load_statuses()
status_of <- function(id) {
  s <- STATUSES[[id]]
  if (is.null(s) || is.na(s)) "pending" else if (s == "ok") "ok" else if (s == "manual") "manual" else "pending"
}

# Flat list of all renderable entries (deduped by id across themes).
.all_series   <- REGISTRY$series
.dedup        <- !duplicated(vapply(.all_series, function(e) e$id, ""))
.all_series   <- .all_series[.dedup]
DATA_ENTRIES  <- Filter(function(e) status_of(e$id) == "ok",     .all_series)
DATA_IDS      <- vapply(DATA_ENTRIES, function(e) e$id, "")

# --- tile UI (card chrome, popovers and charts live in R/tiles.R) ------------
is_regime <- function(entry) identical(entry$chart, "regime")

data_tile <- function(entry) {
  id <- entry$id
  # The growth/inflation regime tile is one block (regime_body() in R/tiles.R).
  if (is_regime(entry)) {
    return(tile_shell(entry, footer = attribution_tag(entry, LIC), uiOutput(paste0("body_", id))))
  }
  tile_shell(entry, footer = attribution_tag(entry, LIC),
    div(class = "d-flex justify-content-between align-items-baseline",
      div(class = "fs-4 fw-semibold", textOutput(paste0("val_", id), inline = TRUE)),
      div(class = "small text-muted text-nowrap ms-2", uiOutput(paste0("asof_", id), inline = TRUE))),
    div(class = "small mb-1", uiOutput(paste0("chg_", id), inline = TRUE),
        if (identical(entry$chart, "pair")) uiOutput(paste0("detail_", id))),
    uiOutput(paste0("badge_", id)),
    plotlyOutput(paste0("spark_", id), height = "150px", fill = FALSE)
  )
}

view_panel <- function(view) {
  series   <- view_series(view, REGISTRY)
  render   <- Filter(function(e) status_of(e$id) %in% c("ok", "manual"), series)
  pending  <- length(series) - length(render)
  tiles <- lapply(render, function(e)
    if (status_of(e$id) == "manual") manual_tile(e, REGISTRY$providers) else data_tile(e))

  nav_panel(
    title = view$title,
    div(class = "text-muted small mt-2",
      sprintf("Cockpit zone: %s", view$zone),
      if (pending > 0) span(class = "ms-2", sprintf("· %d source(s) pending", pending))),
    div(class = "border-start border-3 ps-2 mb-3 mt-1 text-body-secondary small",
        style = "max-width: 900px;", view_help(view$id)),
    if (length(tiles))
      do.call(layout_column_wrap, c(list(width = "330px", heights_equal = "row"), tiles))
    else div(class = "text-muted py-4", "All sources for this view are pending.")
  )
}

# --- UI ----------------------------------------------------------------------
ui <- page_sidebar(
  title = "Global Macro Cockpit",
  theme = bs_theme(version = 5, preset = "flatly"),
  fillable = FALSE,
  sidebar = sidebar(
    width = 300,
    dateInput("start_date", "Show history since",
      value = Sys.Date() - 365 * 3, max = Sys.Date(), weekstart = 1),
    radioButtons("view_mode", "Display mode",
      choices = c("Level" = "level", "Z-score" = "z", "Percentile" = "pct"),
      selected = "level", inline = TRUE),
    actionButton("refresh", "Refresh data", icon = icon("rotate"), class = "btn-primary"),
    hr(),
    div(class = "p-2 rounded border bg-body-tertiary",
      div(class = "fw-semibold mb-2", "Recession watch"),
      div(class = "d-flex justify-content-between align-items-baseline",
        span(class = "text-muted small", "Recession signals"),
        span(class = "fs-5 fw-bold", uiOutput("snap_signals", inline = TRUE))),
      div(class = "d-flex justify-content-between align-items-baseline",
        span(class = "text-muted small", "Cautions"),
        span(class = "fs-5 fw-bold", uiOutput("snap_cautions", inline = TRUE))),
      div(class = "small text-muted mt-1", "Updated ", textOutput("snap_refreshed", inline = TRUE))),
    hr(),
    div(class = "small",
      strong("Cycle read legend"), br(),
      span(class = "badge text-bg-success", "good"), " on track ", br(),
      span(class = "badge text-bg-warning", "warn"), " caution ", br(),
      span(class = "badge text-bg-danger", "bad"), " recession signal "),
    hr(),
    helpText(class = "small",
      "Leading-indicator-first. Data: FRED, OECD, Eurostat, ECB, IMF, Bank of England, ONS, Bank of Japan, New York Fed (public APIs). ",
      "Manual tiles are licensed/headline-only. Not investment advice."),
    div(class = "small text-muted",
      "Co-written by Claude Code Opus 5", br(), "Directed by Martin Hoshi Vognsen")
  ),
  do.call(navset_tab, lapply(VIEWS, view_panel)),
  ESC_DISMISS_JS
)

# --- server ------------------------------------------------------------------
server <- function(input, output, session) {

  # "Refresh data" must pull data published since the last fetch, so clear the
  # on-disk cache before the tiles recompute (high priority = runs first).
  # ignoreInit keeps the initial load fast (it may reuse a fresh cache).
  observeEvent(input$refresh, {
    unlink(file.path(getwd(), ".cache"), recursive = TRUE)
  }, priority = 1000, ignoreInit = TRUE)

  # One lazy data reactive per renderable series (suspended on hidden tabs).
  # End date is Sys.Date() evaluated at fetch time, so the window always runs
  # through today rather than a date baked in when the app started.
  data_r <- lapply(DATA_ENTRIES, function(e) {
    eventReactive(input$refresh, {
      withProgress(message = paste("Fetching", display_title(e)), {
        tryCatch(fetch_series(e, input$start_date, Sys.Date(), META),
                 error = function(err) NULL)
      })
    }, ignoreNULL = FALSE)
  })
  names(data_r) <- DATA_IDS

  # The regime tile renders as one block and looks the same in every display mode.
  for (e in Filter(is_regime, DATA_ENTRIES)) local({
    ent <- e; dr <- data_r[[ent$id]]
    output[[paste0("body_", ent$id)]] <- renderUI({
      raw <- dr()
      validate(need(!is.null(raw) && nrow(raw) > 0, "No data — click Refresh."))
      regime_body(raw, ent$frequency)
    })
  })

  # Wire the five outputs for each other data tile.
  for (e in Filter(Negate(is_regime), DATA_ENTRIES)) local({
    ent <- e; id <- ent$id; dr <- data_r[[id]]
    ass <- assess_for(id); ref <- display_ref(ent); unit <- display_unit(ent)

    output[[paste0("val_", id)]]   <- renderText(value_label(dr(), input$view_mode, unit))
    output[[paste0("asof_", id)]]  <- renderUI(asof_tag(dr(), ent$frequency))
    output[[paste0("chg_", id)]]   <- renderUI(change_tag(dr(), input$view_mode))
    output[[paste0("badge_", id)]] <- renderUI(badge_tag(ass, dr()))   # reads the level
    if (identical(ent$chart, "pair")) output[[paste0("detail_", id)]] <- renderUI({
      raw <- dr()
      pair_detail(raw, input$view_mode, if (!is.null(ass) && !is.null(raw)) ass(raw)$tone else "neutral")
    })

    output[[paste0("spark_", id)]] <- renderPlotly({
      raw <- dr()
      validate(need(!is.null(raw) && nrow(raw) > 0, "No data — click Refresh."))
      tone <- if (!is.null(ass)) ass(raw)$tone else "neutral"
      if (identical(ent$chart, "pair")) spark_plot_pair(raw, input$view_mode, tone)
      else spark_plot(apply_mode(raw, input$view_mode), ent$frequency, tone,
                      mode_ref(input$view_mode, ref))
    })
  })

  # --- Recession-watch snapshot (headline assessed series) -------------------
  rw_view <- Filter(function(v) v$id == "recession", VIEWS)[[1]]
  rw_ids  <- intersect(vapply(view_series(rw_view, REGISTRY), function(e) e$id, ""), DATA_IDS)
  rw_ids  <- Filter(function(id) !is.null(assess_for(id)), rw_ids)

  snap_tones <- reactive({
    vapply(rw_ids, function(id) {
      df <- data_r[[id]](); if (is.null(df) || !nrow(df)) return("neutral")
      assess_for(id)(df)$tone
    }, character(1))
  })

  output$snap_signals <- renderUI({
    t <- snap_tones(); n <- sum(t == "bad")
    span(style = sprintf("color:%s", if (n > 0) TONE_COLOUR[["bad"]] else TONE_COLOUR[["good"]]),
         sprintf("%d of %d", n, length(rw_ids)))
  })
  output$snap_cautions <- renderUI({
    t <- snap_tones(); n <- sum(t == "warn")
    span(style = sprintf("color:%s", if (n > 0) TONE_COLOUR[["warn"]] else TONE_COLOUR[["neutral"]]),
         as.character(n))
  })
  output$snap_refreshed <- renderText({ input$refresh; format(Sys.time(), "%Y-%m-%d %H:%M") })
}

shinyApp(ui, server)
