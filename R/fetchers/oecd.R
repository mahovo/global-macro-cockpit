# oecd.R — OECD Composite Leading Indicator (CLI), amplitude-adjusted.
#
# Source : OECD Data Explorer, dataflow DSD_STES@DF_CLI (public SDMX API, no key).
# Endpoint: https://sdmx.oecd.org/public/rest/data/OECD.SDD.STES,DSD_STES@DF_CLI,/
#           <REF_AREA>.M.LI...AA...H?startPeriod=YYYY-MM&format=csvfilewithlabels
# Key dims: REF_AREA.FREQ.MEASURE.UNIT.ACTIVITY.ADJUSTMENT.TRANSFORM.HORIZON.METHOD
#           We pin FREQ=M, MEASURE=LI, ADJUSTMENT=AA (amplitude adjusted),
#           METHODOLOGY=H (OECD harmonised); the rest resolve by wildcard.
#
# CLI is indexed so 100 = long-run trend: >100 & rising = expansion.
# Returns a tibble: date (Date, month start), value (numeric).

oecd_cli <- function(ref_area = "USA", start, end) {
  startp <- format(start, "%Y-%m")
  url <- sprintf(
    "https://sdmx.oecd.org/public/rest/data/OECD.SDD.STES,DSD_STES@DF_CLI,/%s.M.LI...AA...H?startPeriod=%s&format=csvfilewithlabels",
    ref_area, startp
  )

  cache_get(url, ttl = 24 * 3600, compute = function() {
    raw <- http_get_text(url)
    df  <- readr::read_csv(raw, show_col_types = FALSE, progress = FALSE)

    tibble::tibble(
      date  = as.Date(paste0(df$TIME_PERIOD, "-01")),
      value = suppressWarnings(as.numeric(df$OBS_VALUE))
    ) |>
      dplyr::filter(!is.na(value)) |>
      dplyr::arrange(date)
  }) |>
    dplyr::filter(date <= end)
}
