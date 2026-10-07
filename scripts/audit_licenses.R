#!/usr/bin/env Rscript
# audit_licenses.R — re-check the FRED copyright status behind every FRED-sourced row
# of instructions/data_licenses.csv, and list FRED series in the registry that the
# table doesn't cover yet. Uses the official FRED API (set FRED_API_KEY).
# It only reports: a human reviews the findings and edits the CSV.
#
# Run from the project root:  Rscript scripts/audit_licenses.R

suppressMessages({ library(dplyr); library(httr2); library(yaml) })
source("R/utf8.R")   # UTF-8 locale first, so the UTF-8 source files read fully
for (f in list.files("R/fetchers", pattern = "\\.R$", full.names = TRUE)) source(f, encoding = "UTF-8")
for (f in c("R/registry.R", "R/display.R", "R/licensing.R")) source(f, encoding = "UTF-8")

key <- fred_api_key()
if (!nzchar(key)) stop("Set FRED_API_KEY to run the licence audit.", call. = FALSE)

# Higher = more restrictive; a derived series takes its most restrictive input.
RANK <- c("public-domain" = 1, "citation-required" = 2, "unknown" = 3, "pre-approval" = 4)

fred_copyright_class <- function(series_id) {
  body <- tryCatch(
    httr2::request("https://api.stlouisfed.org/fred/series/tags") |>
      httr2::req_url_query(series_id = series_id, api_key = key, file_type = "json") |>
      httr2::req_throttle(rate = 100 / 60, realm = "api.stlouisfed.org") |>
      httr2::req_retry(max_tries = 4) |>
      httr2::req_perform() |>
      httr2::resp_body_json(simplifyVector = TRUE),
    error = function(e) NULL)
  tags <- tolower(body$tags$name %||% character())
  if (any(grepl("pre-approval", tags)))          "pre-approval"
  else if (any(grepl("^copyrighted", tags)))     "citation-required"
  else if (any(grepl("^public domain", tags)))   "public-domain"
  else                                           "unknown"
}

lic <- load_licenses()
fred_rows <- lic[lic$provider %in% c("fred", "transform"), , drop = FALSE]
cat(sprintf("Checking %d FRED-sourced rows against the FRED API...\n\n", nrow(fred_rows)))

report <- do.call(rbind, lapply(seq_len(nrow(fred_rows)), function(i) {
  r <- fred_rows[i, ]
  ids <- trimws(strsplit(r$source_ids, ";", fixed = TRUE)[[1]])
  ids <- ids[!grepl(":", ids, fixed = TRUE)]     # other providers' inputs, e.g. OECD's DF_CLI:USA
  classes <- vapply(ids, fred_copyright_class, character(1))
  data.frame(id = r$id, source_ids = r$source_ids, table = r$licence_class,
             fred = classes[which.max(RANK[classes])], stringsAsFactors = FALSE)
}))

if (all(report$fred == "unknown")) {
  cat("FRED's API returned no copyright tags for these series, so this check can't be\n",
      "automated here. Review https://fred.stlouisfed.org/series/<ID> pages manually.\n", sep = "")
} else {
  # A row that also uses another provider's data carries that licence (cc-by-4.0 for OECD
  # inputs): flag it only when its FRED inputs need more than attribution.
  mixed <- !(report$table %in% names(RANK))
  flag  <- ifelse(mixed, RANK[report$fred] > RANK[["citation-required"]], report$table != report$fred)
  diffs <- report[flag, , drop = FALSE]
  if (nrow(diffs)) {
    cat("Rows where FRED's current status differs from the table (review these):\n")
    print(diffs, row.names = FALSE)
  } else {
    cat("All FRED-sourced rows match FRED's current copyright status.\n")
  }
  if (any(report$fred == "unknown")) {
    cat("\n'unknown' = FRED returned no copyright tag; check the series page manually.\n")
  }
}

reg <- load_registry()
fred_ids <- unique(unlist(lapply(reg$series, function(e) if (identical(e$provider, "fred")) e$id)))
missing <- setdiff(fred_ids, lic$id)
if (length(missing)) {
  cat("\nFRED series in the registry with no licence row (the public build shows them link-only):\n")
  cat(paste0("  - ", missing), sep = "\n")
}
