#!/usr/bin/env Rscript
# build_site.R — render the static public edition of Global Macro Cockpit into _site/.
#
# Runs locally or in GitHub Actions (.github/workflows/pages.yml). It fetches the
# series that instructions/data_licenses.csv allows to be republished, renders the
# same tiles as the local Shiny app (R/tiles.R) into one static page with
# interactive plotly charts, and writes _site/index.html plus _site/lib/.
#
# Run from the project root:  Rscript scripts/build_site.R
# FRED_API_KEY is required in CI and recommended locally.
#
# This script's own strings are ASCII-only (non-ASCII characters are built with
# intToUtf8()), because Rscript parses it before the locale can be adjusted.

suppressMessages({
  library(bslib); library(htmltools); library(dplyr); library(plotly)
})

# The R files contain UTF-8 text (dashes, bullets, sigma). R/utf8.R switches the
# session to a UTF-8 locale if needed (Rscript with LANG unset runs in the C
# locale), then everything is read as UTF-8.
source("R/utf8.R")
for (f in list.files("R/fetchers", pattern = "\\.R$", full.names = TRUE)) source(f, encoding = "UTF-8")
for (f in c("R/utils_cache.R", "R/registry.R", "R/transforms.R", "R/fetch.R",
            "R/assess.R", "R/display.R", "R/views.R", "R/help.R", "R/tiles.R",
            "R/licensing.R")) {
  source(f, encoding = "UTF-8")
}

OUT_DIR  <- "_site"
YEARS    <- 5
MIN_OK   <- 0.90
MODES    <- c("level", "z", "pct")
REPO_URL <- "https://github.com/mahovo/global-macro-cockpit"
TODAY    <- Sys.Date()
START    <- TODAY - round(365.25 * YEARS)
BUILT_AT <- format(Sys.time(), "%Y-%m-%d %H:%M UTC", tz = "UTC")
USES_API <- nzchar(fred_api_key())
DOT      <- intToUtf8(0xB7)     # middle dot
ARROW    <- intToUtf8(0x203A)   # single right-pointing angle quotation mark
REG      <- intToUtf8(0xAE)     # registered sign

if (nzchar(Sys.getenv("CI")) && !USES_API) {
  stop("FRED_API_KEY must be set for the automated build (add it as a repository secret).",
       call. = FALSE)
}

REGISTRY <- load_registry()
META     <- REGISTRY$meta
LIC      <- load_licenses()

# The validation report says which series have a working fetcher (ok), are
# licensed headline tiles (manual), or aren't wired up yet (pending).
COVERAGE <- utils::read.csv("instructions/registry_coverage.csv", stringsAsFactors = FALSE)
status_of <- function(id) {
  s <- COVERAGE$status[match(id, COVERAGE$id)]
  if (is.na(s)) "pending" else s
}

# data = republishable and fetched; licensed = link only; manual = headline tile
kind_of <- function(e) {
  s <- status_of(e$id)
  if (s == "manual") return("manual")
  if (s != "ok") return("pending")
  if (publish_policy(e, LIC) == "publish") "data" else "licensed"
}

ALL  <- REGISTRY$series[!duplicated(vapply(REGISTRY$series, function(e) e$id, ""))]
KIND <- stats::setNames(vapply(ALL, kind_of, ""), vapply(ALL, function(e) e$id, ""))

# --- fetch ---------------------------------------------------------------------
to_fetch <- ALL[KIND == "data"]
message(sprintf("Fetching %d republishable series (%s to %s; FRED via %s)...",
                length(to_fetch), START, TODAY, if (USES_API) "API" else "graph CSV"))
DATA <- lapply(to_fetch, function(e) {
  tryCatch({
    d <- fetch_series(e, START, TODAY, META)
    if (is.null(d) || !nrow(d)) NULL else d
  }, error = function(err) { message("  ! ", e$id, ": ", conditionMessage(err)); NULL })
})
names(DATA) <- vapply(to_fetch, function(e) e$id, "")
n_ok <- sum(!vapply(DATA, is.null, logical(1)))
message(sprintf("Resolved %d of %d.", n_ok, length(DATA)))
if (n_ok < MIN_OK * length(DATA)) {
  stop(sprintf("Only %d of %d series resolved (below %.0f%%); not publishing.",
               n_ok, length(DATA), 100 * MIN_OK), call. = FALSE)
}

# --- tiles ---------------------------------------------------------------------
mode_parts <- function(fun) {
  lapply(MODES, function(m) span(class = "mode-part", `data-mode` = m, fun(m)))
}

data_card <- function(e, df) {
  ass  <- assess_for(e$id)
  tone <- if (is.null(ass)) "neutral" else ass(df)$tone
  unit <- display_unit(e)
  tile_shell(e, footer = attribution_tag(e, LIC),
    div(class = "d-flex justify-content-between align-items-baseline",
      div(class = "fs-4 fw-semibold", mode_parts(function(m) value_label(df, m, unit))),
      div(class = "small text-muted text-nowrap ms-2", asof_tag(df, e$frequency))),
    div(class = "small mb-1", mode_parts(function(m) change_tag(df, m))),
    badge_tag(ass, df),
    spark_plot_modes(df, e$frequency, tone, display_ref(e), TODAY)
  )
}

link_label <- function(url) {
  if (grepl("fred\\.stlouisfed\\.org/series/", url)) sprintf("%s on FRED %s", basename(url), ARROW)
  else paste("View at source", ARROW)
}

licensed_card <- function(e) {
  urls <- source_urls_for(e, LIC)
  tile_shell(e, badge = "licensed", badge_class = "text-bg-secondary",
             footer = attribution_for(e, LIC),
    div(class = "text-muted small mb-2",
        "Copyrighted data: republishing it requires the rights holder's permission, ",
        "so it is linked rather than shown."),
    if (length(urls))
      div(class = "small d-flex flex-column gap-1",
          lapply(urls, function(u) tags$a(href = u, target = "_blank", rel = "noopener", link_label(u))))
  )
}

unavailable_card <- function(e) {
  tile_shell(e, footer = attribution_for(e, LIC),
    div(class = "text-muted small", "Data unavailable in this build."))
}

card_for <- function(e) {
  switch(KIND[[e$id]],
    manual   = manual_tile(e, REGISTRY$providers, footer = attribution_for(e, LIC)),
    licensed = licensed_card(e),
    data     = if (is.null(DATA[[e$id]])) unavailable_card(e) else data_card(e, DATA[[e$id]]))
}

view_panel <- function(view) {
  series  <- view_series(view, REGISTRY)
  shown   <- Filter(function(e) KIND[[e$id]] != "pending", series)
  pending <- length(series) - length(shown)
  nav_panel(
    title = view$title,
    div(class = "text-muted small mt-2", sprintf("Cockpit zone: %s", view$zone),
        if (pending > 0) span(class = "ms-2", sprintf("%s %d source(s) pending", DOT, pending))),
    div(class = "border-start border-3 ps-2 mb-3 mt-1 text-body-secondary small",
        style = "max-width: 900px;", view_help(view$id)),
    if (length(shown))
      do.call(layout_column_wrap,
              c(list(width = "330px", heights_equal = "row"), lapply(shown, card_for)))
    else div(class = "text-muted py-4", "All sources for this view are pending.")
  )
}

# --- sidebar -------------------------------------------------------------------
ABOUT <- paste(
  "This page is a static snapshot of an interactive dashboard developed for private use,",
  "rebuilt automatically each day. The public edition is deliberately limited to comply",
  "with data-licensing terms and security requirements: indicators whose licences do not",
  "permit republication are shown as links only, and live refresh and custom date ranges",
  sprintf("are not available. Last built: %s.", BUILT_AT))

radio_group <- function(name, choices, selected) {
  div(class = "btn-group btn-group-sm w-100", role = "group", `aria-label` = name,
    lapply(seq_along(choices), function(i) {
      id <- paste0(name, "-", choices[[i]])
      tagList(
        tags$input(type = "radio", class = "btn-check", name = name, id = id,
                   value = choices[[i]], autocomplete = "off",
                   checked = if (identical(choices[[i]], selected)) NA),
        tags$label(class = "btn btn-outline-primary", `for` = id, names(choices)[i]))
    }))
}

rw_view <- Filter(function(v) v$id == "recession", VIEWS)[[1]]
rw_ids  <- Filter(function(id) !is.null(assess_for(id)) && !is.null(DATA[[id]]),
                  vapply(view_series(rw_view, REGISTRY), function(e) e$id, ""))
rw_tone <- vapply(rw_ids, function(id) assess_for(id)(DATA[[id]])$tone, "")
n_bad   <- sum(rw_tone == "bad")
n_warn  <- sum(rw_tone == "warn")

# On phones the sidebar sits above the tiles in a short scrolling strip, so the
# edition notice and the controls are seen first (bslib's default puts it below).
side <- sidebar(
  width = 300,
  open = list(desktop = "open", mobile = "always-above"),
  max_height_mobile = "250px",
  div(class = "small text-muted edition-note",
      "Static public edition of a private dashboard",
      help_popover("About this edition", ABOUT, placement = "bottom")),
  div(tags$label(class = "form-label small fw-semibold mb-1", "Display mode"),
      radio_group("mode", c("Level" = "level", "Z-score" = "z", "Percentile" = "pct"), "level")),
  div(tags$label(class = "form-label small fw-semibold mb-1", "Zoom"),
      radio_group("zoom", c("1Y" = "1", "3Y" = "3", "5Y" = "5"), "3"),
      div(class = "small text-muted mt-1", "Z-scores and percentiles use the full 5-year window.")),
  hr(),
  div(class = "p-2 rounded border bg-body-tertiary",
    div(class = "fw-semibold mb-2", "Recession watch"),
    div(class = "d-flex justify-content-between align-items-baseline",
      span(class = "text-muted small", "Recession signals"),
      span(class = "fs-5 fw-bold",
           style = sprintf("color:%s", if (n_bad > 0) TONE_COLOUR[["bad"]] else TONE_COLOUR[["good"]]),
           sprintf("%d of %d", n_bad, length(rw_ids)))),
    div(class = "d-flex justify-content-between align-items-baseline",
      span(class = "text-muted small", "Cautions"),
      span(class = "fs-5 fw-bold",
           style = sprintf("color:%s", if (n_warn > 0) TONE_COLOUR[["warn"]] else TONE_COLOUR[["neutral"]]),
           as.character(n_warn))),
    div(class = "small text-muted mt-1", "Built ", BUILT_AT)),
  hr(),
  div(class = "small",
    strong("Cycle read legend"), br(),
    span(class = "badge text-bg-success", "good"), " on track ", br(),
    span(class = "badge text-bg-warning", "warn"), " caution ", br(),
    span(class = "badge text-bg-danger", "bad"), " recession signal "),
  hr(),
  div(class = "small text-muted",
    "Leading-indicator-first. Data: FRED, OECD, Eurostat, ECB and IMF. ",
    "Not investment advice."),
  div(class = "small text-muted mt-2",
    "Co-written by Claude Code Opus 5", br(), "Directed by Martin Hoshi Vognsen", br(),
    tags$a(href = REPO_URL, target = "_blank", rel = "noopener", paste("Source code", ARROW)))
)

# --- footer: about, attributions, notices ---------------------------------------
published    <- names(DATA)[!vapply(DATA, is.null, logical(1))]
attributions <- sort(unique(stats::na.omit(LIC$attribution[LIC$id %in% published])))
IMF_TERMS    <- "https://www.imf.org/en/about/copyright-and-terms"

# A credit links to its source page when every series sharing it has the same one.
source_item <- function(a) {
  urls <- unique(stats::na.omit(LIC$source_url[LIC$id %in% published & LIC$attribution %in% a]))
  if (length(urls) == 1 && !grepl(";", urls, fixed = TRUE))
    tags$li(tags$a(href = urls, target = "_blank", rel = "noopener", a))
  else tags$li(a)
}

footer <- div(class = "about-data small text-muted mt-5 pt-3 border-top",
  h2(class = "h6 text-body", "About this edition"),
  p(ABOUT),
  h2(class = "h6 text-body mt-3", "Data sources and licences"),
  p("Each tile credits its source. Sources republished on this page:"),
  tags$ul(class = "mb-2", lapply(attributions, source_item)),
  p("Z-scores, percentiles, changes versus the prior observation and series derived from ",
    "several inputs (such as net liquidity and the equity/GDP ratio) are computed by this ",
    "site from the original series. They are adaptations of the original works and are not ",
    "endorsed by the source organisations."),
  p("This is an adaptation of an original work by the OECD. The opinions expressed and ",
    "arguments employed in this adaptation should not be reported as representing the ",
    "official views of the OECD or of its Member countries."),
  p("OECD and Eurostat data are used under CC BY 4.0, and ECB data under the ECB's terms ",
    "of use, with the source credited. IMF data are used under the IMF's ",
    tags$a(href = IMF_TERMS, target = "_blank", rel = "noopener", .noWS = "outside",
           "terms for statistical data"),
    ", which also apply to anyone reusing them from this page. No data provider endorses ",
    "this site. Licensed indicators (S&P 500, ICE BofA credit spreads, S&P Cotality ",
    "Case-Shiller) and headline-only surveys are linked rather than republished."),
  if (USES_API)
    p(sprintf("This product uses the FRED%s API but is not endorsed or certified by the Federal ", REG),
      "Reserve Bank of St. Louis."),
  p(strong("Not investment advice."),
    " For information and education only; no warranty of accuracy, completeness or timeliness."),
  p(sprintf("Co-written by Claude Code Opus 5 %s Directed by Martin Hoshi Vognsen %s ", DOT, DOT),
    tags$a(href = REPO_URL, target = "_blank", rel = "noopener", "Source code (MIT licence)"))
)

# --- page-level CSS and JS ------------------------------------------------------
CSS <- "
.mode-part { display: none; }
body:not([data-mode='z']):not([data-mode='pct']) .mode-part[data-mode='level'],
body[data-mode='z'] .mode-part[data-mode='z'],
body[data-mode='pct'] .mode-part[data-mode='pct'] { display: inline; }
.edition-note { line-height: 1.35; }
.about-data { max-width: 900px; }
.about-data h2 { font-weight: 600; }
"

# Display-mode and zoom controls: toggle which precomputed traces are visible
# (level / z / pct), set the x range, and fit the y range to what's in view.
# Plots rendered inside hidden tabs are resized when their tab is shown.
JS <- "
(function () {
  function plots() { return Array.prototype.slice.call(document.querySelectorAll('.js-plotly-plot')); }
  function checked(name, fallback) {
    var el = document.querySelector('input[name=\"' + name + '\"]:checked');
    return el ? el.value : fallback;
  }
  function yRange(gd, x0, x1) {
    var lo = Infinity, hi = -Infinity;
    gd.data.forEach(function (t) {
      if (t.visible !== true || !t.x || !t.y) return;
      var isRef = /_ref$/.test(t.name || '');
      for (var i = 0; i < t.y.length; i++) {
        var y = t.y[i];
        if (y === null || isNaN(y)) continue;
        if (!isRef && (t.x[i] < x0 || t.x[i] > x1)) continue;
        if (y < lo) lo = y;
        if (y > hi) hi = y;
      }
    });
    if (!isFinite(lo)) return null;
    var pad = (hi - lo) * 0.08 || Math.abs(hi) * 0.05 || 1;
    return [lo - pad, hi + pad];
  }
  function applyTo(gd, mode, x0, x1) {
    if (!gd.data) return false;
    var vis = gd.data.map(function (t) { return t.name === mode || t.name === mode + '_ref'; });
    Plotly.restyle(gd, { visible: vis }).then(function () {
      var upd = { 'xaxis.range': [x0, x1] };
      var yr = yRange(gd, x0, x1);
      if (yr) upd['yaxis.range'] = yr;
      return Plotly.relayout(gd, upd);
    });
    return true;
  }
  var tries = 0;
  function update() {
    var mode = checked('mode', 'level');
    var years = +checked('zoom', '3');
    document.body.setAttribute('data-mode', mode);
    var end = new Date(), start = new Date();
    start.setDate(start.getDate() - Math.round(365.25 * years));
    var x0 = start.toISOString().slice(0, 10), x1 = end.toISOString().slice(0, 10);
    var waiting = 0;
    plots().forEach(function (gd) { if (!applyTo(gd, mode, x0, x1)) waiting++; });
    if (waiting && tries++ < 20) setTimeout(update, 250);
  }
  document.addEventListener('change', function (e) {
    if (e.target && (e.target.name === 'mode' || e.target.name === 'zoom')) { tries = 0; update(); }
  });
  document.addEventListener('shown.bs.tab', function (e) {
    var sel = e.target.getAttribute('data-bs-target') || e.target.getAttribute('href');
    var pane = sel ? document.querySelector(sel) : null;
    if (!pane) return;
    pane.querySelectorAll('.js-plotly-plot').forEach(function (gd) { Plotly.Plots.resize(gd); });
  });
  window.addEventListener('load', function () { setTimeout(update, 50); });
})();
"

# --- assemble and write -----------------------------------------------------------
page <- page_sidebar(
  title = "Global Macro Cockpit",
  window_title = "Global Macro Cockpit",
  theme = bs_theme(version = 5, preset = "flatly"),
  fillable = FALSE,
  sidebar = side,
  tags$head(
    tags$meta(name = "description",
              content = "Global Macro Cockpit: a leading-indicator-first macro dashboard (static public edition)."),
    tags$style(HTML(CSS))
  ),
  do.call(navset_tab, lapply(VIEWS, view_panel)),
  footer,
  ESC_DISMISS_JS,
  tags$script(HTML(JS))
)

unlink(OUT_DIR, recursive = TRUE)
dir.create(OUT_DIR, showWarnings = FALSE)
htmltools::save_html(page, file.path(OUT_DIR, "index.html"), libdir = "lib", lang = "en")
invisible(file.create(file.path(OUT_DIR, ".nojekyll")))

message(sprintf("Wrote %s/index.html (%s KB): %d data tiles, %d licensed, %d manual.",
                OUT_DIR, round(file.size(file.path(OUT_DIR, "index.html")) / 1024),
                n_ok, sum(KIND == "licensed"), sum(KIND == "manual")))
