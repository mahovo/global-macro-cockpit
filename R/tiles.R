# tiles.R — card building blocks shared by the local Shiny app (app.R) and the
# static public build (scripts/build_site.R).

TONE_COLOUR <- c(good = "#2e7d32", warn = "#ed6c02", bad = "#c62828", neutral = "#607d8b")
TONE_CLASS  <- c(good = "text-bg-success", warn = "text-bg-warning",
                 bad = "text-bg-danger", neutral = "text-bg-secondary")

# Info icon (ⓘ) with a popover. trigger = "focus" opens it on click and dismisses
# it on outside-click (closing any other open one); the icon needs tabindex to be
# focusable. Esc, and clicks on links inside a popover, are handled by POPOVER_JS.
help_popover <- function(title, body, placement = "left") {
  bslib::popover(
    htmltools::span(class = "ms-1", tabindex = "0", role = "button",
                    `aria-label` = paste("Help:", title),
                    style = "cursor:pointer; color:#6c757d;", htmltools::HTML("&#9432;")),
    body, title = title, placement = placement,
    options = list(trigger = "focus")
  )
}

# Link into the user guide, opened in a new tab so the dashboard keeps its state.
# `anchor` is a tile id or "tab-<view id>". GUIDE_URL is the public guide; the static
# build links to the copy beside its page instead (scripts/build_site.R).
GUIDE_URL <- "https://mahovo.github.io/global-macro-cockpit/guide/"
guide_link <- function(anchor = NULL, text = "More in the guide ›") {
  htmltools::tags$a(href = paste0(GUIDE_URL, if (!is.null(anchor)) paste0("#", anchor)),
                    target = "_blank", rel = "noopener", text)
}

info_popover <- function(entry) help_popover(display_title(entry),
  htmltools::tagList(card_help(entry), htmltools::div(class = "mt-1", guide_link(entry$id))))

# Pressing Esc blurs the focused element, which dismisses a focus-trigger popover. A
# mousedown on a link inside a popover would move the focus too, and the popover would
# close before the click landed, so the focus stays where it is.
POPOVER_JS <- htmltools::tags$script(htmltools::HTML(paste(
  "document.addEventListener('keydown', function(e){ if (e.key === 'Escape' && document.activeElement) document.activeElement.blur(); });",
  "document.addEventListener('mousedown', function(e){ if (e.target.closest && e.target.closest('.popover a')) e.preventDefault(); });",
  sep = "\n")))

# --- tile contents, shared by the app's renderers and the static build --------

# Headline value in the chosen display mode ("—" when there is no data).
value_label <- function(df, mode, unit) {
  d <- apply_mode(df, mode)
  if (is.null(d) || !nrow(d)) return("—")
  format_value_mode(dplyr::last(d$value), mode, unit)
}

# Arrow + change vs the prior observation, in the chosen display mode.
change_tag <- function(df, mode, unit = NULL) {
  d <- apply_mode(df, mode)
  if (is.null(d) || nrow(d) < 2) return(NULL)
  ch <- dplyr::last(d$value) - d$value[nrow(d) - 1]
  arrow  <- if (ch > 0) "&#9650;" else if (ch < 0) "&#9660;" else "&#9644;"
  colour <- if (ch > 0) TONE_COLOUR[["good"]] else if (ch < 0) TONE_COLOUR[["bad"]] else TONE_COLOUR[["neutral"]]
  lab <- switch(mode,
    z   = sprintf("%+.2fσ", ch),
    pct = sprintf("%+d pct", as.integer(round(ch))),
    format_change(ch, unit))
  htmltools::tags$span(htmltools::HTML(arrow), style = sprintf("color:%s", colour),
    htmltools::tags$span(style = "color:#6c757d", sprintf(" %s vs prior", lab)))
}

# Staleness dot + "as of" date of the latest observation.
asof_tag <- function(df, frequency) {
  if (is.null(df) || !nrow(df)) return(NULL)
  last <- max(df$date)
  dot_colour <- if (is_stale(last, frequency)) TONE_COLOUR[["warn"]] else TONE_COLOUR[["good"]]
  htmltools::tagList(htmltools::span(style = sprintf("color:%s", dot_colour), "● "),
                     paste("as of", format(last)))
}

# Cycle-read badge; always assesses the level series.
badge_tag <- function(assessor, df) {
  if (is.null(assessor)) return(NULL)
  a <- assessor(df)
  htmltools::span(class = paste("badge", TONE_CLASS[[a$tone]]), a$text)
}

# Card chrome: title, badge and ⓘ in the header; body content; footer line.
tile_shell <- function(entry, ..., badge = entry$indicator_class %||% "",
                       badge_class = "text-bg-light", footer = source_label(entry)) {
  bslib::card(
    fillable = FALSE,   # natural height; layout_column_wrap(heights_equal = "row") aligns rows
    bslib::card_header(
      htmltools::strong(display_title(entry)),
      htmltools::span(class = "float-end",
        htmltools::span(class = paste("badge", badge_class), badge),
        info_popover(entry))),
    ...,
    bslib::card_footer(class = "small text-muted", footer)
  )
}

# Licensed / headline-only tile: no data, a short note and links. `links` (a list of
# label + url) wins over a single `url`, which falls back to the provider's site.
manual_tile <- function(entry, providers = NULL, footer = source_label(entry)) {
  prov  <- providers[[entry$provider %||% ""]]
  links <- entry$links %||% {
    url <- entry$url %||% prov$base_url
    if (is.null(url)) list() else list(list(label = "Latest release ›", url = url))
  }
  tile_shell(entry, badge = "manual", badge_class = "text-bg-secondary", footer = footer,
    htmltools::div(class = "text-muted small mb-2", "Licensed / headline-only — not auto-fetched."),
    if (!is.null(entry$notes)) htmltools::div(class = "small mb-2", entry$notes),
    if (length(links))
      htmltools::div(class = "small d-flex flex-column gap-1",
        lapply(links, function(l)
          htmltools::tags$a(href = l$url, target = "_blank", rel = "noopener", l$label)))
  )
}

# Mini-chart for the Shiny app: one series, already in the chosen display mode.
# Event series (policy rates) are drawn as steps and extended flat to `today`.
spark_plot <- function(df, frequency, tone = "neutral", ref = NA_real_, today = Sys.Date()) {
  step <- identical(frequency, "event")
  if (step && max(df$date) < today) {
    ext <- df[nrow(df), ]; ext$date <- today
    df <- dplyr::bind_rows(df, ext)
  }
  line <- if (step) ggplot2::geom_step(direction = "hv", linewidth = 0.6, colour = TONE_COLOUR[[tone]])
          else      ggplot2::geom_line(linewidth = 0.6, colour = TONE_COLOUR[[tone]])
  p <- ggplot2::ggplot(df, ggplot2::aes(date, value)) + line +
    ggplot2::labs(x = NULL, y = NULL) + ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(plot.margin = ggplot2::margin(2, 2, 2, 2))
  if (!is.na(ref)) p <- p + ggplot2::geom_hline(yintercept = ref, linetype = "dashed",
                                                colour = "grey50", linewidth = 0.4)
  plotly::ggplotly(p, tooltip = c("x", "y"), height = 150) |>
    plotly::config(displayModeBar = FALSE, responsive = TRUE) |>
    plotly::layout(margin = list(l = 40, r = 5, t = 5, b = 20))
}

# Mini-chart for the static build: one trace per display mode (level / z / pct)
# plus its reference line, all precomputed in R with apply_mode(); only the level
# traces start visible. Page JavaScript switches modes by toggling trace names.
spark_plot_modes <- function(df, frequency, tone = "neutral", ref = NA_real_, today = Sys.Date()) {
  step <- identical(frequency, "event")
  p <- plotly::plot_ly(height = 150)
  for (m in c("level", "z", "pct")) {
    d <- apply_mode(df, m)                              # computed on the full series
    if (step && max(d$date) < today) {
      ext <- d[nrow(d), ]; ext$date <- today
      d <- dplyr::bind_rows(d, ext)
    }
    # A 150 px sparkline can't show daily detail over years: for long series keep the
    # last point of each ISO week, and round values (.page_digits), to keep the page light.
    if (nrow(d) > 600) d <- d[!duplicated(format(d$date, "%G-%V"), fromLast = TRUE), ]
    dg <- .page_digits(d$value, d$date, today)
    d$value <- round(d$value, dg)
    p <- plotly::add_trace(p, x = d$date, y = d$value, type = "scatter", mode = "lines",
      name = m, visible = identical(m, "level"),
      line = list(color = unname(TONE_COLOUR[[tone]]), width = 1.6,
                  shape = if (step) "hv" else "linear"),
      hovertemplate = .page_hover(dg))
    rl <- mode_ref(m, ref)
    if (!is.na(rl)) {
      p <- plotly::add_trace(p, x = range(d$date), y = c(rl, rl), type = "scatter",
        mode = "lines", name = paste0(m, "_ref"), visible = identical(m, "level"),
        hoverinfo = "skip", line = list(color = "#9e9e9e", width = 1, dash = "dash"))
    }
  }
  .static_sparkline(p)
}

# Shared look of the mini-charts.
.sparkline_layout <- function(p) {
  p |>
    plotly::layout(showlegend = FALSE, margin = list(l = 40, r = 5, t = 5, b = 20),
                   xaxis = list(title = "", showgrid = FALSE),
                   yaxis = list(title = "", zeroline = FALSE)) |>
    plotly::config(displayModeBar = FALSE, responsive = TRUE)
}

.static_sparkline <- function(p) .static_plot(.sparkline_layout(p))

# Static build: decimals for a series' plotted values and tooltips, so the page stays
# light without visible steps. The step is a power of ten no larger than 1/250 of the
# range over the last year, the tightest zoom, so it stays under half a pixel at every
# zoom; a flat series keeps 6 significant digits. (A fixed 4 significant digits left the
# CLIs, near 100 with small moves, one decimal: they drew as staircases.)
.page_digits <- function(x, date, today = Sys.Date()) {
  span <- function(v) if (length(v) > 1) diff(range(v)) else 0
  ok <- is.finite(x)
  r  <- span(x[ok & date >= today - 365])
  if (r == 0) r <- span(x[ok])
  if (r > 0) return(max(0, -floor(log10(r / 250))))
  m <- if (any(ok)) max(abs(x[ok])) else 0
  if (m == 0) 0 else max(0, 5 - floor(log10(m)))
}

# Tooltip of a static mini-chart: the date, then the value at its plotted precision with
# thousands separators and no trailing zeros (100.2968, 159,044, 4.12).
.page_hover <- function(digits)
  sprintf("%%{x|%%Y-%%m-%%d}<br>%%{y:,.%d~f}<extra></extra>", digits)

# Static build: serialise only the built traces. By default plotly also embeds the raw
# inputs (attrs) and rebuilds on render, roughly doubling the page size.
.static_plot <- function(p) {
  p <- plotly::plotly_build(p)
  p$x[c("attrs", "visdat", "cur_data")] <- NULL
  p$preRenderHook <- NULL
  # plotly also repeats a trace's tooltip template for every point (half the page);
  # one copy per trace does the same job.
  for (i in seq_along(p$x$data)) {
    h <- p$x$data[[i]]$hovertemplate
    if (length(h) > 1 && all(h == h[1])) p$x$data[[i]]$hovertemplate <- h[1]
  }
  attr(p$x, "TOJSON_FUNC") <- .page_json
  p
}

# plotly's JSON writer with numbers at up to 15 significant digits instead of full binary
# precision (100.4, not 100.40000000000001): shorter, and the values read back the same.
.page_json <- function(x, ...)
  jsonlite::toJSON(x, digits = NA, auto_unbox = TRUE, force = TRUE, null = "null",
                   na = "null", time_format = "%Y-%m-%d %H:%M:%OS6", ...)

# Legend glyphs drawn beside text: a short line and a dot.
.key_line <- function(colour) htmltools::span(style = sprintf(
  "display:inline-block;width:14px;vertical-align:middle;margin-right:4px;border-top:2px solid %s;",
  colour))
.key_dot <- function(colour) htmltools::span(style = sprintf(
  "display:inline-block;width:8px;height:8px;border-radius:50%%;vertical-align:middle;margin-right:4px;background:%s;",
  colour))

# --- two-line tiles (stocks vs bonds) -------------------------------------------
# The data of a pair tile carries its two components (`equity`, `bond`) next to
# `value`, the gap between them. In level mode the chart shows both lines and shades
# any stretch where stocks yield less than bonds; z / pct modes show the gap.

PAIR_COLOUR <- c(equity = "#2a78d6", bond = "#eb6834", crossed = "rgba(227,73,72,0.25)")

# Key for the lines on show, with latest values: both components in level mode
# ("Stocks 3.37% (Q2 2026)  Bonds 2.92%"), the gap in z-score / percentile modes.
pair_detail <- function(df, mode = "level", tone = "neutral") {
  if (is.null(df) || !nrow(df)) return(NULL)
  last <- df[nrow(df), ]
  key  <- .key_line
  if (!identical(mode, "level")) {
    return(htmltools::span(class = "d-block text-muted", key(unname(TONE_COLOUR[[tone]])),
                           sprintf("Gap: stocks %.2f%% − bonds %.2f%%", last$equity, last$bond)))
  }
  quarter <- sprintf("Q%d %s", (as.integer(format(last$equity_asof, "%m")) - 1) %/% 3 + 1,
                     format(last$equity_asof, "%Y"))
  # Each entry names its cadence: the stocks line steps once a quarter, bonds move daily.
  htmltools::span(class = "d-block text-muted",     # sits inside the tile's change line
    htmltools::span(class = "text-nowrap me-2", key(PAIR_COLOUR[["equity"]]),
                    sprintf("Stocks %.2f%% (%s, quarterly)", last$equity, quarter)),
    htmltools::span(class = "text-nowrap", key(PAIR_COLOUR[["bond"]]),
                    sprintf("Bonds %.2f%% (daily)", last$bond)))
}

.add_pair_traces <- function(p, d, visible = TRUE) {
  p |>
    plotly::add_trace(x = d$date, y = d$bond, type = "scatter", mode = "lines", name = "level",
      visible = visible, line = list(color = PAIR_COLOUR[["bond"]], width = 1.6),
      hovertemplate = "%{x|%Y-%m-%d}<br>Bonds %{y:.2f}%<extra></extra>") |>
    plotly::add_trace(x = d$date, y = pmin(d$equity, d$bond), type = "scatter", mode = "lines",
      name = "level", visible = visible, fill = "tonexty", fillcolor = PAIR_COLOUR[["crossed"]],
      line = list(width = 0), hoverinfo = "skip") |>
    plotly::add_trace(x = d$date, y = d$equity, type = "scatter", mode = "lines", name = "level",
      visible = visible, line = list(color = PAIR_COLOUR[["equity"]], width = 1.6),
      hovertemplate = "%{x|%Y-%m-%d}<br>Stocks %{y:.2f}%<extra></extra>")
}

# Mini-chart of a pair tile for the Shiny app, in the chosen display mode.
spark_plot_pair <- function(df, mode, tone = "neutral") {
  if (!identical(mode, "level")) {
    return(spark_plot(apply_mode(df, mode), "daily", tone, mode_ref(mode, NA_real_)))
  }
  .sparkline_layout(.add_pair_traces(plotly::plot_ly(height = 150), df))
}

# Mini-chart of a pair tile for the static build: both lines for level mode, the gap's
# z-score and percentile for the other modes (toggled by the page JavaScript).
spark_plot_pair_modes <- function(df, tone = "neutral") {
  thin <- function(d) {      # last point of each ISO week
    if (nrow(d) > 600) d[!duplicated(format(d$date, "%G-%V"), fromLast = TRUE), ] else d
  }
  lv <- thin(df)
  for (col in c("equity", "bond")) lv[[col]] <- round(lv[[col]], .page_digits(lv[[col]], lv$date))
  p <- .add_pair_traces(plotly::plot_ly(height = 150), lv)
  for (m in c("z", "pct")) {
    g  <- thin(apply_mode(df, m))
    dg <- .page_digits(g$value, g$date)
    g$value <- round(g$value, dg)
    rl <- mode_ref(m, NA_real_)
    p <- p |>
      plotly::add_trace(x = g$date, y = g$value, type = "scatter", mode = "lines", name = m,
        visible = FALSE, line = list(color = unname(TONE_COLOUR[[tone]]), width = 1.6),
        hovertemplate = .page_hover(dg)) |>
      plotly::add_trace(x = range(g$date), y = c(rl, rl), type = "scatter", mode = "lines",
        name = paste0(m, "_ref"), visible = FALSE, hoverinfo = "skip",
        line = list(color = "#9e9e9e", width = 1, dash = "dash"))
  }
  .static_sparkline(p)
}

# --- growth/inflation regime tile -----------------------------------------------
# The data carry `growth` (3-month change in the US CLI), `inflation` (CPI inflation
# minus its 12-month average), `cli`, `cpi_yoy`, `cpi_avg12`, `since` and `before`
# next to `value`, the regime code (REGIMES in R/assess.R). The strip shows the regime of
# every month, and the quadrant traces the months in the strip's visible range, which the
# handles under the strip (and the static page's zoom) set; REGIME_JS redraws the
# quadrant when it changes. The tile looks the same in every display mode: z-scores
# would move the zero lines that separate the regimes.

# One colour per regime code. Any two regimes can sit side by side on the strip, so the
# four were validated as a set against every pairing for colour-blind separation.
REGIME_COLOUR <- c("#008300", "#eda100", "#e87ba4", "#2a78d6")
REGIME_INK    <- "#52514e"     # the path, the latest month and their key
.AXIS_FONT    <- list(size = 10, color = "#6c757d")

.rgba <- function(hex, alpha) {
  v <- grDevices::col2rgb(hex)
  sprintf("rgba(%d,%d,%d,%.2f)", v[1], v[2], v[3], alpha)
}
.month_label <- function(d) format(d, "%b %Y")
.next_month  <- function(d) as.Date(format(d + 32, "%Y-%m-01"))   # d is a month start

# "Growth ↑ Inflation ↓" for the latest month.
regime_headline <- function(df) {
  r <- REGIMES[df$value[nrow(df)], ]
  arrow <- function(up) if (up) "↑" else "↓"
  sprintf("Growth %s Inflation %s", arrow(r$growth), arrow(r$inflation))
}

# When the current regime began, the regime before it, and the two readings behind it.
# `price` names the inflation measure (CPI, or HICP for the euro area).
regime_detail <- function(df, price = "CPI") {
  last <- df[nrow(df), ]
  htmltools::tagList(
    htmltools::div(paste0("Since ", .month_label(last$since),
                          if (!is.na(last$before)) paste0(", after ", REGIMES$name[last$before]))),
    htmltools::div(class = "text-muted",
      sprintf("Growth: CLI %.2f, %+.2f over 3 months", last$cli, last$growth)),
    htmltools::div(class = "text-muted",
      sprintf("Inflation: %s %.2f%%, 12-month average %.2f%%", price, last$cpi_yoy, last$cpi_avg12)))
}

# The months a period from `from` to today shows: those whose middle falls inside it,
# the rule REGIME_JS applies to the strip's range. Without `from`, every month.
.regime_window <- function(df, from = NULL) {
  if (is.null(from)) return(df)
  w <- df[df$date + 15 >= as.Date(from), ]
  if (nrow(w) >= 2) w else utils::tail(df, 12)
}

# Quadrant: growth momentum across, inflation momentum up, each regime's quadrant tinted
# and named, with a swatch of its colour, above the plot in two rows (upper quadrants
# first), on its quadrant's side; the names are the legend for the strip too. The path
# covers the period: its last 12 months dark, earlier months light, the final month a
# larger dot. The axes stay symmetric, so tints and zero lines sit in paper coordinates
# and a new period only changes the traces and axis ranges.
REGIME_FADED <- "#c3c2b7"

regime_quadrant <- function(df, from = NULL, price = "CPI") {
  d  <- .regime_window(df, from)
  n  <- nrow(d)
  k0 <- max(1, n - 11)                     # first month of the dark stretch
  xr <- 1.3 * max(0.3, abs(d$growth))      # symmetric ranges keep the origin centred
  yr <- 1.3 * max(0.3, abs(d$inflation))
  sx <- ifelse(REGIMES$growth, 1, -1)
  sy <- ifelse(REGIMES$inflation, 1, -1)
  tints <- lapply(REGIMES$code, function(k) list(type = "rect", layer = "below",
    xref = "paper", yref = "paper", x0 = 0.5, x1 = 0.5 + sx[k] / 2, y0 = 0.5,
    y1 = 0.5 + sy[k] / 2, line = list(width = 0), fillcolor = .rgba(REGIME_COLOUR[k], 0.12)))
  zero <- list(color = "#b5b4ad", width = 1)
  lines <- list(
    list(type = "line", layer = "below", xref = "paper", yref = "paper",
         x0 = 0.5, x1 = 0.5, y0 = 0, y1 = 1, line = zero),
    list(type = "line", layer = "below", xref = "paper", yref = "paper",
         x0 = 0, x1 = 1, y0 = 0.5, y1 = 0.5, line = zero))
  labels <- lapply(REGIMES$code, function(k) list(
    x = if (sx[k] > 0) 1 else 0, y = 1, xref = "paper", yref = "paper",
    showarrow = FALSE, font = .AXIS_FONT,
    text = sprintf('<span style="color:%s;font-size:12px">■</span> %s', REGIME_COLOUR[k],
                   REGIMES$name[k]),
    xanchor = if (sx[k] > 0) "right" else "left", yanchor = "bottom",
    yshift = if (sy[k] > 0) 17 else 2))      # upper quadrants' names on the top row
  hover <- sprintf("%s: %s<br>Growth %+.2f, inflation %+.2f pp", .month_label(d$date),
                   REGIMES$name[d$value], d$growth, d$inflation)
  # Three traces always exist, named for REGIME_JS; with 12 months or fewer the "earlier"
  # trace is the path's first point, hidden under it.
  plotly::plot_ly(height = 204) |>
    plotly::add_trace(x = d$growth[1:k0], y = d$inflation[1:k0], type = "scatter",
      mode = "lines+markers", name = "earlier", line = list(color = REGIME_FADED, width = 1.5),
      marker = list(size = 4, color = REGIME_FADED), hovertext = hover[1:k0], hoverinfo = "text") |>
    plotly::add_trace(x = d$growth[k0:n], y = d$inflation[k0:n], type = "scatter",
      mode = "lines+markers", name = "path", line = list(color = REGIME_INK, width = 2),
      marker = list(size = 6, color = REGIME_INK), hovertext = hover[k0:n], hoverinfo = "text") |>
    plotly::add_trace(x = d$growth[n], y = d$inflation[n], type = "scatter", mode = "markers",
      name = "latest", marker = list(size = 11, color = REGIME_INK, line = list(color = "#ffffff", width = 2)),
      hovertext = hover[n], hoverinfo = "text") |>
    plotly::layout(meta = "regime-quadrant", showlegend = FALSE,
      margin = list(l = 48, r = 5, t = 36, b = 32), shapes = c(tints, lines), annotations = labels,
      xaxis = list(range = c(-xr, xr), zeroline = FALSE, showgrid = FALSE, nticks = 5,
                   tickfont = .AXIS_FONT, title = list(text = "CLI change over 3 months",
                   font = .AXIS_FONT, standoff = 4)),
      yaxis = list(range = c(-yr, yr), zeroline = FALSE, showgrid = FALSE, nticks = 5,
                   tickfont = .AXIS_FONT, title = list(text = paste(price, "vs 12-mo avg, pp"),
                   font = .AXIS_FONT, standoff = 4))) |>
    plotly::config(displayModeBar = FALSE, responsive = TRUE)
}

# Strip: one bar per spell of a regime on a date axis, with a range slider under it over
# the whole history: its handles choose the period the quadrant traces. `from` sets the
# initial range (the static page's default zoom); without it the strip shows everything.
# Hover gives each spell's full span.
regime_strip <- function(df, from = NULL, to = Sys.Date()) {
  run   <- cumsum(c(TRUE, diff(df$value) != 0))
  first <- !duplicated(run)
  last  <- !duplicated(run, fromLast = TRUE)
  start <- df$date[first]                 # each spell's first month and the month after it
  stop  <- .next_month(df$date[last])
  code  <- df$value[first]
  began <- df$since[first]                # a spell can start before the data's window
  n_mo  <- (as.integer(format(df$date[last], "%Y")) - as.integer(format(began, "%Y"))) * 12 +
           as.integer(format(df$date[last], "%m")) - as.integer(format(began, "%m")) + 1
  hover <- sprintf("%s<br>%s – %s (%d month%s)", REGIMES$name[code], .month_label(began),
                   .month_label(df$date[last]), n_mo, ifelse(n_mo == 1, "", "s"))
  # The bars touch without separators: over decades, in the slider's overview, gaps between
  # spells would outweigh the colours.
  # The slider is as tall as the strip (thickness 1) and sits in the bottom margin, below
  # the tick labels: 24 px strip + 54 px margin. Left to itself, plotly would push the
  # margin and keep the strip at least 64 px tall.
  xaxis <- list(type = "date", showgrid = FALSE, tickfont = .AXIS_FONT, title = "",
                rangeslider = list(visible = TRUE, thickness = 1, bgcolor = "#ffffff",
                                   bordercolor = "#c3c2b7", borderwidth = 1))
  if (!is.null(from)) xaxis$range <- c(format(as.Date(from)), format(to))
  plotly::plot_ly(height = 80) |>
    plotly::add_trace(type = "bar", orientation = "h", y = rep(0, length(start)),
      x = as.numeric(stop - start) * 86400000, base = format(start), name = "regime",
      marker = list(color = REGIME_COLOUR[code], line = list(width = 0)),
      hovertext = hover, hoverinfo = "text") |>
    plotly::layout(meta = "regime-strip", showlegend = FALSE, bargap = 0,
      margin = list(l = 48, r = 5, t = 2, b = 54), xaxis = xaxis,
      yaxis = list(visible = FALSE, range = c(-0.5, 0.5), fixedrange = TRUE)) |>
    plotly::config(displayModeBar = FALSE, responsive = TRUE)
}

# Key for the quadrant's path, and the period it covers. REGIME_JS keeps the month labels
# and the "Earlier" entry (shown only when the period has more than 12 months) in step.
regime_key <- function(df, from = NULL) {
  d    <- .regime_window(df, from)
  last <- .month_label(d$date[nrow(d)])
  htmltools::div(class = "small text-muted mt-1",
    htmltools::div(
      .key_line(REGIME_INK), "Last 12 months", htmltools::span(class = "ms-2"),
      htmltools::span(class = "regime-earlier-key", style = if (nrow(d) <= 12) "display:none",
        .key_line(REGIME_FADED), "Earlier", htmltools::span(class = "ms-2")),
      .key_dot(REGIME_INK), htmltools::span(class = "regime-end", last)),
    htmltools::div(
      htmltools::span(class = "regime-period", paste(.month_label(d$date[1]), "–", last)),
      htmltools::span(class = "text-nowrap", "(drag the handles to change it)")))
}

# The tile's monthly history for REGIME_JS: dates, the two readings and the regime codes.
.regime_json <- function(df) {
  as.character(jsonlite::toJSON(list(date = format(df$date), g = round(df$growth, 4),
    i = round(df$inflation, 4), r = as.integer(df$value), names = REGIMES$name), digits = NA))
}

# The whole tile body for a registry entry, shared by the app (renderUI) and the static
# build (static = TRUE strips plotly's raw inputs from the page). `from` is the start of
# the initial period; the entry's `price_index` names the inflation measure.
regime_body <- function(df, entry, static = FALSE, from = NULL) {
  fin   <- if (static) .static_plot else identity
  price <- entry$price_index %||% "CPI"
  htmltools::tagList(
    # One line of words, a step smaller than the other tiles' figures; on a narrow card
    # the date moves below the headline rather than splitting it.
    htmltools::div(class = "d-flex flex-wrap justify-content-between align-items-baseline",
      htmltools::div(class = "fs-5 fw-semibold text-nowrap me-2", regime_headline(df)),
      htmltools::div(class = "small text-muted text-nowrap", asof_tag(df, entry$frequency))),
    htmltools::div(class = "small mb-1", regime_detail(df, price)),
    badge_tag(assess_regime, df),
    htmltools::div(class = "regime-tile",
      htmltools::tags$script(type = "application/json", class = "regime-data",
                             htmltools::HTML(.regime_json(df))),
      fin(regime_quadrant(df, from, price)),
      fin(regime_strip(df, from)),
      regime_key(df, from)))
}

# Page script for the regime tile, in both editions. When the strip's visible range
# changes (its handles, the static page's zoom, a drag across the strip), it redraws the
# quadrant for the months whose middle falls in that range: the three path traces, the
# axis ranges and the key's labels. It looks for new tiles every 0.7 s, because the app
# renders the tile after the page loads (and again on refresh).
REGIME_JS <- htmltools::tags$script(htmltools::HTML("
(function () {
  var MON = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  function ms(v) {
    if (typeof v === 'number') return v;
    var s = String(v);
    return Date.UTC(+s.slice(0, 4), +s.slice(5, 7) - 1, +s.slice(8, 10) || 1,
                    +s.slice(11, 13) || 0, +s.slice(14, 16) || 0);
  }
  function label(d) { return MON[+d.slice(5, 7) - 1] + ' ' + d.slice(0, 4); }
  function signed(v) { return (v >= 0 ? '+' : '') + v.toFixed(2); }
  function plotIn(box, meta) {
    var gds = box.querySelectorAll('.js-plotly-plot');
    for (var i = 0; i < gds.length; i++) if (gds[i].layout && gds[i].layout.meta === meta) return gds[i];
    return null;
  }
  function draw(box) {
    var D = box._regime, q = box._quad, r = box._strip.layout.xaxis.range;
    if (!r) return;
    var x0 = ms(r[0]), x1 = ms(r[1]), idx = [];
    for (var i = 0; i < D.date.length; i++) {
      var t = ms(D.date[i]) + 15 * 864e5;
      if (t >= x0 && t <= x1) idx.push(i);
    }
    if (idx.length < 2) return;
    var n = idx.length, k = Math.max(0, n - 12), gx = 0.3, gy = 0.3, at = {};
    idx.forEach(function (m) { gx = Math.max(gx, Math.abs(D.g[m])); gy = Math.max(gy, Math.abs(D.i[m])); });
    function part(a, b) {
      var o = {x: [], y: [], h: []};
      for (var j = a; j <= b; j++) {
        var m = idx[j];
        o.x.push(D.g[m]); o.y.push(D.i[m]);
        o.h.push(label(D.date[m]) + ': ' + D.names[D.r[m] - 1] + '<br>Growth ' + signed(D.g[m]) +
                 ', inflation ' + signed(D.i[m]) + ' pp');
      }
      return o;
    }
    var e = part(0, k), p = part(k, n - 1), z = part(n - 1, n - 1);
    q.data.forEach(function (tr, j) { at[tr.name] = j; });
    Plotly.restyle(q, {x: [e.x, p.x, z.x], y: [e.y, p.y, z.y], hovertext: [e.h, p.h, z.h]},
                   [at.earlier, at.path, at.latest]);
    Plotly.relayout(q, {'xaxis.range': [-1.3 * gx, 1.3 * gx], 'yaxis.range': [-1.3 * gy, 1.3 * gy]});
    var first = label(D.date[idx[0]]), last = label(D.date[idx[n - 1]]);
    box.querySelector('.regime-end').textContent = last;
    box.querySelector('.regime-period').textContent = first + ' – ' + last;
    box.querySelector('.regime-earlier-key').style.display = n > 12 ? '' : 'none';
  }
  function init() {
    var boxes = document.querySelectorAll('.regime-tile:not(.regime-ready)');
    Array.prototype.forEach.call(boxes, function (box) {
      var q = plotIn(box, 'regime-quadrant'), s = plotIn(box, 'regime-strip');
      if (!q || !s || !s.on || !s._fullLayout) return;
      box._regime = JSON.parse(box.querySelector('script.regime-data').textContent);
      box._quad = q; box._strip = s;
      box.classList.add('regime-ready');
      s.on('plotly_relayout', function () { draw(box); });
      draw(box);
    });
  }
  setInterval(init, 700);
})();
"))
