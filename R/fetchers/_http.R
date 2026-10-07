# _http.R — shared HTTP GET helper (underscore sorts first so it loads before
# the fetchers that use it).
#
# Plain httr2 with a few retries and a short backoff for transient failures, a longer
# one for rate limits (429/503), and optional spacing between requests to one host.
# Responses are cached upstream (utils_cache.R), so requests only happen on a
# genuine cache miss. Any `api_key=` in a URL is redacted from error messages so
# keys never end up in logs.

.redact <- function(x) gsub("(api_key=)[^&[:space:]]+", "\\1***", x)

http_get_text <- function(url, tries = 3, timeout = 20, spacing = NULL) {
  last_err <- NULL
  for (attempt in seq_len(tries)) {
    # A server that answers 429 (too many requests) or 503 is tried again after a longer,
    # growing wait, honouring its Retry-After header if it sends one.
    req <- httr2::request(url) |>
      httr2::req_timeout(timeout) |>
      httr2::req_retry(max_tries = 4)
    # `spacing`: at least this many seconds between requests to the same host, for sites
    # with tight rate limits (the ONS website).
    if (!is.null(spacing)) {
      req <- httr2::req_throttle(req, capacity = 1, fill_time_s = spacing,
                                 realm = httr2::url_parse(url)$hostname)
    }
    res <- tryCatch(
      req |>
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
