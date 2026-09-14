# boe.R — a series from the Bank of England Database, the Bank's statistical database.
#
# Download: https://www.bankofengland.co.uk/boeapps/database/_iadb-fromshowcolumns.asp
#           ?csv.x=yes&Datefrom=01/Sep/2021&Dateto=now&SeriesCodes=<CODE>&CSVF=TN&UsingCodes=Y&VPD=Y&VFD=N
#           The Database's CSV download (public, no key). Example: IUDSOIA = SONIA, daily.
# Database data may be reused under the Open Government Licence v3.0; SONIA carries its
# own attribution statement (see data_licenses.csv and the public site's footer).
# Returns a tibble: date (Date), value (numeric).

# "01 Sep 2021" -> Date, with English month names whatever the session locale.
.boe_date <- function(x) {
  parts <- strsplit(trimws(x), " ", fixed = TRUE)
  iso <- vapply(parts, function(p) {
    m <- match(p[2], month.abb)
    if (length(p) != 3 || is.na(m)) NA_character_
    else sprintf("%s-%02d-%02d", p[3], m, as.integer(p[1]))
  }, character(1))
  as.Date(iso, format = "%Y-%m-%d")
}

boe_series <- function(code, start = NULL, end = NULL, ttl = 24 * 3600) {
  from <- as.Date(start %||% "1990-01-01")
  url  <- sprintf(paste0("https://www.bankofengland.co.uk/boeapps/database/_iadb-fromshowcolumns.asp",
                         "?csv.x=yes&Datefrom=%s/%s/%s&Dateto=now&SeriesCodes=%s",
                         "&CSVF=TN&UsingCodes=Y&VPD=Y&VFD=N"),
                  format(from, "%d"), month.abb[as.integer(format(from, "%m"))], format(from, "%Y"), code)
  df <- cache_get(url, ttl = ttl, compute = function() {
    d <- readr::read_csv(I(http_get_text(url)),
                         col_types = readr::cols(.default = readr::col_character()), progress = FALSE)
    if (!nrow(d) || !all(c("DATE", code) %in% names(d))) {
      stop(sprintf("boe: no observations returned for %s", code), call. = FALSE)
    }
    tibble::tibble(date = .boe_date(d$DATE), value = suppressWarnings(as.numeric(d[[code]]))) |>
      dplyr::filter(!is.na(date), !is.na(value)) |>
      dplyr::arrange(date)
  })
  trim_window(df, start, end)
}
