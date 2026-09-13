# eurostat.R — a series from Eurostat's dissemination API (SDMX 2.1, CSV output).
#
# API : https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/<DATASET>/<KEY>
#       ?format=SDMX-CSV&startPeriod=YYYY-MM          (public, no key; CC BY 4.0)
# Example: prc_hicp_minr / M.RCH_A.TOTAL.EA20 = euro-area HICP, annual rate of change
# (the ECOICOP ver. 2 table that replaced prc_hicp_manr in February 2026).
# Returns a tibble: date (Date, period start), value (numeric).

eurostat_series <- function(dataset, key, start = NULL, end = NULL, ttl = 24 * 3600) {
  url <- sprintf("https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/%s/%s?format=SDMX-CSV%s",
                 dataset, key,
                 if (is.null(start)) "" else paste0("&startPeriod=", format(as.Date(start), "%Y-%m")))
  df <- cache_get(url, ttl = ttl, compute = function() sdmx_csv_values(http_get_text(url), "eurostat"))
  trim_window(df, start, end)
}
