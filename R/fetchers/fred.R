# fred.R — fetch a single FRED series.
#
# Source : Federal Reserve Bank of St. Louis (FRED).
# With FRED_API_KEY set (recommended, and required by the public build) this uses
# the official FRED API via fred_api_series(). Without a key it falls back to the
# public graph-CSV download (fredgraph.csv), which is fine for occasional personal
# use. Responses are cached with a TTL by series frequency; cache keys never
# contain the API key.
#
# Returns a tibble: date (Date), value (numeric), with missing obs dropped.

fred_series <- function(id, start, end, ttl = 6 * 3600) {
  use_api   <- nzchar(fred_api_key())
  cache_key <- sprintf("fred_%s_%s_%s_%s", if (use_api) "api" else "csv",
                       id, format(start), format(end))

  cache_get(cache_key, ttl = ttl, compute = function() {
    if (use_api) return(fred_api_series(id, start, end))

    url <- sprintf(
      "https://fred.stlouisfed.org/graph/fredgraph.csv?id=%s&cosd=%s&coed=%s",
      id, format(start), format(end)
    )
    df <- readr::read_csv(
      http_get_text(url), show_col_types = FALSE, progress = FALSE,
      na = c("", ".", "NA", "NaN")
    )
    names(df) <- c("date", "value")
    tibble::tibble(
      date  = as.Date(df$date),
      value = suppressWarnings(as.numeric(df$value))
    ) |>
      dplyr::filter(!is.na(value))
  })
}
