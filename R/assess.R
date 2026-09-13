# assess.R — per-series cycle-read logic. Each assessor maps a (date,value)
# frame to list(text, tone) with tone in good/warn/bad/neutral. Only series with
# a meaningful threshold get an assessor; the rest render value + chart with no
# badge (we don't fabricate thresholds).

.last <- function(df) if (!is.null(df) && nrow(df)) dplyr::last(df$value) else NA_real_
.prev <- function(df) if (!is.null(df) && nrow(df) > 1) df$value[nrow(df) - 1] else NA_real_

assess_curve <- function(df) {
  v <- .last(df)
  if (is.na(v))     list(text = "No data", tone = "neutral")
  else if (v < 0)   list(text = "Inverted — recession lead", tone = "bad")
  else if (v < 0.5) list(text = "Flat — late-cycle", tone = "warn")
  else              list(text = "Positively sloped", tone = "good")
}

assess_hy <- function(df) {
  v <- .last(df)
  if (is.na(v))    list(text = "No data", tone = "neutral")
  else if (v < 3)  list(text = "Tight — risk-on", tone = "neutral")
  else if (v < 5)  list(text = "Normal range", tone = "good")
  else if (v < 8)  list(text = "Elevated stress", tone = "warn")
  else             list(text = "Stressed — risk-off", tone = "bad")
}

assess_hy_ig <- function(df) {
  v <- .last(df)
  if (is.na(v))      list(text = "No data", tone = "neutral")
  else if (v < 2)    list(text = "Compressed — complacent", tone = "neutral")
  else if (v < 3.5)  list(text = "Normal range", tone = "good")
  else if (v < 5)    list(text = "Decompressing", tone = "warn")
  else               list(text = "Wide — risk-off", tone = "bad")
}

assess_nfci <- function(df) {           # 0 = average; positive = tighter than average
  v <- .last(df)
  if (is.na(v))      list(text = "No data", tone = "neutral")
  else if (v > 0.5)  list(text = "Tight — headwind", tone = "bad")
  else if (v > 0)    list(text = "Slightly tight", tone = "warn")
  else               list(text = "Loose — tailwind", tone = "good")
}

assess_sahm <- function(df) {           # >= 0.5 triggers the Sahm recession rule
  v <- .last(df)
  if (is.na(v))       list(text = "No data", tone = "neutral")
  else if (v >= 0.5)  list(text = "Triggered — recession", tone = "bad")
  else if (v >= 0.3)  list(text = "Rising — watch", tone = "warn")
  else                list(text = "Below trigger", tone = "good")
}

assess_recprob <- function(df) {        # smoothed recession probability, %
  v <- .last(df)
  if (is.na(v))      list(text = "No data", tone = "neutral")
  else if (v >= 50)  list(text = "High probability", tone = "bad")
  else if (v >= 20)  list(text = "Elevated", tone = "warn")
  else               list(text = "Low", tone = "good")
}

assess_claims <- function(df) {         # rising off lows = softening labour
  if (is.null(df) || nrow(df) < 5) return(list(text = "No data", tone = "neutral"))
  v  <- .last(df); lo <- min(utils::tail(df$value, 52), na.rm = TRUE)
  if ((v - lo) / lo > 0.15) list(text = "Rising off lows", tone = "warn")
  else                      list(text = "Near lows — firm", tone = "good")
}

assess_cli <- function(df) {            # 100 = trend
  v <- .last(df); p <- .prev(df)
  if (is.na(v) || is.na(p)) return(list(text = "No data", tone = "neutral"))
  rising <- v >= p
  if (v >= 100 && rising) list(text = "Above trend & rising", tone = "good")
  else if (v >= 100)      list(text = "Above trend, slowing", tone = "warn")
  else if (rising)        list(text = "Below trend, recovering", tone = "warn")
  else                    list(text = "Below trend & falling", tone = "bad")
}

assess_breakeven <- function(df) {      # 10y CPI breakeven, %
  v <- .last(df)
  if (is.na(v))       list(text = "No data", tone = "neutral")
  else if (v < 1.8)   list(text = "Low — disinflation", tone = "warn")
  else if (v <= 2.7)  list(text = "Anchored", tone = "good")
  else if (v <= 3.2)  list(text = "Elevated", tone = "warn")
  else                list(text = "High — inflation risk", tone = "bad")
}

assess_vix <- function(df) {
  v <- .last(df)
  if (is.na(v))       list(text = "No data", tone = "neutral")
  else if (v >= 30)   list(text = "Fear — stress", tone = "bad")
  else if (v >= 20)   list(text = "Elevated", tone = "warn")
  else                list(text = "Calm", tone = "good")
}

assess_buffett <- function(df) {        # corporate equity / GDP ratio
  v <- .last(df)
  if (is.na(v))      list(text = "No data", tone = "neutral")
  else if (v >= 2)   list(text = "Very stretched", tone = "bad")
  else if (v >= 1.5) list(text = "Elevated", tone = "warn")
  else               list(text = "Moderate", tone = "neutral")
}

assess_cpi <- function(df) {            # year-over-year inflation rate, %
  v <- .last(df)
  if (is.na(v))      list(text = "No data", tone = "neutral")
  else if (v < 0)    list(text = "Deflation", tone = "bad")
  else if (v < 1)    list(text = "Below target", tone = "warn")
  else if (v <= 2.5) list(text = "Near target", tone = "good")
  else if (v <= 4)   list(text = "Above target", tone = "warn")
  else               list(text = "High", tone = "bad")
}

assess_copper <- function(df) {         # 3-month momentum
  if (is.null(df) || nrow(df) < 4) return(list(text = "No data", tone = "neutral"))
  v <- .last(df); ago <- df$value[nrow(df) - 3]
  chg <- (v / ago - 1) * 100
  if (chg > 1)       list(text = "Rising — demand firm", tone = "good")
  else if (chg < -1) list(text = "Falling — softening", tone = "warn")
  else               list(text = "Flat", tone = "neutral")
}

# series_id -> assessor
ASSESSORS <- list(
  curve_10y_3m = assess_curve, curve_10y_2y = assess_curve,
  hy_oas = assess_hy, ig_oas = assess_hy, hy_minus_ig = assess_hy_ig,
  nfci = assess_nfci, anfci = assess_nfci,
  sahm_realtime = assess_sahm, recession_prob_chauvet_piger = assess_recprob,
  initial_claims = assess_claims, continuing_claims = assess_claims,
  oecd_cli = assess_cli,
  breakeven_10y = assess_breakeven, breakeven_5y = assess_breakeven,
  breakeven_5y5y_fwd = assess_breakeven, vix = assess_vix, copper_global = assess_copper,
  buffett_indicator = assess_buffett,
  # global (G1): regional CLIs read like the US CLI; HICP like CPI
  cli_g7 = assess_cli, cli_uk = assess_cli, cli_japan = assess_cli, cli_germany = assess_cli,
  cli_china = assess_cli, cli_india = assess_cli, cli_korea = assess_cli, cli_brazil = assess_cli,
  hicp_ea = assess_cpi, hicp_eu = assess_cpi, hicp_de = assess_cpi, hicp_fr = assess_cpi,
  # global (G2)
  cpi_uk = assess_cpi, cpi_japan = assess_cpi, cpi_china = assess_cpi, cpi_india = assess_cpi
)

#' Assessor for a series id, or NULL.
assess_for <- function(id) ASSESSORS[[id]]
