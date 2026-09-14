# nyfed.R — research data published by the Federal Reserve Bank of New York.
#
# Download: https://www.newyorkfed.org<path>                     (public, no key)
# Example: /medialibrary/research/interactives/data/gscpi/gscpi_interactive_data.csv =
#          Global Supply Chain Pressure Index, the data behind the NY Fed's GSCPI page.
#          One row per month (month-end dates such as "31-Aug-2026") and one column per
#          monthly release; each release revises recent months, so the last column is
#          the current estimate.
# NY Fed content may be reused with its copyright notice (see the public site's footer).
# Returns monthly observations: date (Date, month start), value (numeric).

nyfed_series <- function(path, start = NULL, end = NULL, ttl = 24 * 3600) {
  url <- paste0("https://www.newyorkfed.org", path)
  df  <- cache_get(url, ttl = ttl, compute = function() {
    d <- readr::read_csv(I(http_get_text(url)),
                         col_types = readr::cols(.default = readr::col_character()),
                         na = c("", "NA", "#N/A"), progress = FALSE)
    if (ncol(d) < 2 || !nrow(d)) stop("nyfed: unexpected file layout", call. = FALSE)
    # "31-Aug-2026" -> 2026-08-01, with English month names whatever the session locale.
    parts <- strsplit(d[[1]], "-", fixed = TRUE)
    month <- vapply(parts, function(p) if (length(p) == 3) match(p[2], month.abb) else NA_integer_, integer(1))
    year  <- vapply(parts, function(p) if (length(p) == 3) p[3] else NA_character_, character(1))
    tibble::tibble(
      date  = as.Date(sprintf("%s-%02d-01", year, month), format = "%Y-%m-%d"),
      value = suppressWarnings(as.numeric(d[[ncol(d)]]))
    ) |>
      dplyr::filter(!is.na(date), !is.na(value)) |>
      dplyr::arrange(date)
  })
  trim_window(df, start, end)
}
