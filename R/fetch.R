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
ENTRY_OVERRIDES <- list(
  # OECD CLI: registry points at the discontinued OECD/MEI_CLI; use the live
  # OECD Data Explorer DF_CLI. "OECD" total isn't a valid REF_AREA, so use G20
  # (broad global aggregate incl. China/India) for the global-cycle read.
  oecd_cli = list(
    access = "sdmx",
    fetch  = function(start, end, ttl) oecd_cli("G20", start, end)
  ),
  # Net liquidity = WALCL − TGA − RRP, but WALCL/WTREGEN are in $millions while
  # RRPONTSYD is in $billions — so RRP must be scaled ×1000 before subtracting
  # (the naive formula under-drains by up to ~$2.5T historically). Result in $M.
  net_liquidity = list(
    access = "transform",
    fetch  = function(start, end, ttl) {
      wal <- fred_series("WALCL",     as.Date(start) - 30, end, ttl = ttl)
      tga <- fred_series("WTREGEN",   as.Date(start) - 30, end, ttl = ttl)
      rrp <- fred_series("RRPONTSYD", as.Date(start) - 30, end, ttl = ttl)
      rrp$value <- rrp$value * 1000   # $billions -> $millions
      wide <- .align_locf(list(WALCL = wal, TGA = tga, RRP = rrp), c("WALCL", "TGA", "RRP"))
      tibble::tibble(date = wide$date, value = wide$WALCL - wide$TGA - wide$RRP) |>
        dplyr::filter(!is.na(value), date >= as.Date(start)) |>
        dplyr::arrange(date)
    }
  ),
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
  # `value` is the gap in percentage points; `equity`, `bond` and `equity_asof` feed the
  # two-line tile (spark_plot_pair* in R/tiles.R).
  stocks_vs_bonds_real = list(
    access = "transform",
    fetch  = function(start, end, ttl) {
      qend <- function(d) {                              # quarter start -> quarter end
        m <- as.integer(format(d, "%m")) + 3
        y <- as.integer(format(d, "%Y")) + (m > 12)
        as.Date(sprintf("%d-%02d-01", y, ifelse(m > 12, m - 12, m))) - 1
      }
      prof <- fred_series("NFCPATAX",    as.Date(start) - 200, end, ttl = ttl)   # $bn, SAAR
      eq   <- fred_series("NCBEILQ027S", as.Date(start) - 200, end, ttl = ttl)   # $m
      nom  <- fred_series("DGS10",       start,                end, ttl = ttl)   # %, daily
      inf  <- fred_series("EXPINF10YR",  as.Date(start) - 40,  end, ttl = ttl)   # %, monthly
      j    <- findInterval(nom$date, inf$date)           # latest monthly estimate by each day
      bond <- tibble::tibble(date = nom$date[j > 0], value = nom$value[j > 0] - inf$value[j[j > 0]])
      ey <- dplyr::inner_join(prof, eq, by = "date", suffix = c("_p", "_e")) |>
        dplyr::transmute(date = qend(date), ey = 100 * value_p * 1000 / value_e) |>
        dplyr::arrange(date)
      i  <- findInterval(bond$date, ey$date)             # latest quarter ended by each day
      ok <- i > 0
      tibble::tibble(date = bond$date[ok], equity = ey$ey[i[ok]], bond = bond$value[ok],
                     equity_asof = ey$date[i[ok]]) |>
        dplyr::mutate(value = equity - bond) |>
        dplyr::filter(!is.na(value), date >= as.Date(start)) |>
        dplyr::arrange(date)
    }
  ),
  # Growth/inflation regime, after Ray Dalio's four economic environments. Growth
  # momentum: the 3-month change in the OECD CLI for the US (index points). Inflation
  # momentum: headline CPI inflation, year on year, minus its average over the past 12
  # months (percentage points). Above zero counts as rising. `value` is the regime code:
  # 1 growth up / inflation down (Goldilocks), 2 both up (Reflation), 3 growth down /
  # inflation up (Stagflation), 4 both down (Disinflationary slowdown); names, tones and
  # colours live in R/assess.R and R/tiles.R. `since` and `before` give the start of the
  # current spell and the regime before it, worked out on the longer history fetched
  # here. At least 12 months are returned, so the quadrant's path is always complete.
  growth_inflation_regime = list(
    access = "transform",
    fetch  = function(start, end, ttl) {
      from <- as.Date(start) - 5 * 366       # 23 months feed the first value; the rest finds spell starts
      cli  <- oecd_cli("USA", from, end)
      cpi  <- fred_series("CPIAUCSL", from, end, ttl = ttl)
      # A month BLS never published (October 2025, during the federal shutdown) is filled
      # in log-linearly from its neighbours before any rate is taken.
      months <- seq(min(cpi$date), max(cpi$date), by = "month")
      lvl  <- exp(stats::approx(cpi$date, log(cpi$value), xout = months)$y)
      yoy  <- 100 * (lvl / dplyr::lag(lvl, 12) - 1)
      avg  <- as.numeric(stats::filter(yoy, rep(1 / 12, 12), sides = 1))
      cm   <- seq(min(cli$date), max(cli$date), by = "month")
      lev  <- cli$value[match(cm, cli$date)]
      d <- dplyr::inner_join(
        tibble::tibble(date = cm, cli = lev, growth = lev - dplyr::lag(lev, 3)),
        tibble::tibble(date = months, cpi_yoy = yoy, cpi_avg12 = avg, inflation = yoy - avg),
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
  ),
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
