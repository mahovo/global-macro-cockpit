# registry.R — load the machine-readable source registry (instructions/sources.yaml)
# and expose helpers the ingestion layer dispatches on.
#
# The YAML is the single source of truth (providers, ~80 series, cache policy,
# cockpit zones). We never hardcode series here; we read them.

#' Path to the registry YAML (relative to the app working directory).
registry_path <- function() file.path(getwd(), "instructions", "sources.yaml")

#' Load the registry. Returns a list with $meta, $providers, $series.
#' Read as UTF-8 explicitly (the YAML contains em-dashes/≈/arrows) so parsing
#' doesn't depend on the system locale. Series from sources_global.yaml (our
#' additions and curation) are merged in, keeping the user's manifest untouched.
load_registry <- function(path = registry_path()) {
  reg <- yaml::yaml.load(readr::read_file(path))
  gpath <- file.path(dirname(path), "sources_global.yaml")
  if (file.exists(gpath)) {
    g <- yaml::yaml.load(readr::read_file(gpath))
    reg$series <- merge_curated(reg$series, g$series, unlist(g$retired))
  }
  reg
}

#' Merge curated series into the manifest's. An entry with `replaces: <id>` takes the
#' place of that manifest series (same tab, same position); other entries are appended.
#' Ids listed under `retired` are dropped.
merge_curated <- function(series, curated = NULL, retired = NULL) {
  ids <- vapply(series, function(e) e$id %||% "", "")
  for (e in curated) {
    at <- if (is.null(e$replaces)) integer(0) else which(ids == e$replaces)
    if (!is.null(e$replaces) && !length(at)) {
      warning(sprintf("sources_global.yaml: '%s' replaces unknown id '%s'", e$id, e$replaces), call. = FALSE)
    }
    if (length(at)) {
      for (i in at) series[[i]] <- e
      ids[at] <- e$id
    } else {
      series[[length(series) + 1]] <- e
      ids <- c(ids, e$id)
    }
  }
  series[!(ids %in% retired)]
}

# Map a provider -> its default access method when a series omits `access`.
PROVIDER_ACCESS <- c(
  fred = "fred", dbnomics = "dbnomics", oecd = "sdmx", ecb = "sdmx",
  eurostat = "sdmx", imf = "sdmx", bis = "dbnomics", transform = "transform",
  proprietary = "manual", treasury = "api", bls = "api", bea = "api",
  eia = "api", census = "api", worldbank = "api", atlantafed = "api",
  boe = "api", ons = "api", boj = "api",
  cpb = "csv", nyfed = "csv", policyuncertainty = "csv", gpr = "csv",
  shiller = "csv", finra = "csv", naaim = "scrape", coingecko = "api",
  googletrends = "api", stooq = "market", market_keyed = "market"
)

#' Effective access method for a registry entry (explicit `access` wins).
effective_access <- function(entry) {
  if (!is.null(entry$access)) return(entry$access)
  pa <- PROVIDER_ACCESS[[entry$provider %||% ""]]
  if (is.null(pa)) "unknown" else pa
}

#' Convert a TTL string ("6h", "1d", "3d") to seconds.
parse_ttl <- function(s) {
  m <- regmatches(s, regexec("^([0-9]+)([hd])$", s))[[1]]
  if (length(m) < 3) return(6 * 3600)
  as.numeric(m[2]) * if (m[3] == "h") 3600 else 86400
}

#' Cache TTL (seconds) for a frequency, from meta$cache$ttl_by_frequency.
ttl_for <- function(frequency, meta) {
  val <- meta$cache$ttl_by_frequency[[frequency %||% ""]]
  if (is.null(val)) 6 * 3600 else parse_ttl(val)
}
