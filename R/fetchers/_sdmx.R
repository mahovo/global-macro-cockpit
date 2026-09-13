# _sdmx.R — helpers shared by the official statistics fetchers (ecb.R, eurostat.R, imf.R).

# Parse period strings to the period's start date:
#   "2026-09-16" daily | "2026-08" or "2026-M08" monthly | "2026-Q3" quarterly | "2026" annual.
# Anything else becomes NA.
sdmx_period_start <- function(x) {
  x   <- sub("^([0-9]{4})-M([0-9]{2})$", "\\1-\\2", as.character(x))
  out <- rep(as.Date(NA), length(x))
  day <- grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", x)
  mon <- grepl("^[0-9]{4}-[0-9]{2}$", x)
  qtr <- grepl("^[0-9]{4}-Q[1-4]$", x)
  ann <- grepl("^[0-9]{4}$", x)
  out[day] <- as.Date(x[day])
  # recycle0 = TRUE: with no matches, paste0() must return nothing rather than "-01".
  out[mon] <- as.Date(paste0(x[mon], "-01", recycle0 = TRUE))
  out[qtr] <- as.Date(sprintf("%s-%02d-01", substr(x[qtr], 1, 4),
                              (as.integer(substr(x[qtr], 7, 7)) - 1) * 3 + 1))
  out[ann] <- as.Date(paste0(x[ann], "-01-01", recycle0 = TRUE))
  out
}

# SDMX-CSV text (columns TIME_PERIOD and OBS_VALUE) -> tibble(date, value), sorted.
sdmx_csv_values <- function(raw, what) {
  d <- readr::read_csv(I(raw), col_types = readr::cols(.default = readr::col_character()),
                       progress = FALSE)
  if (!nrow(d) || !all(c("TIME_PERIOD", "OBS_VALUE") %in% names(d))) {
    stop(sprintf("%s: no observations returned", what), call. = FALSE)
  }
  tibble::tibble(date  = sdmx_period_start(d$TIME_PERIOD),
                 value = suppressWarnings(as.numeric(d$OBS_VALUE))) |>
    dplyr::filter(!is.na(date), !is.na(value)) |>
    dplyr::arrange(date)
}

# Limit a (date, value) frame to the window, keeping the last observation at or
# before `start` so a step series (a policy rate whose last change predates the
# window) still has a current value.
trim_window <- function(df, start = NULL, end = NULL) {
  if (!is.null(end)) df <- dplyr::filter(df, date <= as.Date(end))
  if (!is.null(start) && nrow(df)) {
    prior  <- df$date[df$date <= as.Date(start)]
    anchor <- if (length(prior)) max(prior) else min(df$date)
    df <- dplyr::filter(df, date >= anchor)
  }
  df
}
