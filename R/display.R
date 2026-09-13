# display.R — presentation helpers for tiles: human titles, reference lines,
# value formatting, and staleness (data freshness vs expected cadence).

# Acronyms / unit-like tokens to keep uppercase when prettifying ids.
.ACRONYMS <- c("hy","ig","oas","cli","pmi","ism","lei","gdp","cpi","pce","ppi",
  "vix","usd","epu","gpr","nfci","anfci","m2","us","eu","jolts","mba","nahb",
  "sloos","ecb","oecd","bis","ny","spac","ipo","rsp","spy","tsf","fai","ip",
  "dma","cape","ecy","sp500","wti","kc","move","stl","ppi","tcu","ust","effr")

#' Turn a snake_case id into a readable title (acronyms/period tokens upper-cased).
prettify_id <- function(id) {
  parts <- strsplit(id, "_")[[1]]
  out <- vapply(parts, function(w) {
    if (tolower(w) %in% .ACRONYMS) toupper(w)
    else if (grepl("^[0-9]+[a-z]+$", w)) toupper(w)          # 10y, 3m, 5y5y, 200dma
    else paste0(toupper(substr(w, 1, 1)), substr(w, 2, nchar(w)))
  }, character(1))
  paste(out, collapse = " ")
}

# Nicer titles for key series (everything else uses prettify_id()).
TITLE_OVERRIDES <- list(
  curve_10y_3m = "Yield curve 10Y–3M", curve_10y_2y = "Yield curve 10Y–2Y",
  hy_oas = "HY credit spread (OAS)", ig_oas = "IG credit spread (OAS)",
  hy_minus_ig = "HY − IG (decompression)", nfci = "Financial conditions (NFCI)",
  anfci = "Adjusted NFCI", net_liquidity = "Net liquidity (Fed − TGA − RRP)",
  oecd_cli = "OECD CLI (G20)", sahm_realtime = "Sahm rule (real-time)",
  recession_prob_chauvet_piger = "Recession probability", initial_claims = "Initial jobless claims",
  continuing_claims = "Continuing claims", breakeven_10y = "10Y inflation breakeven",
  breakeven_5y = "5Y inflation breakeven", breakeven_5y5y_fwd = "5y5y forward breakeven",
  copper_global = "Copper price", broad_usd = "Broad US dollar", vix = "VIX",
  sp500 = "S&P 500", real_10y_yield = "Real 10Y yield", ecb_policy_rate = "ECB deposit rate",
  case_shiller_price_rent = "Case-Shiller price/rent", building_permits = "Building permits",
  housing_starts = "Housing starts", umich_sentiment = "UMich consumer sentiment",
  buffett_indicator = "Equity / GDP (Buffett)",
  # global (G1)
  ea_10y = "10Y yield — Euro area", de_10y = "10Y yield — Germany",
  fr_10y = "10Y yield — France", it_10y = "10Y yield — Italy",
  uk_10y = "10Y yield — UK", jp_10y = "10Y yield — Japan", ca_10y = "10Y yield — Canada",
  cli_g7 = "OECD CLI — G7", cli_uk = "OECD CLI — UK", cli_japan = "OECD CLI — Japan",
  cli_germany = "OECD CLI — Germany", cli_china = "OECD CLI — China",
  cli_india = "OECD CLI — India", cli_korea = "OECD CLI — Korea", cli_brazil = "OECD CLI — Brazil",
  unemp_uk = "Unemployment — UK", unemp_japan = "Unemployment — Japan",
  unemp_germany = "Unemployment — Germany",
  hicp_ea = "HICP inflation — Euro area", hicp_eu = "HICP inflation — EU",
  hicp_de = "HICP — Germany", hicp_fr = "HICP — France",
  # global (G2)
  rate_3m_euro = "3M rate — Euro area", rate_3m_uk = "3M rate — UK",
  rate_3m_japan = "3M rate — Japan", rate_3m_canada = "3M rate — Canada",
  cpi_uk = "CPI inflation — UK", cpi_japan = "CPI inflation — Japan",
  cpi_china = "CPI inflation — China", cpi_india = "CPI inflation — India",
  pmi_euro = "PMI — Euro area", pmi_uk = "PMI — UK", pmi_japan = "PMI — Japan",
  pmi_china = "PMI — China (Caixin)", pmi_india = "PMI — India"
)

# Reference lines drawn on the mini-chart, where a meaningful threshold exists.
REF_LINES <- list(
  curve_10y_3m = 0, curve_10y_2y = 0, oecd_cli = 100, nfci = 0, anfci = 0,
  breakeven_10y = 2.3, breakeven_5y = 2.3, breakeven_5y5y_fwd = 2.3,
  sahm_realtime = 0.5, real_10y_yield = 0, net_liquidity = NA, buffett_indicator = 1,
  cli_g7 = 100, cli_uk = 100, cli_japan = 100, cli_germany = 100,
  cli_china = 100, cli_india = 100, cli_korea = 100, cli_brazil = 100,
  hicp_ea = 2, hicp_eu = 2, hicp_de = 2, hicp_fr = 2,
  cpi_uk = 2, cpi_japan = 2, cpi_china = 2, cpi_india = 2
)

# Short unit suffixes for the value headline. "k" = thousands (FRED convention
# for payrolls/openings/housing); index/level/ratio series are left blank since
# the title and reference line convey them.
UNITS <- list(
  # rates / spreads / percentages
  curve_10y_3m = "pp", curve_10y_2y = "pp", sahm_realtime = "pp", hy_minus_ig = "pp",
  hy_oas = "%", ig_oas = "%", breakeven_10y = "%", breakeven_5y = "%",
  breakeven_5y5y_fwd = "%", umich_inflation_exp_1y = "%", ecb_policy_rate = "%",
  effr = "%", ust_3m = "%", ust_2y = "%", ust_10y = "%", real_10y_yield = "%",
  recession_prob_chauvet_piger = "%", sloos_ci_tightening = "%", jolts_quits_rate = "%",
  unemployment_rate = "%", household_debt_service_ratio = "%",
  # dollar levels
  fed_balance_sheet = "$M", treasury_general_account = "$M", net_liquidity = "$M",
  retail_sales_control_group = "$M", reverse_repo = "$B", m2 = "$B", real_gdp = "$B",
  # counts (thousands) / hours
  jolts_openings = "k", temp_help_employment = "k", nonfarm_payrolls = "k",
  building_permits = "k", housing_starts = "k", avg_weekly_hours_mfg = "hrs",
  # prices
  copper_global = "USD/t", brent = "USD/bbl", wti = "USD/bbl", henry_hub_gas = "USD/MMBtu",
  # indices
  cpi_headline = "index", cpi_core = "index", pce_core = "index", ppi_final_demand = "index",
  industrial_production = "index", umich_sentiment = "index", broad_usd = "index",
  epu_us_daily = "index", epu_global = "index",
  # ratio
  buffett_indicator = "x",
  # global (G1): yields / unemployment / HICP all in %
  ea_10y = "%", de_10y = "%", fr_10y = "%", it_10y = "%", uk_10y = "%",
  jp_10y = "%", ca_10y = "%", unemp_uk = "%", unemp_japan = "%", unemp_germany = "%",
  hicp_ea = "%", hicp_eu = "%", hicp_de = "%", hicp_fr = "%",
  # global (G2)
  rate_3m_euro = "%", rate_3m_uk = "%", rate_3m_japan = "%", rate_3m_canada = "%",
  cpi_uk = "%", cpi_japan = "%", cpi_china = "%", cpi_india = "%"
)

display_title <- function(entry) TITLE_OVERRIDES[[entry$id]] %||% prettify_id(entry$id)
display_ref   <- function(entry) { r <- REF_LINES[[entry$id]]; if (is.null(r)) NA_real_ else r }
display_unit  <- function(entry) UNITS[[entry$id]] %||% ""

#' Provenance line for a tile footer.
source_label <- function(entry) {
  ref <- entry$series_id %||% entry$sdmx_key %||% entry$dataset %||% entry$formula %||% ""
  prov <- switch(entry$provider %||% "",
    fred = "FRED", dbnomics = "DBnomics", oecd = "OECD", eurostat = "Eurostat",
    ecb = "ECB", imf = "IMF", transform = "derived",
    proprietary = "licensed", entry$provider %||% "")
  paste0(prov, if (nzchar(ref)) paste0(" · ", substr(ref, 1, 40)) else "",
         if (!is.null(entry$frequency)) paste0(" · ", entry$frequency) else "")
}

#' Format a scalar value for the tile headline (magnitude-aware), with unit.
format_value <- function(v, unit = NULL) {
  if (is.null(v) || is.na(v)) return("—")
  txt <- if (abs(v) >= 1000) formatC(v, format = "d", big.mark = ",")
         else if (abs(v) >= 100) formatC(v, format = "f", digits = 1)
         else formatC(v, format = "f", digits = 2)
  if (!is.null(unit) && nzchar(unit)) paste(txt, unit) else txt
}

#' Format the change vs the prior observation, magnitude-aware, signed.
format_change <- function(d) {
  if (is.null(d) || is.na(d)) return("")
  if (abs(d) >= 1000) formatC(d, format = "d", big.mark = ",", flag = "+")
  else if (abs(d) >= 100) formatC(d, format = "f", digits = 1, flag = "+")
  else formatC(d, format = "f", digits = 2, flag = "+")
}

# Max age (days) before a series of a given frequency is considered stale.
.STALE_DAYS <- c(daily = 7, weekly = 12, monthly = 45, quarterly = 130, event = 99999)

#' Is the latest observation older than expected for its frequency?
is_stale <- function(last_date, frequency) {
  if (is.null(last_date) || is.na(last_date)) return(TRUE)
  thr <- .STALE_DAYS[[frequency %||% ""]]
  if (is.null(thr)) thr <- 45
  as.numeric(Sys.Date() - as.Date(last_date)) > thr
}

# --- comparability modes -----------------------------------------------------
# "level" shows native units; "z" shows z-scores vs the window's own history;
# "pct" shows percentile rank. z/pct make heterogeneous series comparable
# ("how stretched is this vs its own past") — the badge still reads the level.

#' Re-express a (date,value) frame in the chosen display mode.
apply_mode <- function(df, mode) {
  if (is.null(df) || !nrow(df) || mode == "level") return(df)
  v <- df$value
  if (mode == "z") {
    s <- stats::sd(v, na.rm = TRUE); if (is.na(s) || s == 0) s <- 1
    df$value <- (v - mean(v, na.rm = TRUE)) / s
  } else if (mode == "pct") {
    df$value <- 100 * (rank(v, ties.method = "average") / length(v))
  }
  df
}

mode_ref <- function(mode, ref) switch(mode, z = 0, pct = 50, ref)

#' Format the headline value for a display mode.
format_value_mode <- function(v, mode, unit) {
  if (is.null(v) || is.na(v)) return("—")
  if (mode == "z")   return(sprintf("%+.1fσ", v))      # ±1.3σ
  if (mode == "pct") return(paste0(round(v), " pct"))
  format_value(v, unit)
}
