# ons.R — a time series from the Office for National Statistics (ONS).
#
# Download: https://www.ons.gov.uk/generator?format=csv&uri=<time-series path>
#           The "download CSV" link of an ONS time-series page (public, no key).
# Example: /employmentandlabourmarket/peoplenotinwork/unemployment/timeseries/mgsx/lms
#          = MGSX, unemployment rate aged 16+, seasonally adjusted (Labour Force Survey;
#          each month is the middle of a rolling three-month period).
# ONS data may be reused under the Open Government Licence v3.0 (see data_licenses.csv).
# Returns monthly observations: date (Date, month start), value (numeric).

ons_series <- function(path, start = NULL, end = NULL, ttl = 24 * 3600) {
  url <- paste0("https://www.ons.gov.uk/generator?format=csv&uri=", path)
  df  <- cache_get(url, ttl = ttl, compute = function() {
    # Metadata rows ("Title", "CDID", ...) come first, then annual, quarterly and
    # monthly rows; keep the monthly ones ("2026 MAY").
    d <- suppressWarnings(readr::read_csv(I(http_get_text(url)), col_names = c("period", "value"),
                                          col_types = "cc", progress = FALSE))
    d <- d[grepl("^[0-9]{4} [A-Z]{3}$", d$period), ]
    if (!nrow(d)) stop("ons: no monthly observations returned", call. = FALSE)
    month <- match(substr(d$period, 6, 8), toupper(month.abb))
    tibble::tibble(
      date  = as.Date(sprintf("%s-%02d-01", substr(d$period, 1, 4), month), format = "%Y-%m-%d"),
      value = suppressWarnings(as.numeric(d$value))
    ) |>
      dplyr::filter(!is.na(date), !is.na(value)) |>
      dplyr::arrange(date)
  })
  trim_window(df, start, end)
}
