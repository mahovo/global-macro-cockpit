# licensing.R — which series the public build may republish, and how to credit them.
#
# instructions/data_licenses.csv is the reviewed source of truth, one row per
# displayed series: id, provider, source_ids, licence_class, attribution, source_url.
# The public build embeds data only for series whose licence class is on the
# allow-list below. Pre-approval-required series AND series missing from the table
# are shown as link-only tiles, so a newly added series can't leak data by accident.

PUBLISHABLE_CLASSES <- c("public-domain", "citation-required", "cc-by-4.0",
                         "ecb-terms", "imf-data-terms", "ogl-3.0", "boj-terms", "nyfed-terms")

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

#' Attribution for a tile footer, linked to the source page(s) (the IMF's data terms, for
#' example, ask for a link to the dataset). A series with one source page gets one link.
#' A derived series whose credit lists one source per page, in order ("Source: A; B;
#' regime computed by this site" with two pages), links each source to its own page;
#' any other credit stays plain text.
attribution_tag <- function(entry, lic) {
  urls <- source_urls_for(entry, lic)
  txt  <- attribution_for(entry, lic)
  link <- function(url, text) htmltools::tags$a(href = url, target = "_blank", rel = "noopener",
                                                 class = "link-secondary", text)
  if (length(urls) == 1) return(link(urls, txt))
  parts <- strsplit(sub("^Source: ", "", txt), "; ", fixed = TRUE)[[1]]
  note  <- grepl("computed by this site$", parts)
  if (length(urls) < 2 || !startsWith(txt, "Source: ") || sum(!note) != length(urls)) return(txt)
  k <- cumsum(!note)
  htmltools::tagList("Source: ", lapply(seq_along(parts), function(i)
    htmltools::tagList(if (i > 1) "; ", if (note[i]) parts[i] else link(urls[k[i]], parts[i]))))
}
