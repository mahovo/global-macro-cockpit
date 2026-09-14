# licensing.R — which series the public build may republish, and how to credit them.
#
# instructions/data_licenses.csv is the reviewed source of truth, one row per
# displayed series: id, provider, source_ids, licence_class, attribution, source_url.
# The public build embeds data only for series whose licence class is on the
# allow-list below. Pre-approval-required series AND series missing from the table
# are shown as link-only tiles, so a newly added series can't leak data by accident.

PUBLISHABLE_CLASSES <- c("public-domain", "citation-required", "cc-by-4.0",
                         "ecb-terms", "imf-data-terms", "ogl-3.0", "boj-terms")

load_licenses <- function(path = file.path(getwd(), "instructions", "data_licenses.csv")) {
  if (!file.exists(path)) {
    return(data.frame(id = character(), provider = character(), source_ids = character(),
                      licence_class = character(), attribution = character(),
                      source_url = character(), stringsAsFactors = FALSE))
  }
  utils::read.csv(path, stringsAsFactors = FALSE, na.strings = "", fileEncoding = "UTF-8")
}

.licence_row <- function(id, lic) {
  r <- lic[lic$id == id, , drop = FALSE]
  if (nrow(r)) r[1, , drop = FALSE] else NULL
}

#' "publish" (embed data) or "link_only" (show a link, no data) for a data series.
publish_policy <- function(entry, lic) {
  r <- .licence_row(entry$id, lic)
  if (!is.null(r) && r$licence_class %in% PUBLISHABLE_CLASSES) "publish" else "link_only"
}

#' Attribution line for a series, e.g. "Source: U.S. Bureau of Labor Statistics via FRED".
attribution_for <- function(entry, lic) {
  r <- .licence_row(entry$id, lic)
  if (is.null(r) || is.na(r$attribution)) return(source_label(entry))
  r$attribution
}

#' Source page link(s) for a series (semicolon-separated in the CSV).
source_urls_for <- function(entry, lic) {
  r <- .licence_row(entry$id, lic)
  if (is.null(r) || is.na(r$source_url)) return(character())
  trimws(strsplit(r$source_url, ";", fixed = TRUE)[[1]])
}

#' Attribution for a tile footer, linked to the source page when a series has exactly
#' one (the IMF's data terms, for example, ask for a link to the dataset).
attribution_tag <- function(entry, lic) {
  urls <- source_urls_for(entry, lic)
  txt  <- attribution_for(entry, lic)
  if (length(urls) != 1) return(txt)
  htmltools::tags$a(href = urls, target = "_blank", rel = "noopener",
                    class = "link-secondary", txt)
}
