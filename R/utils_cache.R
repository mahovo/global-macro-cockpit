# utils_cache.R — small on-disk cache so we don't re-hit upstream APIs
# unnecessarily. Being a polite client is part of staying within technical
# and ethical bounds.

#' Return a cached value if fresh, otherwise compute, store, and return it.
#'
#' @param key   Stable string identifying the request (e.g. a URL).
#' @param ttl   Time-to-live in seconds. Cached files older than this are ignored.
#' @param compute  A zero-arg function that produces the value (a data frame).
cache_get <- function(key, ttl, compute) {
  cache_dir <- file.path(getwd(), ".cache")
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  safe <- gsub("[^A-Za-z0-9._-]", "_", key)
  if (nchar(safe) > 180) safe <- substr(safe, nchar(safe) - 179, nchar(safe))
  path <- file.path(cache_dir, paste0(safe, ".rds"))

  if (file.exists(path)) {
    age <- as.numeric(difftime(Sys.time(), file.info(path)$mtime, units = "secs"))
    if (age < ttl) {
      return(readRDS(path))
    }
  }

  value <- compute()
  saveRDS(value, path)
  value
}
