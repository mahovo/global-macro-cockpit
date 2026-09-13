# fred_api.R — fetch a FRED series through the official FRED API.
#
# Needs a free API key (https://fredaccount.stlouisfed.org) in the FRED_API_KEY
# environment variable. fred_series() uses this automatically when a key is set;
# the automated public build requires it.
#
# This product uses the FRED® API but is not endorsed or certified by the
# Federal Reserve Bank of St. Louis.
#
# Returns a tibble: date (Date), value (numeric), with missing obs dropped.

fred_api_key <- function() Sys.getenv("FRED_API_KEY", unset = "")

fred_api_series <- function(id, start, end, key = fred_api_key()) {
  if (!nzchar(key)) stop("FRED_API_KEY is not set", call. = FALSE)

  resp <- tryCatch(
    httr2::request("https://api.stlouisfed.org/fred/series/observations") |>
      httr2::req_url_query(series_id = id, api_key = key, file_type = "json",
                           observation_start = format(as.Date(start)),
                           observation_end   = format(as.Date(end))) |>
      httr2::req_throttle(rate = 100 / 60, realm = "api.stlouisfed.org") |>
      httr2::req_retry(max_tries = 4) |>
      httr2::req_timeout(30) |>
      httr2::req_perform(),
    error = function(e)
      stop(.redact(sprintf("FRED API request for %s failed: %s", id, conditionMessage(e))),
           call. = FALSE)
  )

  obs <- httr2::resp_body_json(resp, simplifyVector = TRUE)$observations
  if (is.null(obs) || !NROW(obs)) {
    return(tibble::tibble(date = as.Date(character()), value = numeric()))
  }
  tibble::tibble(
    date  = as.Date(obs$date),
    value = suppressWarnings(as.numeric(obs$value))   # FRED marks missing values "."
  ) |>
    dplyr::filter(!is.na(value))
}
