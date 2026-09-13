#!/usr/bin/env Rscript
# validate_registry.R — verify which registry series actually resolve before they
# are wired into the dashboard (the design brief: "treat the registry as a starting
# manifest and verify each series resolves before wiring it in").
#
# Every series goes through the real fetch layer. Providers without a fetcher yet
# are reported as "pending:<access>" and licensed headline tiles as "manual". Writes
# instructions/registry_coverage.csv, which both the app and the public build use to
# decide what to show, and prints a summary.
#
# Run from the project root:  Rscript scripts/validate_registry.R

suppressMessages({
  library(dplyr); library(httr2); library(readr); library(tibble); library(yaml)
})

# Load the ingestion layer (fetchers first) as UTF-8, switching the session to a
# UTF-8 locale first if it isn't in one (see R/utf8.R).
source("R/utf8.R")
for (f in list.files("R/fetchers", pattern = "\\.R$", full.names = TRUE)) source(f, encoding = "UTF-8")
for (f in c("R/utils_cache.R", "R/registry.R", "R/transforms.R", "R/fetch.R")) {
  source(f, encoding = "UTF-8")
}

reg    <- load_registry()
meta   <- reg$meta
series <- reg$series
start  <- Sys.Date() - 500   # wide enough that quarterly series/transforms resolve
end    <- Sys.Date()

cat(sprintf("Validating %d series from the registry...\n\n", length(series)))

# Exercise every entry through the real dispatcher, then classify the result.
rows <- lapply(series, function(e) {
  acc <- effective_access(e)
  out <- tryCatch({
    d <- fetch_series(e, start, end, meta)
    if (inherits(d, "manual_tile")) {
      list(status = "manual", rows = NA_integer_, last = NA_character_, note = "flagged tile")
    } else if (is.null(d) || !nrow(d)) {
      list(status = "EMPTY", rows = 0L, last = NA_character_, note = "no rows returned")
    } else {
      list(status = "ok", rows = nrow(d), last = as.character(max(d$date)), note = "")
    }
  }, error = function(err) {
    msg <- conditionMessage(err)
    status <- if (grepl("^pending:", msg)) paste0("pending:", acc) else "ERROR"
    list(status = status, rows = NA_integer_, last = NA_character_, note = msg)
  })

  data.frame(
    id        = e$id,
    provider  = e$provider %||% NA_character_,
    access    = acc,
    ref       = e$series_id %||% e$sdmx_key %||% e$dataset %||% e$endpoint %||% e$route %||% NA_character_,
    theme     = e$theme %||% NA_character_,
    frequency = e$frequency %||% NA_character_,
    status    = out$status,
    rows      = out$rows,
    last_date = out$last,
    note      = substr(out$note, 1, 90),
    stringsAsFactors = FALSE
  )
})

df <- do.call(rbind, rows)
dir.create("instructions", showWarnings = FALSE)
write.csv(df, "instructions/registry_coverage.csv", row.names = FALSE)

# ---- console summary --------------------------------------------------------
cat("=== By status ===\n");        print(table(df$status))
cat("\n=== By access method ===\n"); print(table(df$access))

ok   <- df[df$status == "ok", ]
errs <- df[df$status == "ERROR", ]
cat(sprintf("\nResolved with data: %d ok, %d error, %d empty, %d manual\n",
            nrow(ok), nrow(errs), sum(df$status == "EMPTY"), sum(df$status == "manual")))

if (nrow(errs) || any(df$status == "EMPTY")) {
  cat("\n--- series that errored / returned empty (curate these) ---\n")
  bad <- df[df$status %in% c("ERROR", "EMPTY"), c("id", "ref", "status", "note")]
  print(bad, row.names = FALSE)
}

cat("\nWrote instructions/registry_coverage.csv\n")
