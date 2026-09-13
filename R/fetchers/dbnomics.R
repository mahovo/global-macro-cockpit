# dbnomics.R — fetch a single series from DBnomics (Banque de France / CEPREMAP).
#
# API : https://api.db.nomics.world/v22/series/<PROVIDER>/<DATASET>/<SERIES_CODE>
#       Public, no key, unified over ECB / BIS / OECD / Eurostat / national sources.
# Returns a tibble: date (Date, period start), value (numeric).

# Parse a DBnomics period string to its period-start Date. Handles
#   daily "YYYY-MM-DD" | monthly "YYYY-MM" | quarterly "YYYY-Qn" | annual "YYYY"
# per element (order matters: test daily/quarterly before the monthly prefix),
# and returns NA for anything unrecognized rather than erroring.
.dbnomics_period1 <- function(x) {
  tryCatch({
    if (grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", x)) return(as.Date(x))
    if (grepl("^[0-9]{4}-Q[1-4]$", x)) {
      mo <- (as.integer(substr(x, 7, 7)) - 1) * 3 + 1
      return(as.Date(sprintf("%s-%02d-01", substr(x, 1, 4), mo)))
    }
    if (grepl("^[0-9]{4}-[0-9]{2}$", x)) return(as.Date(paste0(x, "-01")))
    if (grepl("^[0-9]{4}$", x))          return(as.Date(paste0(x, "-01-01")))
    as.Date(NA)
  }, error = function(e) as.Date(NA))
}

.dbnomics_period <- function(p) {
  as.Date(vapply(as.character(p), .dbnomics_period1, as.Date(NA)), origin = "1970-01-01")
}

dbnomics_series <- function(provider, dataset, series_code, start = NULL, end = NULL,
                            ttl = 24 * 3600) {
  url <- sprintf("https://api.db.nomics.world/v22/series/%s/%s/%s?observations=1",
                 provider, dataset, series_code)

  df <- cache_get(url, ttl = ttl, compute = function() {
    raw  <- http_get_text(url)
    j    <- jsonlite::fromJSON(raw)
    docs <- j$series$docs
    if (is.null(docs) || !length(docs$period)) stop("dbnomics: empty series", call. = FALSE)
    tibble::tibble(
      date  = .dbnomics_period(docs$period[[1]]),
      value = suppressWarnings(as.numeric(docs$value[[1]]))
    ) |>
      dplyr::filter(!is.na(date), !is.na(value)) |>
      dplyr::arrange(date)
  })

  if (!is.null(end)) df <- dplyr::filter(df, date <= as.Date(end))
  if (!is.null(start) && nrow(df)) {
    start <- as.Date(start)
    # Keep the last observation at/just before `start` (the carry-in value) so
    # step series like policy rates — whose last change can predate the window —
    # still render a current value instead of going empty.
    prior  <- df$date[df$date <= start]
    anchor <- if (length(prior)) max(prior) else min(df$date)
    df <- dplyr::filter(df, date >= anchor)
  }
  df
}
