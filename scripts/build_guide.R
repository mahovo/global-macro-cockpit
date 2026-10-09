#!/usr/bin/env Rscript
# build_guide.R -- render the user guide (guide/*.md) into _site/guide/index.html.
#
# The guide's text lives in Markdown under guide/: Part I (00-introduction.md), the
# opening of Parts II and III (10-tabs.md, 20-tiles.md), one file per dashboard tab
# (guide/tabs/<view id>.md, in the order of VIEWS in R/views.R) and the appendices
# (9*.md). A tab file holds the tab's own section, then a line "<!-- tiles -->", then
# its tiles; the first part goes to Part II and the rest to Part III.
#
# Facts that live in the code are filled in here, so the guide can't drift from the
# dashboard. Three directives, each on a line of its own:
#   {{tab <view id>}}                  heading + fact box for a tab (zone, tiles)
#   {{tile <id> lag="<text>"}}         heading + fact box for a tile: title, source and
#                                      licence, frequency, unit, class, reference line,
#                                      badge, who computes it
#   {{badge <id> var="<TeX symbol>"}}  the tile's badge rules as a table, from the data
#                                      in R/assess.R (BADGE_BANDS, BADGE_PARAMS, REGIMES)
# Math is LaTeX in the Markdown, typeset by pandoc as MathML (no JavaScript). HTML
# comments in the Markdown (source notes) are left out of the page.
#
# Coverage: every tile a tab shows needs a section, and a section for a tile the tab
# doesn't show is a gap too. Gaps stop the build when run locally; in CI (the CI
# environment variable set) they are warnings, so they never hold back a deploy.
#
# Run from the project root after scripts/build_site.R (which clears _site/):
#   Rscript scripts/build_guide.R
# Needs pandoc (version 2.12 or later; set PANDOC to choose a binary). The Pages
# workflow installs pandoc 3.2, the version the guide is checked with.
#
# This script's own strings are ASCII-only (non-ASCII characters are built with
# intToUtf8()), like build_site.R.

source("R/utf8.R")
for (f in c("R/registry.R", "R/display.R", "R/views.R", "R/assess.R", "R/licensing.R")) {
  source(f, encoding = "UTF-8")
}
`%||%` <- function(a, b) if (is.null(a)) b else a

GUIDE_DIR <- "guide"
OUT_DIR   <- file.path("_site", "guide")
DOT       <- intToUtf8(0xB7)     # middle dot
SIGMA     <- intToUtf8(0x3C3)

REGISTRY <- load_registry()
LIC      <- load_licenses()
COVERAGE <- utils::read.csv("instructions/registry_coverage.csv", stringsAsFactors = FALSE)
FETCH_OVERRIDES <- local({        # ids computed by the dashboard (R/fetch.R), without sourcing it
  src <- readLines("R/fetch.R", encoding = "UTF-8", warn = FALSE)
  body <- src[seq(grep("^ENTRY_OVERRIDES <- list", src), length(src))]
  sub("^  ([a-z0-9_]+) *= .*", "\\1", grep("^  [a-z0-9_]+ *= ", body, value = TRUE))
})
REDIRECT_ONLY <- c("oecd_cli", "ecb_policy_rate")   # overrides that only point at a source
APPENDIX_SECTION <- c(                             # tile -> its section of Appendix A
  net_liquidity = "a-net-liquidity", m2 = "a-notation", cpi_headline = "a-notation",
  cpi_core = "a-notation", pce_core = "a-notation", ppi_final_demand = "a-notation", hy_minus_ig = "a-hy-ig", case_shiller_price_rent = "a-price-rent",
  ust10y_realized_vol = "a-realized-vol", buffett_indicator = "a-buffett",
  stocks_vs_bonds_real = "a-stocks-bonds", stocks_vs_bonds_euro_area = "a-stocks-bonds",
  stocks_vs_bonds_uk = "a-stocks-bonds", growth_inflation_regime = "a-regimes",
  regime_euro_area = "a-regimes", regime_uk = "a-regimes", regime_japan = "a-regimes",
  regime_china = "a-regimes")

entry_by_id <- function(id) {
  for (e in REGISTRY$series) if (identical(e$id, id)) return(e)
  stop(sprintf("guide: unknown tile id '%s'", id), call. = FALSE)
}

# Tiles a tab shows: its registry series that resolve or are manual, as build_site.R
# decides (pending series have statuses such as "pending:csv" and are shown nowhere).
shown_ids <- function(view) {
  ids <- vapply(view_series(view, REGISTRY), function(e) e$id, "")
  st  <- COVERAGE$status[match(ids, COVERAGE$id)]
  ids[!is.na(st) & st %in% c("ok", "manual")]
}

esc <- function(x) htmltools::htmlEscape(x)
link <- function(url, text) sprintf('<a href="%s">%s</a>', esc(url), esc(text))

UNIT_WORDS <- c(pp = "percentage points (pp)", "%" = "percent", "$M" = "US$ millions",
                "$B" = "US$ billions", k = "thousands", bp = "basis points (bp)",
                x = "ratio (times)", index = "index", hrs = "hours",
                "USD/bbl" = "US$ per barrel", "USD/MMBtu" = "US$ per million BTU",
                "USD/t" = "US$ per metric ton")
UNIT_WORDS[[SIGMA]] <- "standard deviations"

LICENCE_WORDS <- c(
  "public-domain"     = "Public domain",
  "citation-required" = "Free to reuse with a citation",
  "cc-by-4.0"         = "CC BY 4.0",
  "ecb-terms"         = "ECB reuse terms",
  "imf-data-terms"    = "IMF data terms",
  "ogl-3.0"           = "Open Government Licence v3.0",
  "boj-terms"         = "Bank of Japan terms of use",
  "nyfed-terms"       = "New York Fed terms of use",
  "pre-approval"      = "Republication needs the provider's permission")

facts_box <- function(rows) {
  rows <- rows[!vapply(rows, is.null, logical(1))]
  paste0('<dl class="facts">',
         paste0("<dt>", names(rows), "</dt><dd>", unlist(rows), "</dd>", collapse = ""),
         "</dl>")
}

tile_block <- function(id, lag = NULL) {
  e    <- entry_by_id(id)
  view <- Filter(function(v) (e$theme %||% "") %in% v$themes, VIEWS)[[1]]
  r    <- LIC[LIC$id == id, , drop = FALSE]
  urls <- if (nrow(r) && !is.na(r$source_url[1])) trimws(strsplit(r$source_url[1], ";", fixed = TRUE)[[1]]) else character()
  attr <- if (nrow(r) && !is.na(r$attribution[1])) sub("^Source: ", "", r$attribution[1]) else source_label(e)
  ref  <- e$series_id %||% e$sdmx_key %||% e$api_code %||% e$formula
  source <- paste0(esc(attr),
    if (length(urls) == 1 && !is.null(ref)) paste0(", series ", link(urls, ref))
    else if (length(urls)) {
      ids <- trimws(strsplit(r$source_ids[1] %||% "", ";", fixed = TRUE)[[1]])
      if (length(ids) != length(urls)) ids <- seq_along(urls)
      paste0(", series ", paste(mapply(link, urls, ids), collapse = ", "))
    }
    else "")
  manual <- identical(e$access, "manual")
  if (manual) {                           # a manual tile: credit the linked site(s)
    u <- if (!is.null(e$url)) e$url else vapply(e$links %||% list(), function(l) l$url, "")
    source <- if (length(u)) paste0("The tile links to ", paste(vapply(u, function(x)
      link(x, sub("^https?://([^/]+).*", "\\1", x)), ""), collapse = ", ")) else "Licensed"
  }
  licence <- if (manual) "Licensed; no data in either edition"
    else if (!nrow(r)) "Not reviewed; link-only on the public site"
    else paste0(esc(LICENCE_WORDS[[r$licence_class[1]]] %||% r$licence_class[1]), "; ",
                if (r$licence_class[1] %in% PUBLISHABLE_CLASSES) "data shown on the public site"
                else "link-only on the public site (data in the local app)")
  computed <- if (id %in% setdiff(FETCH_OVERRIDES, REDIRECT_ONLY) || identical(e$provider, "transform"))
    paste0("The dashboard, from published inputs (", link(paste0("#", if (id %in% names(APPENDIX_SECTION)) APPENDIX_SECTION[[id]] else "appendix-formulas"),
                                                          "Appendix A"), ")")
    else if (manual) NULL else "The publisher; the dashboard shows it unchanged"
  unit <- display_unit(e)
  refl <- display_ref(e)
  heading <- sprintf("### %s {#%s}", display_title(e), id)
  box <- facts_box(list(
    "Source"            = source,
    "Licence"           = licence,
    "Frequency"         = paste0(e$frequency %||% "", if (!is.null(lag)) paste0(" ", DOT, " ", esc(lag))),
    "Unit"              = if (nzchar(unit)) esc(if (unit %in% names(UNIT_WORDS)) UNIT_WORDS[[unit]] else unit) else NULL,
    "Indicator class"   = esc(e$indicator_class %||% ""),
    "Computed by"       = computed,
    "On the dashboard"  = paste0(link(paste0("#tab-", view$id), view$title), " tab", " ", DOT, " ",
                                 if (is.na(refl)) "no reference line" else paste("reference line at", format(refl)),
                                 " ", DOT, " ", if (is.null(assess_for(id))) "no badge" else "badge")))
  c(heading, "", box, "")
}

tab_block <- function(view_id) {
  v   <- Filter(function(v) v$id == view_id, VIEWS)[[1]]
  ids <- shown_ids(v)
  titles <- vapply(ids, function(id) display_title(entry_by_id(id)), "")
  box <- facts_box(list(
    "Cockpit zone" = esc(v$zone),
    "Tiles"        = paste0(length(ids), ": ", paste(mapply(function(i, t) link(paste0("#", i), t), ids, titles),
                                                     collapse = paste0(" ", DOT, " ")))))
  c(sprintf("## %s {#tab-%s}", v$title, v$id), "", box, "")
}

# --- badge tables (from R/assess.R) ---------------------------------------------
tone_span <- function(text, tone) sprintf('<span class="tone %s">%s</span>', tone, esc(text))
num <- function(a) format(a, trim = TRUE)
TEX_OP <- c("<" = "<", "<=" = "\\le", ">" = ">", ">=" = "\\ge")

# Condition of each row of a band rule set: its own test, bounded by the previous row's.
band_conditions <- function(r, x) {
  vapply(seq_len(nrow(r)), function(i) {
    op <- r$op[i]; prev <- if (i > 1) r$op[i - 1] else NA
    if (is.na(op)) {                                        # fallback: not the last test
      neg <- c("<" = "\\ge", "<=" = ">", ">" = "\\le", ">=" = "<")[[prev]]
      return(sprintf("$%s %s %s$", x, neg, num(r$at[i - 1])))
    }
    if (is.na(prev)) return(sprintf("$%s %s %s$", x, TEX_OP[[op]], num(r$at[i])))
    if (op %in% c("<", "<=")) {                             # ascending: lower bound from prev
      lo <- c("<" = "\\le", "<=" = "<")[[prev]]
      sprintf("$%s %s %s %s %s$", num(r$at[i - 1]), lo, x, TEX_OP[[op]], num(r$at[i]))
    } else {                                                # descending: upper bound from prev
      lo <- c(">" = "<", ">=" = "\\le")[[op]]
      hi <- c(">" = "\\le", ">=" = "<")[[prev]]
      sprintf("$%s %s %s %s %s$", num(r$at[i]), lo, x, hi, num(r$at[i - 1]))
    }
  }, "")
}

badge_table <- function(id, x) {
  fn <- assess_for(id)
  if (is.null(fn)) stop(sprintf("guide: '%s' has no badge", id), call. = FALSE)
  rows <- if (!is.null(environment(fn)$set)) {
    r <- BADGE_BANDS[[environment(fn)$set]]
    data.frame(cond = band_conditions(r, x), text = r$text, tone = r$tone, stringsAsFactors = FALSE)
  } else if (identical(fn, assess_stocks_bonds_history)) {
    p <- BADGE_PARAMS$stocks_bonds_history
    probe <- function(v, rank) {           # the assessor's own text, with a placeholder year
      a <- fn(data.frame(date = Sys.Date(), value = v, gap_rank = rank, hist_from = as.Date("9999-01-01")))
      c(text = a$text, tone = a$tone)
    }
    cases <- list(list(sprintf("$%s < 0$", x), probe(-1, 50)),
                  list(sprintf("$%s \\ge 0,\\ R \\le %s$", x, num(p$near)), probe(1, p$near)),
                  list(sprintf("$%s < R \\le %s$", num(p$near), num(p$narrow)), probe(1, p$narrow)),
                  list(sprintf("$%s < R \\le %s$", num(p$narrow), num(p$narrower)), probe(1, p$narrower)),
                  list(sprintf("$R > %s$", num(p$narrower)), probe(1, 100)))
    data.frame(cond = vapply(cases, `[[`, "", 1),
               text = vapply(cases, function(k) k[[2]][["text"]], ""),
               tone = vapply(cases, function(k) k[[2]][["tone"]], ""), stringsAsFactors = FALSE)
  } else if (identical(fn, assess_cli)) {
    k <- BADGE_PARAMS$cli$trend
    xp <- sub("_n$", "_{n-1}", x)            # the previous month's symbol
    probe <- function(prev, last) {
      a <- fn(data.frame(date = Sys.Date() - 1:0, value = c(prev, last)))
      c(text = a$text, tone = a$tone)
    }
    cases <- list(
      list(sprintf("$%s \\ge %s,\\ %s \\ge %s$", x, num(k), x, xp), probe(k + 1, k + 2)),
      list(sprintf("$%s \\ge %s,\\ %s < %s$", x, num(k), x, xp), probe(k + 2, k + 1)),
      list(sprintf("$%s < %s,\\ %s \\ge %s$", x, num(k), x, xp), probe(k - 2, k - 1)),
      list(sprintf("$%s < %s,\\ %s < %s$", x, num(k), x, xp), probe(k - 1, k - 2)))
    data.frame(cond = vapply(cases, `[[`, "", 1),
               text = vapply(cases, function(c) c[[2]][["text"]], ""),
               tone = vapply(cases, function(c) c[[2]][["tone"]], ""), stringsAsFactors = FALSE)
  } else if (identical(fn, assess_claims)) {
    p <- BADGE_PARAMS$claims
    probe <- function(rise) {                # a 52-week series ending `rise` % above its low
      v <- c(rep(100, p$window - 1), 100 * (1 + rise / 100))
      a <- fn(data.frame(date = Sys.Date() - rev(seq_along(v)) * 7, value = v))
      c(text = a$text, tone = a$tone)
    }
    lo <- sprintf("\\min_{%d}", p$window)
    cases <- list(
      list(sprintf("$100\\,(%s - %s)/%s > %s$", x, lo, lo, num(p$rise)), probe(p$rise + 5)),
      list(sprintf("$100\\,(%s - %s)/%s \\le %s$", x, lo, lo, num(p$rise)), probe(p$rise - 5)))
    data.frame(cond = vapply(cases, `[[`, "", 1),
               text = vapply(cases, function(c) c[[2]][["text"]], ""),
               tone = vapply(cases, function(c) c[[2]][["tone"]], ""), stringsAsFactors = FALSE)
  } else if (identical(fn, assess_copper)) {
    p <- BADGE_PARAMS$copper
    probe <- function(chg) {                 # a series whose change over `lag` obs is `chg` %
      v <- c(rep(100, p$lag), 100 * (1 + chg / 100))
      a <- fn(data.frame(date = Sys.Date() - rev(seq_along(v)) * 30, value = v))
      c(text = a$text, tone = a$tone)
    }
    ch <- sprintf("100\\,(%s / %s - 1)", x, sub("_n$", sprintf("_{n-%d}", p$lag), x))
    cases <- list(
      list(sprintf("$%s > %s$", ch, num(p$band)), probe(p$band + 1)),
      list(sprintf("$%s < -%s$", ch, num(p$band)), probe(-p$band - 1)),
      list(sprintf("$-%s \\le %s \\le %s$", num(p$band), ch, num(p$band)), probe(0)))
    data.frame(cond = vapply(cases, `[[`, "", 1),
               text = vapply(cases, function(c) c[[2]][["text"]], ""),
               tone = vapply(cases, function(c) c[[2]][["tone"]], ""), stringsAsFactors = FALSE)
  } else if (identical(fn, assess_regime)) {
    data.frame(cond = sprintf("$g_t %s 0,\\ m_t %s 0$", ifelse(REGIMES$growth, ">", "\\le"),
                              ifelse(REGIMES$inflation, ">", "\\le")),
               text = REGIMES$name, tone = REGIMES$tone, stringsAsFactors = FALSE)
  } else stop(sprintf("guide: no badge table for '%s' yet", id), call. = FALSE)
  shown <- sub("9999", "<em>year</em>", vapply(seq_len(nrow(rows)), function(i)
    tone_span(rows$text[i], rows$tone[i]), ""), fixed = TRUE)
  c("| Condition | Badge |", "|---|---|", sprintf("| %s | %s |", rows$cond, shown), "")
}

# Expand the directives in a vector of lines; returns the lines and the tile ids seen.
# A tile no longer in the registry (retired) keeps a bare heading; the coverage check
# below reports it as a section for a tile the tab doesn't show.
expand <- function(lines) {
  out <- character(); seen <- character()
  for (ln in lines) {
    if (grepl("^\\{\\{tile ", ln)) {
      id  <- sub("^\\{\\{tile ([a-z0-9_]+).*", "\\1", ln)
      lag <- if (grepl('lag="', ln)) sub('.*lag="([^"]*)".*', "\\1", ln) else NULL
      known <- any(vapply(REGISTRY$series, function(e) identical(e$id, id), logical(1)))
      out <- c(out, if (known) tile_block(id, lag) else c(sprintf("### %s {#%s}", id, id), ""))
      seen <- c(seen, id)
    } else if (grepl("^\\{\\{badge ", ln)) {
      id <- sub("^\\{\\{badge ([a-z0-9_]+).*", "\\1", ln)
      x  <- if (grepl('var="', ln)) sub('.*var="([^"]*)".*', "\\1", ln) else "x_n"
      out <- c(out, badge_table(id, x))
    } else if (grepl("^\\{\\{tab ", ln)) {
      out <- c(out, tab_block(sub("^\\{\\{tab ([a-z0-9_]+).*", "\\1", ln)))
    } else out <- c(out, ln)
  }
  list(lines = out, seen = seen)
}

read_md <- function(path) readLines(path, encoding = "UTF-8", warn = FALSE)

# --- assemble ------------------------------------------------------------------
part1  <- read_md(file.path(GUIDE_DIR, "00-introduction.md"))
part2  <- read_md(file.path(GUIDE_DIR, "10-tabs.md"))
part3  <- read_md(file.path(GUIDE_DIR, "20-tiles.md"))
tiles_written <- character()
gaps <- character()               # coverage problems, one line per tab
for (v in VIEWS) {
  f <- file.path(GUIDE_DIR, "tabs", paste0(v$id, ".md"))
  shown <- shown_ids(v)
  if (!file.exists(f)) {
    message(sprintf("  - %-24s no guide file (%d tiles)", v$title, length(shown)))
    gaps <- c(gaps, sprintf("%s: no guide file %s", v$title, f))
    next
  }
  md  <- read_md(f)
  cut <- grep("^<!-- tiles -->$", md)
  if (length(cut) != 1) stop(sprintf("guide: %s needs one '<!-- tiles -->' line", f), call. = FALSE)
  intro <- expand(md[seq_len(cut - 1)])
  tiles <- expand(md[seq(cut + 1, length(md))])
  part2 <- c(part2, "", intro$lines)
  part3 <- c(part3, "", sprintf("## %s {#tiles-%s}", v$title, v$id), "", tiles$lines)
  missing <- setdiff(shown, tiles$seen); extra <- setdiff(tiles$seen, shown)
  message(sprintf("  + %-24s %d of %d tiles%s%s", v$title, length(intersect(shown, tiles$seen)), length(shown),
                  if (length(missing)) paste0("; missing: ", paste(missing, collapse = ", ")) else "",
                  if (length(extra)) paste0("; not on this tab: ", paste(extra, collapse = ", ")) else ""))
  if (length(missing)) gaps <- c(gaps, sprintf("%s: no section for %s", v$title, paste(missing, collapse = ", ")))
  if (length(extra)) gaps <- c(gaps, sprintf("%s: sections for tiles the tab doesn't show: %s",
                                             v$title, paste(extra, collapse = ", ")))
  tiles_written <- c(tiles_written, tiles$seen)
}
# Coverage: every tile a tab shows has a section, and no section is left for a tile the
# tab doesn't show. A gap stops a local build, so it's caught before a commit; in CI it
# is a warning on the run instead, so the guide never holds back the daily data refresh.
if (length(gaps)) {
  if (nzchar(Sys.getenv("CI"))) {
    cat(sprintf("::warning title=User guide coverage::%s\n", gsub("%", "%25", gaps, fixed = TRUE)), sep = "")
  } else {
    stop("guide: coverage gaps (in CI these only warn):\n  ", paste(gaps, collapse = "\n  "), call. = FALSE)
  }
}
appendix <- unlist(lapply(sort(list.files(GUIDE_DIR, "^9.*[.]md$", full.names = TRUE)),
                          function(f) c(read_md(f), "")))   # a blank line between files
doc <- c(expand(part1)$lines, "", part2, "", part3, "", expand(appendix)$lines)

# --- render --------------------------------------------------------------------
pandoc_bin <- function() {
  cand <- unique(Filter(nzchar, c(Sys.getenv("PANDOC"), Sys.which("pandoc"),
    "/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64/pandoc")))
  cand <- cand[file.exists(cand)]
  if (!length(cand)) stop("guide: pandoc not found (set PANDOC)", call. = FALSE)
  ver <- vapply(cand, function(p) sub("^pandoc(\\.exe)? ", "", system2(p, "--version", stdout = TRUE)[1]), "")
  best <- cand[order(numeric_version(ver), decreasing = TRUE)][1]
  if (numeric_version(max(numeric_version(ver))) < "2.12") stop("guide: pandoc 2.12 or later needed", call. = FALSE)
  best
}

dir.create(file.path(OUT_DIR, "fonts"), recursive = TRUE, showWarnings = FALSE)
tmp <- tempfile(fileext = ".md")
con <- file(tmp, "w", encoding = "UTF-8"); writeLines(doc, con); close(con)
built <- format(Sys.time(), "%Y-%m-%d %H:%M UTC", tz = "UTC")
pandoc <- pandoc_bin()
status <- system2(pandoc, c(shQuote(tmp), "--from", "markdown-implicit_figures", "--to", "html5",
  "--standalone", "--mathml", "--toc", "--toc-depth=3",
  "--strip-comments",                    # the source notes in the Markdown stay out of the page
  "--template", shQuote(file.path(GUIDE_DIR, "assets", "template.html")),
  "--metadata", shQuote("pagetitle=User guide - Global Macro Cockpit"),
  "--variable", shQuote(paste0("built=", built)),
  "--variable", shQuote(paste0("version=", format(Sys.time(), "%Y%m%d%H%M%S"))),
  "--output", shQuote(file.path(OUT_DIR, "index.html"))))
if (status != 0) stop("guide: pandoc failed", call. = FALSE)
invisible(file.copy(file.path(GUIDE_DIR, "assets", "guide.css"), OUT_DIR, overwrite = TRUE))
invisible(file.copy(list.files(file.path(GUIDE_DIR, "assets", "fonts"), full.names = TRUE),
                    file.path(OUT_DIR, "fonts"), overwrite = TRUE))
message(sprintf("Wrote %s with %s (%d tile sections).", file.path(OUT_DIR, "index.html"),
                system2(pandoc, "--version", stdout = TRUE)[1], length(tiles_written)))
