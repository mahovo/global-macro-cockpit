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
.tidy_long <- function(df, entry) {
  if (is.null(df) || !nrow(df)) return(NULL)
  tibble::tibble(
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
    # (`api_path`), Bank of Japan (`api_db` + `api_code`); other providers stay pending.
    api       = switch(entry$provider %||% "",
                  boe = boe_series(entry$api_code, start, end, ttl),
                  ons = ons_series(entry$api_path, start, end, ttl),
                  boj = boj_series(entry$api_db, entry$api_code, start, end, ttl),
                  stop(sprintf("pending: %s api fetcher (later phase)", entry$provider), call. = FALSE)),
    csv       = stop(sprintf("pending: %s csv fetcher (later phase)", entry$provider), call. = FALSE),
    market    = stop("pending: market fetcher (later phase)", call. = FALSE),
    scrape    = stop("pending: scrape fetcher (later phase)", call. = FALSE),
    stop(sprintf("unknown access '%s' for entry '%s'", acc, entry$id), call. = FALSE)
  )

  .tidy_long(raw, entry)
}
