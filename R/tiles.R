# tiles.R — card building blocks shared by the local Shiny app (app.R) and the
# static public build (scripts/build_site.R).

TONE_COLOUR <- c(good = "#2e7d32", warn = "#ed6c02", bad = "#c62828", neutral = "#607d8b")
TONE_CLASS  <- c(good = "text-bg-success", warn = "text-bg-warning",
                 bad = "text-bg-danger", neutral = "text-bg-secondary")
CARD_HEIGHT <- 360

# Info icon (ⓘ) with a popover. trigger = "focus" opens it on click and dismisses
# it on outside-click (closing any other open one); the icon needs tabindex to be
# focusable. Esc is handled by ESC_DISMISS_JS.
help_popover <- function(title, body, placement = "left") {
  bslib::popover(
    htmltools::span(class = "ms-1", tabindex = "0", role = "button",
                    `aria-label` = paste("Help:", title),
                    style = "cursor:pointer; color:#6c757d;", htmltools::HTML("&#9432;")),
    body, title = title, placement = placement,
    options = list(trigger = "focus")
  )
}

info_popover <- function(entry) help_popover(display_title(entry), card_help(entry))

# Pressing Esc blurs the focused element, which dismisses a focus-trigger popover.
ESC_DISMISS_JS <- htmltools::tags$script(htmltools::HTML(
  "document.addEventListener('keydown', function(e){ if (e.key === 'Escape' && document.activeElement) document.activeElement.blur(); });"
))

# --- tile contents, shared by the app's renderers and the static build --------

# Headline value in the chosen display mode ("—" when there is no data).
value_label <- function(df, mode, unit) {
  d <- apply_mode(df, mode)
  if (is.null(d) || !nrow(d)) return("—")
  format_value_mode(dplyr::last(d$value), mode, unit)
}

# Arrow + change vs the prior observation, in the chosen display mode.
change_tag <- function(df, mode) {
  d <- apply_mode(df, mode)
  if (is.null(d) || nrow(d) < 2) return(NULL)
  ch <- dplyr::last(d$value) - d$value[nrow(d) - 1]
  arrow  <- if (ch > 0) "&#9650;" else if (ch < 0) "&#9660;" else "&#9644;"
  colour <- if (ch > 0) TONE_COLOUR[["good"]] else if (ch < 0) TONE_COLOUR[["bad"]] else TONE_COLOUR[["neutral"]]
  lab <- switch(mode,
    z   = sprintf("%+.2fσ", ch),
    pct = sprintf("%+d pct", as.integer(round(ch))),
    format_change(ch))
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
    height = CARD_HEIGHT, fillable = FALSE,
    bslib::card_header(
      htmltools::strong(display_title(entry)),
      htmltools::span(class = "float-end",
        htmltools::span(class = paste("badge", badge_class), badge),
        info_popover(entry))),
    ...,
    bslib::card_footer(class = "small text-muted", footer)
  )
}

# Licensed / headline-only tile: no data, a short note and an optional link.
manual_tile <- function(entry, providers = NULL, footer = source_label(entry)) {
  prov <- providers[[entry$provider %||% ""]]
  link <- entry$url %||% prov$base_url
  tile_shell(entry, badge = "manual", badge_class = "text-bg-secondary", footer = footer,
    htmltools::div(class = "text-muted small mb-2", "Licensed / headline-only — not auto-fetched."),
    if (!is.null(entry$notes)) htmltools::div(class = "small mb-2", entry$notes),
    if (!is.null(link))
      htmltools::div(class = "small",
        htmltools::tags$a(href = link, target = "_blank", rel = "noopener", "Latest release ›"))
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
    # last point of each ISO week, and 4 significant digits, to keep the page light.
    if (nrow(d) > 600) d <- d[!duplicated(format(d$date, "%G-%V"), fromLast = TRUE), ]
    d$value <- signif(d$value, 4)
    p <- plotly::add_trace(p, x = d$date, y = d$value, type = "scatter", mode = "lines",
      name = m, visible = identical(m, "level"),
      line = list(color = unname(TONE_COLOUR[[tone]]), width = 1.6,
                  shape = if (step) "hv" else "linear"),
      hovertemplate = "%{x|%Y-%m-%d}<br>%{y:.4~g}<extra></extra>")
    rl <- mode_ref(m, ref)
    if (!is.na(rl)) {
      p <- plotly::add_trace(p, x = range(d$date), y = c(rl, rl), type = "scatter",
        mode = "lines", name = paste0(m, "_ref"), visible = identical(m, "level"),
        hoverinfo = "skip", line = list(color = "#9e9e9e", width = 1, dash = "dash"))
    }
  }
  p <- p |>
    plotly::layout(showlegend = FALSE, margin = list(l = 40, r = 5, t = 5, b = 20),
                   xaxis = list(title = "", showgrid = FALSE),
                   yaxis = list(title = "", zeroline = FALSE)) |>
    plotly::config(displayModeBar = FALSE, responsive = TRUE)

  # Serialise only the built traces: by default plotly also embeds the raw inputs
  # (attrs) and rebuilds on render, roughly doubling the page size.
  p <- plotly::plotly_build(p)
  p$x[c("attrs", "visdat", "cur_data")] <- NULL
  p$preRenderHook <- NULL
  p
}
