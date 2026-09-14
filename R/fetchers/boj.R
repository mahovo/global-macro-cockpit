# boj.R — a series from the Bank of Japan's Time-Series Data Search API.
#
# API : https://www.stat-search.boj.or.jp/api/v1/getDataCode?format=json&lang=en
#       &db=<DB>&code=<SERIES CODE>&startDate=YYYYMM            (public, no key)
# Example: FM01 / STRDCLUCON = uncollateralized overnight call rate, daily average (the
# Bank of Japan's policy target rate). Days without a value come back as null.
# Returns a tibble: date (Date), value (numeric).

boj_series <- function(db, code, start = NULL, end = NULL, ttl = 24 * 3600) {
  url <- sprintf("https://www.stat-search.boj.or.jp/api/v1/getDataCode?format=json&lang=en&db=%s&code=%s%s",
                 db, code,
                 if (is.null(start)) "" else paste0("&startDate=", format(as.Date(start), "%Y%m")))
  df <- cache_get(url, ttl = ttl, compute = function() {
    pages <- list()
    pos   <- NULL
    repeat {   # long requests are split; NEXTPOSITION says where the next part starts
      page_url <- if (is.null(pos)) url else paste0(url, "&startPosition=", pos)
      j <- jsonlite::fromJSON(http_get_text(page_url), simplifyVector = FALSE)
      if (!identical(as.integer(j$STATUS), 200L) || !length(j$RESULTSET)) {
        stop(sprintf("boj: %s", j$MESSAGE %||% "no data returned"), call. = FALSE)
      }
      v <- j$RESULTSET[[1]]$VALUES
      periods <- vapply(v$SURVEY_DATES, function(x) as.character(x), character(1))
      periods <- ifelse(nchar(periods) == 6, paste0(periods, "01"), periods)   # monthly: YYYYMM
      pages[[length(pages) + 1]] <- tibble::tibble(
        date  = as.Date(periods, format = "%Y%m%d"),
        value = vapply(v$VALUES, function(x) if (is.null(x)) NA_real_ else as.numeric(x), numeric(1))
      )
      pos <- j$NEXTPOSITION
      if (is.null(pos) || !nzchar(as.character(pos))) break
    }
    dplyr::bind_rows(pages) |>
      dplyr::filter(!is.na(date), !is.na(value)) |>
      dplyr::distinct(date, .keep_all = TRUE) |>
      dplyr::arrange(date)
  })
  trim_window(df, start, end)
}
