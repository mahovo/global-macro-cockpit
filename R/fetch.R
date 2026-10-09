# fetch.R — provider-dispatching fetch layer.
#
# fetch_series() takes one registry entry, dispatches on its effective access
# method, and returns a normalized tidy-long tibble:
#   date, series_id, value, provider, theme, indicator_class, frequency, units, fetched_at
#
# Official statistics APIs (OECD, Eurostat, ECB, IMF), DBnomics and the transform
# DAG sit alongside FRED. Providers not yet implemented raise a clear "pending"
# condition so the resolution report can distinguish "not yet implemented" from "broken".
#
# Curation layer: the YAML is a *starting manifest*, so a few entries carry stale
# or placeholder references (e.g. oecd_cli -> dead OECD/MEI_CLI; ecb_policy_rate
# -> a search string, not a code). ENTRY_OVERRIDES maps those ids to a concrete,
# verified fetch closure, keeping the YAML pure data.

# --- growth/inflation regimes (after Ray Dalio's four economic environments) --------
# A regime series from a monthly leading indicator (`cli`: date, value) and headline
# inflation year on year (`yoy`: date, value, %). Growth momentum is the indicator's
# 3-month change (index points); inflation momentum is inflation minus its average over
# the past 12 months (percentage points; an isolated missing month is filled in from its
# neighbours). Above zero counts as rising. `value` is the regime code: 1 growth up /
# inflation down (Goldilocks), 2 both up (Reflation), 3 growth down / inflation up
# (Stagflation), 4 both down (Disinflationary slowdown); names, tones and colours live in
# R/assess.R and R/tiles.R. `since` and `before` give the start of each month's spell and
# the regime before it. At least 12 months are returned, so a tile's path is complete.
.regime_series <- function(cli, yoy, start) {
  cm  <- seq(min(cli$date), max(cli$date), by = "month")
  lev <- cli$value[match(cm, cli$date)]
  ym  <- seq(min(yoy$date), max(yoy$date), by = "month")
  inf <- stats::approx(yoy$date, yoy$value, xout = ym)$y
  avg <- as.numeric(stats::filter(inf, rep(1 / 12, 12), sides = 1))
  d <- dplyr::inner_join(
    tibble::tibble(date = cm, cli = lev, growth = lev - dplyr::lag(lev, 3)),
    tibble::tibble(date = ym, cpi_yoy = inf, cpi_avg12 = avg, inflation = inf - avg),
    by = "date") |>
    dplyr::filter(!is.na(growth), !is.na(inflation)) |>
    dplyr::arrange(date) |>
    dplyr::mutate(value = ifelse(growth > 0, ifelse(inflation > 0, 2, 1),
                                 ifelse(inflation > 0, 3, 4)))
  if (!nrow(d)) return(d)
  spell    <- cumsum(c(TRUE, diff(d$value) != 0))
  first    <- match(spell, spell)                    # first row of each row's spell
  d$since  <- d$date[first]
  d$before <- ifelse(first > 1, d$value[pmax(first - 1, 1)], NA)
  keep <- min(as.Date(start), seq(max(d$date), by = "-11 months", length.out = 2)[2])
  dplyr::filter(d, date >= keep)
}

# Fetch closure for a regime tile. `cli` and `yoy` are functions of (from, end, ttl);
# they fetch from five years before the window (23 months feed the first value, the
# rest finds where the first spell began).
.regime_fetch <- function(cli, yoy) {
  function(start, end, ttl) {
    from <- as.Date(start) - 5 * 366
    .regime_series(cli(from, end, ttl), yoy(from, end, ttl), start)
  }
}

# Inflation year on year from a monthly price index. A month that was never published
# (US CPI for October 2025, during the federal shutdown) is filled in log-linearly from
# its neighbours before the rate is taken.
.yoy_from_index <- function(idx) {
  months <- seq(min(idx$date), max(idx$date), by = "month")
  lvl <- exp(stats::approx(idx$date, log(idx$value), xout = months)$y)
  tibble::tibble(date = months, value = 100 * (lvl / dplyr::lag(lvl, 12) - 1)) |>
    dplyr::filter(!is.na(value))
}

# Inflation year on year from the published months of a monthly price index only: a month
# with no published index (US CPI for October 2025) gets no value, nor does the month a year
# after it. The regime tiles use .yoy_from_index above instead, which fills such a month in.
.yoy_published <- function(idx) {
  ago <- as.Date(sprintf("%d-%s", as.integer(format(idx$date, "%Y")) - 1, format(idx$date, "%m-%d")))
  tibble::tibble(date = idx$date, value = 100 * (idx$value / idx$value[match(ago, idx$date)] - 1)) |>
    dplyr::filter(!is.na(value)) |>
    dplyr::arrange(date)
}

# Fetch closure for a tile that shows a monthly FRED price index as inflation, % over 12 months.
.yoy_tile <- function(series_id) {
  list(access = "transform", fetch = function(start, end, ttl)
    dplyr::filter(.yoy_published(fred_series(series_id, as.Date(start) - 400, end, ttl = ttl)),
                  date >= as.Date(start)))
}

# Euro-area leading indicator. The OECD publishes none, so this averages the OECD
# indicators for the four largest euro economies, weighted by their nominal GDP in the
# latest year Eurostat has for all four, over the months all four indicators cover.
.cli_euro_area <- function(from, end, ttl) {
  geo <- c(DEU = "DE", FRA = "FR", ITA = "IT", ESP = "ES")
  gdp <- lapply(geo, function(g)
    eurostat_series("nama_10_gdp", paste0("A.CP_MEUR.B1GQ.", g), Sys.Date() - 6 * 366, end, ttl))
  year <- max(Reduce(intersect, lapply(gdp, function(x) as.character(x$date))))
  w    <- vapply(gdp, function(x) x$value[as.character(x$date) == year], numeric(1))
  cli  <- Reduce(function(a, b) dplyr::inner_join(a, b, by = "date"),
                 lapply(names(geo), function(a)
                   dplyr::rename(oecd_cli(a, from, end), !!a := value)))
  tibble::tibble(date = cli$date, value = as.numeric(as.matrix(cli[names(geo)]) %*% (w / sum(w))))
}

# --- stocks vs bonds, expected real returns (after Ray Dalio) -----------------------------
# Pair-tile data: the earnings yield (`ey`: date = quarter end, ey in %) carried forward to
# each day of the real 10-year bond yield (`bond`: daily, %). `value` is the gap in
# percentage points; `equity`, `bond` and `equity_asof` feed the two-line tile
# (spark_plot_pair* in R/tiles.R).
.stocks_vs_bonds <- function(ey, bond, start) {
  i  <- findInterval(bond$date, ey$date)               # latest quarter ended by each day
  ok <- i > 0
  tibble::tibble(date = bond$date[ok], equity = ey$ey[i[ok]], bond = bond$value[ok],
                 equity_asof = ey$date[i[ok]]) |>
    dplyr::mutate(value = equity - bond) |>
    dplyr::filter(!is.na(value), date >= as.Date(start)) |>
    dplyr::arrange(date)
}

# For a stocks-vs-bonds tile read against its own history, because its level isn't
# comparable with the US tile's: `gap_rank` is the share of days since `hist_from` with a
# gap as narrow as the latest or narrower (assess_stocks_bonds_history in R/assess.R).
# The rows are then cut to the window.
.gap_history <- function(full, start) {
  full$gap_rank  <- 100 * mean(full$value <= full$value[nrow(full)])
  full$hist_from <- min(full$date)
  dplyr::filter(full, date >= as.Date(start))
}

# Expected real yield: a nominal yield (`nom`: daily, %) minus the latest expected
# inflation by each day (`inf`: date, %).
.real_yield <- function(nom, inf) {
  j <- findInterval(nom$date, inf$date)
  tibble::tibble(date = nom$date[j > 0], value = nom$value[j > 0] - inf$value[j[j > 0]])
}

# Earnings yield from sector accounts: profits after tax over the last four quarters
# (`profit`: quarterly flows, date = quarter start) over the equity issued at each
# quarter's end (`equity`, same dating), in %, dated at the quarter's end.
.earnings_yield <- function(profit, equity) {
  profit <- dplyr::arrange(profit, date)
  ann <- tibble::tibble(date = profit$date,
                        sum4 = as.numeric(stats::filter(profit$value, rep(1, 4), sides = 1)))
  dplyr::inner_join(ann, equity, by = "date") |>
    dplyr::transmute(date = .quarter_end(date), ey = 100 * sum4 / value) |>
    dplyr::filter(!is.na(ey), is.finite(ey)) |>
    dplyr::arrange(date)
}

.quarter_end <- function(d) {                          # quarter start -> quarter end
  m <- as.integer(format(d, "%m")) + 3
  y <- as.integer(format(d, "%Y")) + (m > 12)
  as.Date(sprintf("%d-%02d-01", y, ifelse(m > 12, m - 12, m))) - 1
}

ENTRY_OVERRIDES <- list(
  # OECD CLI: registry points at the discontinued OECD/MEI_CLI; use the live
  # OECD Data Explorer DF_CLI. "OECD" total isn't a valid REF_AREA, so use G20
  # (broad global aggregate incl. China/India) for the global-cycle read.
  oecd_cli = list(
    access = "sdmx",
    fetch  = function(start, end, ttl) oecd_cli("G20", start, end)
  ),
  # Net liquidity = WALCL − TGA − RRP, but WALCL/WDTGAL are in $millions while
  # RRPONTSYD is in $billions — so RRP must be scaled ×1000 before subtracting
  # (the naive formula under-drains by up to ~$2.5T historically). Result in $M.
  # The TGA is its Wednesday level (WDTGAL), matching WALCL's timing; the TGA tile
  # itself shows the week average (WTREGEN).
  net_liquidity = list(
    access = "transform",
    fetch  = function(start, end, ttl) {
      wal <- fred_series("WALCL",     as.Date(start) - 30, end, ttl = ttl)
      tga <- fred_series("WDTGAL",    as.Date(start) - 30, end, ttl = ttl)
      rrp <- fred_series("RRPONTSYD", as.Date(start) - 30, end, ttl = ttl)
      rrp$value <- rrp$value * 1000   # $billions -> $millions
      wide <- .align_locf(list(WALCL = wal, TGA = tga, RRP = rrp), c("WALCL", "TGA", "RRP"))
      tibble::tibble(date = wide$date, value = wide$WALCL - wide$TGA - wide$RRP) |>
        dplyr::filter(!is.na(value), date >= as.Date(start)) |>
        dplyr::arrange(date)
    }
  ),
  # M2 growth year on year (%), from the monthly level (M2SL); the money stock is read by
  # its growth, so the tile shows that rather than the level.
  m2 = list(
    access = "transform",
    fetch  = function(start, end, ttl)
      dplyr::filter(.yoy_from_index(fred_series("M2SL", as.Date(start) - 400, end, ttl = ttl)),
                    date >= as.Date(start))
  ),
  # US price indices shown as inflation over 12 months (%), from published months only.
  cpi_headline     = .yoy_tile("CPIAUCSL"),
  cpi_core         = .yoy_tile("CPILFESL"),
  pce_core         = .yoy_tile("PCEPILFE"),
  ppi_final_demand = .yoy_tile("PPIFIS"),
  # Nonfarm payrolls as BLS reports them: the change from the previous month, in thousands
  # (consecutive published months only).
  nonfarm_payrolls = list(access = "transform", fetch = function(start, end, ttl) {
    p <- fred_series("PAYEMS", as.Date(start) - 62, end, ttl = ttl)
    before <- as.Date(vapply(p$date, function(d) format(seq(d, by = "-1 month", length.out = 2)[2]), ""))
    tibble::tibble(date = p$date, value = p$value - p$value[match(before, p$date)]) |>
      dplyr::filter(!is.na(value), date >= as.Date(start)) |>
      dplyr::arrange(date)
  }),
  # Core capital goods orders and industrial production, % change over 12 months.
  core_capex_orders     = .yoy_tile("NEWORDER"),
  # Real retail and food services sales (St. Louis Fed: Census advance sales deflated by CPI;
  # the id is historical, this is not the control group), % change over 12 months.
  retail_sales_control_group = .yoy_tile("RRSFS"),
  industrial_production = .yoy_tile("INDPRO"),
  # ECB deposit facility rate from the ECB Data Portal (verified series key). The
  # DBnomics copy used before lagged the source by weeks and missed rate changes.
  ecb_policy_rate = list(
    access = "sdmx",
    fetch  = function(start, end, ttl)
      ecb_series("FM", "B.U2.EUR.4F.KR.DFR.LEV", start, end, ttl)
  ),
  # Realized 10-year Treasury yield volatility, a free stand-in for the licensed ICE MOVE
  # index (implied volatility): the standard deviation of daily yield changes over 21
  # trading days, annualized, in basis points.
  ust10y_realized_vol = list(
    access = "transform",
    fetch  = function(start, end, ttl) {
      y   <- fred_series("DGS10", as.Date(start) - 45, end, ttl = ttl)
      chg <- c(NA, diff(y$value)) * 100                  # daily change, bp
      vol <- vapply(seq_along(chg), function(i)
        if (i > 21) stats::sd(chg[(i - 20):i]) * sqrt(252) else NA_real_, numeric(1))
      tibble::tibble(date = y$date, value = vol) |>
        dplyr::filter(!is.na(value), date >= as.Date(start)) |>
        dplyr::arrange(date)
    }
  ),
  # Stocks vs bonds, expected real returns: the earnings yield of US nonfinancial
  # corporations (after-tax profits / market value of their equity; quarterly, dated at
  # quarter end and carried forward to each trading day) against the expected real yield
  # on 10-year Treasuries: the nominal yield minus the Cleveland Fed's 10-year expected
  # inflation (monthly, carried forward). One measure for the whole history: TIPS yields
  # start only in 2003 and carried a large liquidity premium in their early years.
  # The pair data come from .stocks_vs_bonds() above.
  stocks_vs_bonds_real = list(
    access = "transform",
    fetch  = function(start, end, ttl) {
      prof <- fred_series("NFCPATAX",    as.Date(start) - 200, end, ttl = ttl)   # $bn, SAAR
      eq   <- fred_series("NCBEILQ027S", as.Date(start) - 200, end, ttl = ttl)   # $m
      ey <- dplyr::inner_join(prof, eq, by = "date", suffix = c("_p", "_e")) |>
        dplyr::transmute(date = .quarter_end(date), ey = 100 * value_p * 1000 / value_e) |>
        dplyr::arrange(date)
      .stocks_vs_bonds(ey, .real_yield(
        nom = fred_series("DGS10",      start,               end, ttl = ttl),    # %, daily
        inf = fred_series("EXPINF10YR", as.Date(start) - 40, end, ttl = ttl)),   # %, monthly
        start = start)
    }
  ),
  # Stocks vs bonds for the euro area, built like the US tile from ECB data. Stocks: the
  # after-tax earnings yield of euro-area non-financial corporations: net entrepreneurial
  # income minus current taxes on income over the last four quarters (the quarterly sector
  # accounts are not seasonally adjusted), over all the equity they have issued at the
  # quarter's end (listed and unlisted shares and other equity, since the income covers
  # quasi-corporations too). The accounts are for the 21-country euro area, Bulgaria
  # included (the 20-country series stopped at the end of 2025), back to 1999. Bonds: the
  # 10-year AAA government yield (ECB yield curve, daily) minus the longer-term HICP
  # expectation in the ECB's Survey of Professional Forecasters (quarterly).
  stocks_vs_bonds_euro_area = list(
    access = "transform",
    fetch  = function(start, end, ttl) {
      qsa <- function(key) ecb_series("QSA", paste0("Q.N.I10.W0.S11.S1.", key), NULL, end, ttl)
      inc <- qsa("_Z.B.B4N._Z._Z._Z.XDC._T.S.V.N._T")   # net entrepreneurial income, EUR m
      tax <- qsa("N.D.D5._Z._Z._Z.XDC._T.S.V.N._T")     # current taxes on income payable
      eq  <- qsa("N.L.LE.F51._Z._Z.XDC._T.S.V.N._T")    # equity issued, end of quarter
      fl  <- dplyr::inner_join(inc, tax, by = "date", suffix = c("_i", "_t"))
      ey  <- .earnings_yield(tibble::tibble(date = fl$date, value = fl$value_i - fl$value_t), eq)
      full <- .stocks_vs_bonds(ey, .real_yield(
        nom = ecb_series("YC",  "B.U2.EUR.4F.G_N_A.SV_C_YM.SR_10Y", NULL, end, ttl),
        inf = ecb_series("SPF", "Q.U2.HICP.POINT.LT.Q.AVG", NULL, end, ttl)),
        start = as.Date("1999-01-01"))
      .gap_history(full, start)
    }
  ),
  # Stocks vs bonds for the UK, built like the euro-area tile from ONS and Bank of England
  # data. Stocks: the after-tax earnings yield of UK private non-financial corporations:
  # their net entrepreneurial income (the balance of primary incomes plus dividends and
  # reinvested earnings paid, minus depreciation, which is gross minus net operating surplus
  # in the ONS profitability data) minus taxes on income, over the last four quarters, over
  # all the equity they have issued at the quarter's end (listed and unlisted shares and
  # other equity). The profitability data stopped at 2025 Q2 (the release is paused), so
  # depreciation for later quarters continues the last value at its growth over the year
  # before; depreciation moves slowly, so the estimate barely moves the yield. Bonds: the
  # Bank of England's 10-year real zero-coupon gilt yield, from index-linked gilts, so
  # measured against RPI inflation.
  stocks_vs_bonds_uk = list(
    access = "transform",
    fetch  = function(start, end, ttl) {
      q <- function(cdid, set = "ukea", topic = "grossdomesticproductgdp")
        ons_series(sprintf("/economy/%s/timeseries/%s/%s", topic, cdid, set), NULL, end, ttl, freq = "quarter")
      bpi  <- q("rpbo")                                   # balance of primary incomes, gross
      div  <- q("roch")                                   # distributed income of corporations paid
      rei  <- q("roci")                                   # reinvested earnings on FDI paid
      tax  <- q("rpla")                                   # taxes on income
      gos  <- q("lrwl", "prof", "nationalaccounts/uksectoraccounts")
      nos  <- q("lrwm", "prof", "nationalaccounts/uksectoraccounts")
      eq   <- Reduce(function(a, b) dplyr::inner_join(a, b, by = "date"),
                     lapply(c("nlbz", "nlca", "nlcb"), function(cd) dplyr::rename(q(cd), !!cd := value)))
      eq   <- tibble::tibble(date = eq$date, value = eq$nlbz + eq$nlca + eq$nlcb) |>
        dplyr::filter(value > 0)                          # the balance sheet starts later than 1987
      cfc  <- dplyr::inner_join(gos, nos, by = "date", suffix = c("_g", "_n")) |>
        dplyr::transmute(date, cfc = value_g - value_n) |>
        dplyr::arrange(date)
      n    <- nrow(cfc)
      grow <- (cfc$cfc[n] / cfc$cfc[n - 4])^(1 / 4)      # quarterly growth over the last year
      later <- sort(bpi$date[bpi$date > cfc$date[n]])
      cfc  <- dplyr::bind_rows(cfc, tibble::tibble(date = later, cfc = cfc$cfc[n] * grow^seq_along(later)))
      fl   <- Reduce(function(a, b) dplyr::inner_join(a, b, by = "date"),
                     list(dplyr::rename(bpi, bpi = value), dplyr::rename(div, div = value),
                          dplyr::rename(rei, rei = value), dplyr::rename(tax, tax = value), cfc))
      ey   <- .earnings_yield(tibble::tibble(date = fl$date,
                value = fl$bpi + fl$div + fl$rei - fl$cfc - fl$tax), eq)
      full <- .stocks_vs_bonds(ey, boe_series("IUDMRZC", as.Date("1985-01-01"), end, ttl),
                               start = as.Date("1985-01-01"))
      .gap_history(full, start)
    }
  ),
  # Growth/inflation regimes (see .regime_series above), one per zone: the OECD leading
  # indicator against headline inflation from the statistics office or its official
  # copy: US CPI (BLS via FRED), euro-area HICP (Eurostat), UK CPI (ONS), and CPI for
  # Japan and China from the IMF's CPI dataset (a few weeks behind the national releases).
  growth_inflation_regime = list(access = "transform", fetch = .regime_fetch(
    cli = function(from, end, ttl) oecd_cli("USA", from, end),
    yoy = function(from, end, ttl) .yoy_from_index(fred_series("CPIAUCSL", from, end, ttl = ttl)))),
  regime_euro_area = list(access = "transform", fetch = .regime_fetch(
    cli = .cli_euro_area,
    yoy = function(from, end, ttl) eurostat_series("prc_hicp_minr", "M.RCH_A.TOTAL.EA", from, end, ttl))),
  regime_uk = list(access = "transform", fetch = .regime_fetch(
    cli = function(from, end, ttl) oecd_cli("GBR", from, end),
    yoy = function(from, end, ttl)
      ons_series("/economy/inflationandpriceindices/timeseries/d7g7/mm23", from, end, ttl))),
  regime_japan = list(access = "transform", fetch = .regime_fetch(
    cli = function(from, end, ttl) oecd_cli("JPN", from, end),
    yoy = function(from, end, ttl) imf_series("IMF.STA,CPI", "JPN.CPI._T.YOY_PCH_PA_PT.M", from, end, ttl))),
  regime_china = list(access = "transform", fetch = .regime_fetch(
    cli = function(from, end, ttl) oecd_cli("CHN", from, end),
    yoy = function(from, end, ttl) imf_series("IMF.STA,CPI", "CHN.CPI._T.YOY_PCH_PA_PT.M", from, end, ttl))),
  # Buffett indicator: the registry's Wilshire id (WILL5000PRFC) 404s on the
  # keyless endpoint. Use the Z.1 corporate-equity market value (NCBEILQ027S,
  # $M) over GDP ($B) — the cleaner flow-of-funds version of the same gauge.
  buffett_indicator = list(
    access = "transform",
    fetch  = function(start, end, ttl) {
      eq  <- fred_series("NCBEILQ027S", as.Date(start) - 400, end, ttl = ttl)
      gdp <- fred_series("GDP",         as.Date(start) - 400, end, ttl = ttl)
      wide <- .align_locf(list(EQ = eq, GDP = gdp), c("EQ", "GDP"))
      tibble::tibble(date = wide$date, value = wide$EQ / (wide$GDP * 1000)) |>
        dplyr::filter(!is.na(value), date >= as.Date(start)) |>
        dplyr::arrange(date)
    }
  )
)

#' Normalize a (date, value) frame to the tidy-long shape, tagged from the entry.
#' Extra columns (the two components of a two-line tile) are kept.
.tidy_long <- function(df, entry) {
  if (is.null(df) || !nrow(df)) return(NULL)
  out <- tibble::tibble(
    date            = df$date,
    series_id       = entry$id,
    value           = df$value,
    provider        = entry$provider %||% NA_character_,
    theme           = entry$theme %||% NA_character_,
    indicator_class = entry$indicator_class %||% NA_character_,
    frequency       = entry$frequency %||% NA_character_,
    units           = entry$units %||% NA_character_,
    fetched_at      = Sys.time()
  )
  for (col in setdiff(names(df), c("date", "value"))) out[[col]] <- df[[col]]
  out
}

#' Fetch one registry entry. `meta` supplies the frequency-based cache TTL.
#' Returns tidy-long data, or a `manual_tile` marker for proprietary/manual entries.
fetch_series <- function(entry, start, end, meta = NULL) {
  ttl <- ttl_for(entry$frequency, meta %||% list())
  ov  <- ENTRY_OVERRIDES[[entry$id]]
  acc <- if (!is.null(ov)) ov$access else effective_access(entry)

  if (acc == "manual") {
    return(structure(list(id = entry$id, manual = TRUE), class = "manual_tile"))
  }

  raw <- if (!is.null(ov)) {
    ov$fetch(start, end, ttl)
  } else switch(acc,
    fred      = fred_series(entry$series_id, start, end, ttl = ttl),
    transform = resolve_transform(entry, start, end, ttl = ttl),
    # dbnomics: a registry entry can carry concrete coordinates (db_provider /
    # db_dataset / db_series); otherwise it stays pending.
    dbnomics  = if (!is.null(entry$db_series))
                  dbnomics_series(entry$db_provider, entry$db_dataset, entry$db_series, start, end, ttl)
                else stop("pending: dbnomics series_code not resolved (no override)", call. = FALSE),
    # sdmx: OECD CLI for any area via `oecd_area`; Eurostat, ECB and IMF series via
    # `sdmx_flow` (dataset or dataflow) + `sdmx_key` (series key).
    sdmx      = if (!is.null(entry$oecd_area)) oecd_cli(entry$oecd_area, start, end)
                else if (!is.null(entry$sdmx_key)) switch(entry$provider %||% "",
                  eurostat = eurostat_series(entry$sdmx_flow, entry$sdmx_key, start, end, ttl),
                  ecb      = ecb_series(entry$sdmx_flow, entry$sdmx_key, start, end, ttl),
                  imf      = imf_series(entry$sdmx_flow, entry$sdmx_key, start, end, ttl),
                  stop(sprintf("pending: no sdmx fetcher for provider '%s'", entry$provider), call. = FALSE))
                else stop("pending: sdmx key not resolved (no override)", call. = FALSE),
    # api: official statistics outside SDMX: Bank of England (`api_code`), ONS
    # (`api_path`), Bank of Japan (`api_db` + `api_code`), New York Fed downloads
    # (`api_path`); other providers stay pending.
    api       = switch(entry$provider %||% "",
                  boe   = boe_series(entry$api_code, start, end, ttl),
                  ons   = ons_series(entry$api_path, start, end, ttl),
                  boj   = boj_series(entry$api_db, entry$api_code, start, end, ttl),
                  nyfed = nyfed_series(entry$api_path, start, end, ttl),
                  stop(sprintf("pending: %s api fetcher (later phase)", entry$provider), call. = FALSE)),
    csv       = stop(sprintf("pending: %s csv fetcher (later phase)", entry$provider), call. = FALSE),
    market    = stop("pending: market fetcher (later phase)", call. = FALSE),
    scrape    = stop("pending: scrape fetcher (later phase)", call. = FALSE),
    stop(sprintf("unknown access '%s' for entry '%s'", acc, entry$id), call. = FALSE)
  )

  .tidy_long(raw, entry)
}
