# imf.R — a series from the IMF's data API (SDMX 2.1, CSV output).
#
# API : https://api.imf.org/external/sdmx/2.1/data/<AGENCY,DATAFLOW>/<KEY>
#       ?detail=dataonly&startPeriod=YYYY-MM                       (public, no key)
# Example: IMF.STA,CPI / GBR.CPI._T.YOY_PCH_PA_PT.M = UK CPI, % change year on year.
# Used instead of DBnomics, whose IMF copy stopped updating in 2025. The IMF's data
# terms ask for a credit naming the dataset, with a link (see data_licenses.csv).
# Returns a tibble: date (Date, period start), value (numeric).

imf_series <- function(flow, key, start = NULL, end = NULL, ttl = 24 * 3600) {
  url <- sprintf("https://api.imf.org/external/sdmx/2.1/data/%s/%s?detail=dataonly%s",
                 flow, key,
                 if (is.null(start)) "" else paste0("&startPeriod=", format(as.Date(start), "%Y-%m")))
  df <- cache_get(url, ttl = ttl, compute = function() {
    raw <- httr2::request(url) |>
      httr2::req_headers(Accept = "application/vnd.sdmx.data+csv;version=1.0.0") |>
      httr2::req_timeout(30) |>
      httr2::req_retry(max_tries = 3, retry_on_failure = TRUE) |>   # also retry timeouts
      httr2::req_perform() |>
      httr2::resp_body_string()
    sdmx_csv_values(raw, "imf")
  })
  trim_window(df, start, end)
}
