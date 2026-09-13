# _http.R — shared HTTP GET helper (underscore sorts first so it loads before
# the fetchers that use it).
#
# Plain httr2 with a few retries and a short backoff for transient failures.
# Responses are cached upstream (utils_cache.R), so requests only happen on a
# genuine cache miss. Any `api_key=` in a URL is redacted from error messages so
# keys never end up in logs.

.redact <- function(x) gsub("(api_key=)[^&[:space:]]+", "\\1***", x)

http_get_text <- function(url, tries = 3, timeout = 20) {
  last_err <- NULL
  for (attempt in seq_len(tries)) {
    res <- tryCatch(
      httr2::request(url) |>
        httr2::req_timeout(timeout) |>
        httr2::req_perform() |>
        httr2::resp_body_string(),
      error = function(e) { last_err <<- conditionMessage(e); NULL }
    )
    if (!is.null(res) && nzchar(res)) return(res)
    if (attempt < tries) Sys.sleep(0.5 * attempt)
  }
  stop(.redact(sprintf("HTTP request failed after %d tries: %s (%s)",
                       tries, url, last_err %||% "empty response")), call. = FALSE)
}
