# ecb.R — a series from the ECB Data Portal, the ECB's official statistics API.
#
# API : https://data-api.ecb.europa.eu/service/data/<FLOW>/<KEY>?format=csvdata
#       Public, no key. Example: FM / B.U2.EUR.4F.KR.DFR.LEV = deposit facility rate
#       (one observation per rate change). Used instead of DBnomics, whose ECB copy
#       lagged the source by weeks.
# Returns a tibble: date (Date), value (numeric).

ecb_series <- function(flow, key, start = NULL, end = NULL, ttl = 24 * 3600) {
  # Full history: small for the key rates, and it supplies the carry-in value.
  url <- sprintf("https://data-api.ecb.europa.eu/service/data/%s/%s?format=csvdata", flow, key)
  df  <- cache_get(url, ttl = ttl, compute = function() sdmx_csv_values(http_get_text(url), "ecb"))
  trim_window(df, start, end)
}
