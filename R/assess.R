# assess.R — per-series cycle-read logic. Each assessor maps a (date,value)
# frame to list(text, tone) with tone in good/warn/bad/neutral. Only series with
# a meaningful threshold get an assessor; the rest render value + chart with no
# badge (we don't fabricate thresholds).
#
# The thresholds are data (BADGE_BANDS and BADGE_PARAMS below), read both by the
# assessors and by the user guide (scripts/build_guide.R), so the guide quotes exactly
# what the badges do.

.last <- function(df) if (!is.null(df) && nrow(df)) dplyr::last(df$value) else NA_real_
.prev <- function(df) if (!is.null(df) && nrow(df) > 1) df$value[nrow(df) - 1] else NA_real_
.no_data <- list(text = "No data", tone = "neutral")

# --- badge rules -------------------------------------------------------------
# Band rules read the latest value: the first row whose condition `value <op> at` holds
# gives the badge; the last row (op NA) is the fallback.
.bands <- function(...) {
  r <- matrix(c(...), ncol = 4, byrow = TRUE)
  data.frame(op = r[, 1], at = suppressWarnings(as.numeric(r[, 2])), text = r[, 3],
             tone = r[, 4], stringsAsFactors = FALSE)
}

BADGE_BANDS <- list(
  curve = .bands(                          # yield-curve spread, pp
    "<",  0,   "Inverted — recession lead", "bad",
    "<",  0.5, "Flat — late-cycle",         "warn",
    NA,   NA,  "Positively sloped",         "good"),
  hy = .bands(                             # credit spread (OAS), %
    "<",  3,   "Tight — risk-on",           "neutral",
    "<",  5,   "Normal range",              "good",
    "<",  8,   "Elevated stress",           "warn",
    NA,   NA,  "Stressed — risk-off",       "bad"),
  hy_ig = .bands(                          # HY minus IG spread, pp
    "<",  2,   "Compressed — complacent",   "neutral",
    "<",  3.5, "Normal range",              "good",
    "<",  5,   "Decompressing",             "warn",
    NA,   NA,  "Wide — risk-off",           "bad"),
  nfci = .bands(                           # 0 = average; positive = tighter than average
    ">",  0.5, "Tight — headwind",          "bad",
    ">",  0,   "Slightly tight",            "warn",
    NA,   NA,  "Loose — tailwind",          "good"),
  sahm = .bands(                           # >= 0.5 triggers the Sahm recession rule
    ">=", 0.5, "Triggered — recession",     "bad",
    ">=", 0.3, "Rising — watch",            "warn",
    NA,   NA,  "Below trigger",             "good"),
  recprob = .bands(                        # smoothed recession probability, %
    ">=", 50,  "High probability",          "bad",
    ">=", 20,  "Elevated",                  "warn",
    NA,   NA,  "Low",                       "good"),
  breakeven = .bands(                      # CPI breakeven, %
    "<",  1.8, "Low — disinflation",        "warn",
    "<=", 2.7, "Anchored",                  "good",
    "<=", 3.2, "Elevated",                  "warn",
    NA,   NA,  "High — inflation risk",     "bad"),
  vix = .bands(
    ">=", 30,  "Fear — stress",             "bad",
    ">=", 20,  "Elevated",                  "warn",
    NA,   NA,  "Calm",                      "good"),
  buffett = .bands(                        # corporate equity / GDP ratio
    ">=", 2,   "Very stretched",            "bad",
    ">=", 1.5, "Elevated",                  "warn",
    NA,   NA,  "Moderate",                  "neutral"),
  cpi = .bands(                            # year-over-year inflation rate, %
    "<",  0,   "Deflation",                 "bad",
    "<",  1,   "Below target",              "warn",
    "<=", 2.5, "Near target",               "good",
    "<=", 4,   "Above target",              "warn",
    NA,   NA,  "High",                      "bad"),
  stocks_bonds = .bands(                   # earnings yield minus real 10Y yield, pp
    "<",  0,   "Crossed — bonds out-yield stocks", "bad",
    "<",  1,   "Close to crossing",         "warn",
    NA,   NA,  "Stocks out-yield bonds",    "good"),
  cpi_india = .bands(                      # RBI target: 4% CPI inflation, tolerance band 2-6%
    "<",  2,   "Below the RBI band",        "warn",
    "<=", 6,   "Within the RBI band",       "good",
    NA,   NA,  "Above the RBI band",        "bad"),
  gscpi = .bands(                          # standard deviations from the historical average
    ">=", 2,   "Severe pressure",           "bad",
    ">=", 1,   "Elevated pressure",         "warn",
    ">=", -1,  "Normal range",              "good",
    NA,   NA,  "Slack",                     "neutral")
)

# Parameters of the rules that aren't bands (see each assessor).
BADGE_PARAMS <- list(
  claims  = list(window = 52, rise = 15),        # % rise off the low of the last `window` obs
  cli     = list(trend = 100),                   # long-term trend of an OECD CLI
  copper  = list(lag = 3, band = 1),             # % change over `lag` obs; flat within ±band
  stocks_bonds_history = list(near = 2, narrow = 10, narrower = 25)   # percentile of the gap
)

.band_badge <- function(set, v) {
  r <- BADGE_BANDS[[set]]
  for (i in seq_len(nrow(r))) {
    if (is.na(r$op[i]) || match.fun(r$op[i])(v, r$at[i])) return(list(text = r$text[i], tone = r$tone[i]))
  }
}

#' Assessor reading the latest value against a band rule set.
assess_bands <- function(set) {
  force(set)
  function(df) { v <- .last(df); if (is.na(v)) .no_data else .band_badge(set, v) }
}

assess_curve        <- assess_bands("curve")
assess_hy           <- assess_bands("hy")
assess_hy_ig        <- assess_bands("hy_ig")
assess_nfci         <- assess_bands("nfci")
assess_sahm         <- assess_bands("sahm")
assess_recprob      <- assess_bands("recprob")
assess_breakeven    <- assess_bands("breakeven")
assess_vix          <- assess_bands("vix")
assess_buffett      <- assess_bands("buffett")
assess_cpi          <- assess_bands("cpi")
assess_stocks_bonds <- assess_bands("stocks_bonds")
assess_gscpi        <- assess_bands("gscpi")
assess_cpi_india    <- assess_bands("cpi_india")

assess_claims <- function(df) {         # rising off lows = softening labour
  p <- BADGE_PARAMS$claims
  if (is.null(df) || nrow(df) < 5) return(.no_data)
  v  <- .last(df); lo <- min(utils::tail(df$value, p$window), na.rm = TRUE)
  if (100 * (v - lo) / lo > p$rise) list(text = "Rising off lows", tone = "warn")
  else                              list(text = "Near lows — firm", tone = "good")
}

assess_cli <- function(df) {            # 100 = trend
  trend <- BADGE_PARAMS$cli$trend
  v <- .last(df); p <- .prev(df)
  if (is.na(v) || is.na(p)) return(.no_data)
  rising <- v >= p
  if (v >= trend && rising) list(text = "Above trend & rising", tone = "good")
  else if (v >= trend)      list(text = "Above trend, slowing", tone = "warn")
  else if (rising)          list(text = "Below trend, recovering", tone = "warn")
  else                      list(text = "Below trend & falling", tone = "bad")
}

assess_copper <- function(df) {         # 3-month momentum
  p <- BADGE_PARAMS$copper
  if (is.null(df) || nrow(df) < p$lag + 1) return(.no_data)
  v <- .last(df); ago <- df$value[nrow(df) - p$lag]
  chg <- (v / ago - 1) * 100
  if (chg > p$band)       list(text = "Rising — demand firm", tone = "good")
  else if (chg < -p$band) list(text = "Falling — softening", tone = "warn")
  else                    list(text = "Flat", tone = "neutral")
}

# Euro-area and UK stocks vs bonds: their levels aren't comparable with the US tile's, so
# each is read against its own history (`gap_rank`, `hist_from`: see R/fetch.R); only a
# negative gap is read absolutely.
assess_stocks_bonds_history <- function(df) {
  p <- BADGE_PARAMS$stocks_bonds_history
  v <- .last(df)
  if (is.na(v)) return(.no_data)
  r    <- df$gap_rank[nrow(df)]
  from <- format(df$hist_from[nrow(df)], "%Y")
  if (v < 0)               list(text = "Crossed — bonds out-yield stocks", tone = "bad")
  else if (r <= p$near)    list(text = paste("Near its narrowest since", from), tone = "warn")
  else if (r <= p$narrow)  list(text = paste0("Narrow: bottom ", p$narrow, "% since ", from), tone = "warn")
  else if (r <= p$narrower) list(text = "Narrower than usual", tone = "warn")
  else                     list(text = "Usual range or wider", tone = "good")
}

# Growth/inflation regimes (after Ray Dalio's four environments), indexed by the code
# the fetch layer stores in `value` (R/fetch.R).
REGIMES <- data.frame(
  code      = 1:4,
  name      = c("Goldilocks", "Reflation", "Stagflation", "Disinflationary slowdown"),
  growth    = c(TRUE, TRUE, FALSE, FALSE),    # growth rising?
  inflation = c(FALSE, TRUE, TRUE, FALSE),    # inflation rising?
  tone      = c("good", "warn", "bad", "warn"),
  stringsAsFactors = FALSE
)

assess_regime <- function(df) {
  v <- .last(df)
  if (is.na(v)) .no_data
  else          list(text = REGIMES$name[v], tone = REGIMES$tone[v])
}

# series_id -> assessor
ASSESSORS <- list(
  curve_10y_3m = assess_curve, curve_10y_2y = assess_curve,
  hy_oas = assess_hy, hy_minus_ig = assess_hy_ig,   # no IG badge: the HY bands don't fit IG spreads
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
  cpi_headline = assess_cpi, cpi_core = assess_cpi, pce_core = assess_cpi,
  # global (G2)
  cpi_uk = assess_cpi, cpi_japan = assess_cpi, cpi_india = assess_cpi_india,   # China: no verified target, no badge
  # free replacements for licensed manual tiles
  cli_usa = assess_cli, gscpi = assess_gscpi, stocks_vs_bonds_real = assess_stocks_bonds,
  stocks_vs_bonds_euro_area = assess_stocks_bonds_history, stocks_vs_bonds_uk = assess_stocks_bonds_history,
  growth_inflation_regime = assess_regime, regime_euro_area = assess_regime,
  regime_uk = assess_regime, regime_japan = assess_regime, regime_china = assess_regime
)

#' Assessor for a series id, or NULL.
assess_for <- function(id) ASSESSORS[[id]]
