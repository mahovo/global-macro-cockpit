# ons.R — a time series from the Office for National Statistics (ONS).
#
# Download: https://www.ons.gov.uk/generator?format=csv&uri=<time-series path>
#           The "download CSV" link of an ONS time-series page (public, no key).
# Example: /employmentandlabourmarket/peoplenotinwork/unemployment/timeseries/mgsx/lms
#          = MGSX, unemployment rate aged 16+, seasonally adjusted (Labour Force Survey;
#          each month is the middle of a rolling three-month period).
# ONS data may be reused under the Open Government Licence v3.0 (see data_licenses.csv).
# Returns observations at `freq`, "month" (the default) or "quarter": date (Date, start of
# the month or quarter), value (numeric).

ons_series <- function(path, start = NULL, end = NULL, ttl = 24 * 3600, freq = "month") {
  url <- paste0("https://www.ons.gov.uk/generator?format=csv&uri=", path)
  df  <- cache_get(paste(url, freq), ttl = ttl, compute = function() {
    # Metadata rows ("Title", "CDID", ...) come first, then annual, quarterly and
    # monthly rows; keep the ones at `freq` ("2026 MAY" or "2026 Q2").
    # The website rate-limits bursts (HTTP 429), so requests are spaced 2 s apart.
    d <- suppressWarnings(readr::read_csv(I(http_get_text(url, spacing = 2)), col_names = c("period", "value"),
                                          col_types = "cc", progress = FALSE))
    d <- d[grepl(if (freq == "quarter") "^[0-9]{4} Q[1-4]$" else "^[0-9]{4} [A-Z]{3}$", d$period), ]
    if (!nrow(d)) stop(sprintf("ons: no %sly observations returned", freq), call. = FALSE)
    month <- if (freq == "quarter") 3 * as.integer(substr(d$period, 7, 7)) - 2
             else match(substr(d$period, 6, 8), toupper(month.abb))
    tibble::tibble(
      date  = as.Date(sprintf("%s-%02d-01", substr(d$period, 1, 4), month), format = "%Y-%m-%d"),
      value = suppressWarnings(as.numeric(d$value))
    ) |>
      dplyr::filter(!is.na(date), !is.na(value)) |>
      dplyr::arrange(date)
  })
  trim_window(df, start, end)
}
