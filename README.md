# Global Macro Cockpit

*Co-written by Claude Code Opus 5*
*Directed by Martin Hoshi Vognsen*

A leading-indicator-first macro dashboard. It lays out around 90 economic and
financial series along the transmission chain of the business cycle — financial
conditions → credit → orders → activity → labour → inflation — with one tile per
indicator.

**Live, static public edition:** https://mahovo.github.io/global-macro-cockpit/

> The public site is a static, daily-rebuilt snapshot of an interactive dashboard
> developed for private use. It is deliberately limited to comply with data-licensing
> terms and security requirements: indicators whose licences do not permit
> republication are shown as links only, and live refresh and custom date ranges are
> not available.

## What it shows

- **11 tabs** along the transmission chain: Recession Watch, Conditions & Liquidity,
  Credit & Rates, Inflation, Cycle & Growth, Labor, Trade & Commodities, Consumer &
  Housing, Markets & Uncertainty, China & Leaders, Bubbles / Froth. Each tab is tagged
  with its *cockpit zone* (windscreen, warning lights, speedometer, …).
- **One tile per series**: latest value, change vs the prior observation, a mini-chart
  with a threshold line, a plain-English cycle-read badge, a staleness dot, a source
  credit, and an ⓘ note on how to read it and why it matters.
- **Display modes**: level, z-score, or percentile against the series' own history, so
  very different series become comparable. The badge always reads the level.
- **Multi-region layer**: euro area and members, UK, Japan, Canada, China, India, Korea
  and Brazil — government bond yields, short rates, OECD leading indicators, HICP/CPI
  and unemployment.
- **Recession-watch snapshot** in the sidebar.

## Two editions

| | Local app (`app.R`) | Public site (`scripts/build_site.R`) |
|---|---|---|
| Runs as | Shiny app on your machine | Static HTML on GitHub Pages |
| Data | Fetched live when a tab opens, cached | Fetched by GitHub Actions on push to `main` and daily |
| Controls | History start date, refresh, display mode | Display mode, zoom (1Y / 3Y / 5Y) |
| Copyrighted "pre-approval" series | Shown (for your personal use) | Link only |

## Run it locally

Requires R ≥ 4.4 and the packages listed in `DESCRIPTION`:

```r
install.packages(c("shiny", "bslib", "dplyr", "ggplot2", "plotly", "httr2", "readr",
                   "tibble", "jsonlite", "yaml", "htmltools", "htmlwidgets"))
```

A free [FRED API key](https://fredaccount.stlouisfed.org) is recommended. Put it in
`~/.Renviron` (never in the repository):

```
FRED_API_KEY=your-key
```

Then, from the project folder:

```bash
Rscript -e 'shiny::runApp(launch.browser = TRUE)'
```

Without a key, FRED data comes from FRED's public graph-CSV download instead, which is
fine for occasional personal use.

The local app is built for single-user use on your own machine. It isn't hardened for
public hosting — for example, *Refresh* clears the shared cache and there is no rate
limiting. If you run it, you are responsible for respecting each data provider's terms.
In particular, the S&P 500, the ICE BofA credit spreads and the S&P Cotality
Case-Shiller index are copyrighted: fine to view for personal use, not to republish.

To build the static site locally:

```bash
Rscript scripts/build_site.R   # writes _site/
```

## How the public site is built

`.github/workflows/pages.yml` runs on every push to `main`, daily at 06:17 UTC, and on
demand. It installs R and the dependencies, runs `scripts/build_site.R` with the
`FRED_API_KEY` repository secret, and deploys `_site/` to GitHub Pages. The build:

1. reads the series registry and `instructions/data_licenses.csv`;
2. fetches only series whose licence permits republication — anything not listed in
   the licence table is shown as a link, never as data;
3. stops without deploying if fewer than 90 % of those series resolve, so the last good
   site stays live;
4. renders the same tiles as the local app into one static page with interactive
   plotly charts.

GitHub pauses scheduled workflows in public repositories after 60 days without activity;
if that happens, re-enable the workflow from the Actions tab.

## Data and licences

- **Official APIs and downloads only**: FRED, OECD, Eurostat, the ECB Data Portal, the IMF
  data API, the Bank of England Database, the ONS and the Bank of Japan's time-series API.
  No scraping.
- **`instructions/data_licenses.csv`** records the licence class and credit line of every
  displayed series, checked against FRED's copyright status and the providers' terms:
  - FRED public-domain and citation-required series are republished as
    "Source: … via FRED";
  - OECD and Eurostat data are used under CC BY 4.0; the ECB is cited as the source with
    modifications stated; IMF data is credited per the IMF's data terms;
  - Bank of England (SONIA) and ONS data are used under the Open Government Licence v3.0
    with their attribution statements; Bank of Japan data are credited to the Bank, and the
    site shows the credit line its API terms ask for. Third-party benchmarks such as Euribor
    are not republished;
  - FRED "pre-approval required" series — S&P 500, ICE BofA high-yield and
    investment-grade spreads (and HY − IG), S&P Cotality Case-Shiller — are link-only on
    the public site.
- **`scripts/audit_licenses.R`** re-checks FRED's copyright status for the table (needs
  `FRED_API_KEY`) and reports differences for review; it never edits the table.
- Licensed, headline-only indicators (PMIs, ISM, LEI, NAHB, MBA, Baltic Dry, MOVE,
  IPO/SPAC) are linked, never fetched.
- This product uses the FRED® API but is not endorsed or certified by the Federal Reserve
  Bank of St. Louis.

The **code** is MIT-licensed (see `LICENSE`). The **data** is not covered by that licence:
it remains under each provider's terms.

**Not investment advice.** For information and education only; no warranty of accuracy,
completeness or timeliness.

## Project layout

```
app.R                        local Shiny app (live edition)
scripts/
  build_site.R               static public edition -> _site/
  validate_registry.R        checks which registry series resolve -> registry_coverage.csv
  audit_licenses.R           re-checks FRED copyright status of the licence table
R/
  registry.R                 loads the YAML registry; access dispatch; cache TTL by frequency
  fetch.R                    fetch_series(): provider dispatch -> tidy long; curation overrides
  transforms.R               derived series from whitelisted FRED arithmetic (LOCF alignment)
  fetchers/                  _http.R, _sdmx.R, fred.R, fred_api.R, oecd.R, eurostat.R, ecb.R,
                             imf.R, boe.R, ons.R, boj.R, dbnomics.R
  assess.R                   per-series cycle-read thresholds
  display.R                  titles, units, reference lines, formatting, staleness, modes
  tiles.R                    cards, popovers and charts shared by both editions
  licensing.R                publish policy and attributions from data_licenses.csv
  views.R                    the 11 tabs
  help.R                     panel and card help text
  utils_cache.R              on-disk read-through cache
instructions/
  sources.yaml               original series registry
  sources_global.yaml        multi-region additions
  data_licenses.csv          licence class and credit per displayed series
  registry_coverage.csv      generated resolution report
  global-macro-cockpit.md    the original design brief
.github/workflows/pages.yml  build and deploy to GitHub Pages
```

## Adding a series

1. Add it to `instructions/sources_global.yaml` and run `Rscript scripts/validate_registry.R`.
2. Give it a title, unit and reference line in `R/display.R`, a cycle read in
   `R/assess.R`, and help text in `R/help.R`.
3. Add a row to `instructions/data_licenses.csv` after checking its licence. Until it has
   one, the public site shows it as a link only.

## How this was built

Directed by Martin Hoshi Vognsen and co-written with Claude Code, working from the design
brief in `instructions/global-macro-cockpit.md`: the registry-driven ingestion layer, the
multi-region expansion, the licence audit and the static GitHub Pages build were planned
and implemented in conversation.
