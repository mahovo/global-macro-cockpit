# Global Macro Cockpit — Source Catalog & Design Notes

*An investor-oriented, leading-indicator-first dashboard. Companion to `sources.yaml` (the machine-readable source registry for the ingestion layer).*

> **Editor's note (publication).** This is the original design brief the dashboard was built from, kept for context. Where it mentions scraping (for example headline prints of licensed indicators) or other tooling, those were options under consideration, not what was implemented: the project uses official APIs and downloads only, shows licensed data as links, and republishes only data whose licences permit it (see `instructions/data_licenses.csv`). DBnomics, described below as a backbone, was later replaced by the official Eurostat, ECB and IMF APIs for the series shown, after its copies of those datasets stopped updating (September 2026).

---

## 0. How to read this

- **Class** tags every indicator as **L** (leading), **C** (coincident), or **Lag** (lagging). The dashboard's emphasis is L, with C/Lag included only to confirm or contextualize.
- **Access** says *how* to pull it. The two backbones are `fred` and `dbnomics` (see §4); everything else is a fallback or a source-of-truth.
- Exact series IDs and endpoints below are accurate to the best of current knowledge but **should be validated against live provider docs at build time** — Claude Code should treat the registry as a starting manifest and verify each series resolves before wiring it in.

---

## 1. Design principle: organize by *transmission*, not by country

The most useful framing for an investor isn't "US / EU / Asia" — it's the **causal chain of the cycle**, because that's where leads and lags live:

> financial conditions & liquidity → credit & risk appetite → orders/sentiment → activity → labor → inflation → policy → (back to conditions)

Each view below is a link in that chain. Money/credit and the yield curve lead by quarters; orders/PMIs/claims lead by weeks-to-months; activity and inflation are coincident-to-lagging; policy responds with a lag and feeds back. Laying the dashboard out left-to-right along this chain makes the lead/lag structure legible at a glance.

### The cockpit (the layout metaphor)

The transmission chain says *what leads what*. The **cockpit** says *where each thing belongs on screen* and, crucially, *how to read it* — because an investor, like a driver, navigates a system that is forecastable but not deterministic: other agents have agency, accidents happen, the weather only half-cooperates. The dashboard is the windscreen-plus-mirrors view that lets you choose a safe speed for the next curve, not a crystal ball.

| Cockpit zone | What it answers | Maps to views |
|---|---|---|
| **Windscreen** (main forward view) | Where are we heading? Is there a curve ahead? | Cycle & momentum, financial conditions, credit, rates, inflation expectations, labor leads (F, B, C, D, E, G) |
| **Heads-up display / warning lights** | What needs attention *now* — brake or turn? | Recession Watch (A); threshold breaches; staleness flags |
| **Speedometer / tachometer** | How fast are we going *relative to safe speed*? | **Bubbles / Froth / Fragility (N)** |
| **Side windows** (peripheral; other drivers) | Who else is on the road, and how are they behaving? | Markets & sentiment (K); positioning; cross-asset; geopolitics overlay (M) |
| **Mirrors** (behind us / catching up) | What already happened; is anything gaining on us? | Activity & inflation realizations; labor levels; household debt (the lagging rows across F, E, G, J) |
| **Weather / road surface** | Conditions we adapt to but can't control | Regime overlays: inflation regime, policy stance, liquidity tide, uncertainty (M) |
| **GPS / navigator** | The base-case route and ETA, with error bands | Nowcasts: GDPNow, consensus path (F) |

The single reading rule the metaphor enforces, which matters most for the new bubbles view: **the speedometer is not a clock.** A froth gauge tells you your *speed*, not the *time of the crash* — see View N and §3.

---

## 2. Proposed views

### View A — Recession Watch (headline gauges)
The "are we okay?" panel. A handful of the most battle-tested signals, up top.

| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| Yield curve 10y–3m | L | daily | FRED `T10Y3M` | fred |
| Yield curve 10y–2y | L | daily | FRED `T10Y2Y` | fred |
| NY Fed recession probability (curve-based) | L | monthly | NY Fed | csv/api |
| Sahm rule (real-time) | C-fast | monthly | FRED `SAHMREALTIME` | fred |
| Smoothed recession probabilities (Chauvet–Piger) | C | monthly | FRED `RECPROUSM156N` | fred |
| HY credit spread (OAS) | L | daily | FRED `BAMLH0A0HYM2` | fred |
| Chicago Fed Financial Conditions (NFCI) | L | weekly | FRED `NFCI` | fred |

### View B — Financial Conditions & Liquidity
Leads everything else; this is where an investor wants to look first.

| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| NFCI / Adjusted NFCI | L | weekly | FRED `NFCI`, `ANFCI` | fred |
| St. Louis Fed Financial Stress Index | L | weekly | FRED `STLFSI4` | fred |
| Fed balance sheet (total assets) | L | weekly | FRED `WALCL` | fred |
| Treasury General Account | L | weekly | FRED `WTREGEN` | fred |
| Overnight reverse repo (RRP) | L | daily | FRED `RRPONTSYD` | fred |
| **Net liquidity** = WALCL − WTREGEN − RRP | L | derived | — | transform |
| M2 money supply | L | monthly | FRED `M2SL` | fred |
| SLOOS — bank lending standards (C&I, tightening net %) | L | quarterly | Fed SLOOS | fred (`DRTSCILM` etc.) |

### View C — Credit & Risk Spreads
| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| US HY OAS | L | daily | FRED `BAMLH0A0HYM2` | fred |
| US IG OAS | L | daily | FRED `BAMLC0A0CM` | fred |
| HY − IG (compression/decompression) | L | derived | — | transform |
| CCC & lower OAS (deep-risk tail) | L | daily | FRED `BAMLH0A3HYCEY`/OAS variant | fred |
| EM sovereign spread (proxy) | L | daily | EMB/EMBI ETF px (proxy) | market |
| Bond volatility (MOVE) | L | daily | *proprietary (ICE)* — proxy via rates vol | manual/proxy |

### View D — Rates & Monetary Policy
| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| Treasury par yields (3m/2y/10y/30y) | L | daily | Treasury fiscaldata; FRED `DGS3MO`,`DGS2`,`DGS10`,`DGS30` | fred / api |
| Effective fed funds rate | C | daily | FRED `EFFR` | fred |
| Implied policy path (fed funds futures) | L | daily | CME (FedWatch) | manual/scrape |
| ECB / BoE / BoJ policy rates | C | event | DBnomics (ECB, etc.) | dbnomics |
| Central bank balance sheets (ECB, BoJ) | L | weekly/monthly | DBnomics | dbnomics |

### View E — Inflation & Price Expectations
Market-implied expectations are the leading part here; realized CPI/PCE is coincident-to-lagging.

| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| 5y / 10y TIPS breakevens | L | daily | FRED `T5YIE`, `T10YIE` | fred |
| 5y5y forward breakeven | L | daily | FRED `T5YIFR` | fred |
| UMich 1y inflation expectations | L | monthly | FRED `MICH` | fred |
| NY Fed Survey of Consumer Expectations | L | monthly | NY Fed | csv/api |
| CPI / core CPI | C/Lag | monthly | BLS; FRED `CPIAUCSL`,`CPILFESL` | fred / bls |
| PCE / core PCE (Fed's target) | C/Lag | monthly | BEA; FRED `PCEPI`,`PCEPILFE` | fred / bea |
| PPI (pipeline) | L | monthly | BLS; FRED `PPIFIS` | fred / bls |
| Import/export prices | L | monthly | BLS | bls |

### View F — Cycle & Growth Momentum
| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| OECD Composite Leading Indicators (CLI) | L | monthly | OECD; DBnomics | dbnomics / sdmx |
| Global mfg & services PMI (new orders subindex) | L | monthly | *S&P Global (proprietary)* — headline only | manual |
| ISM mfg & services (new orders) | L | monthly | *ISM (proprietary)* — headline only | manual |
| Conference Board LEI | L | monthly | *Conference Board (proprietary)* | manual |
| Regional Fed surveys (Empire, Philly, Dallas, KC, Richmond) | L | monthly | FRED (`GACDISA066MSFRBNY` etc.) | fred |
| Atlanta Fed GDPNow (nowcast) | C-nowcast | ~weekly | Atlanta Fed | csv/api |
| Industrial production / capacity util | C | monthly | FRED `INDPRO`, `TCU` | fred |
| Real GDP / GDP growth | C/Lag | quarterly | BEA; FRED `GDPC1`,`A191RL1Q225SBEA` | fred / bea |

### View G — Labor Market
| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| Initial jobless claims | L | **weekly** | FRED `ICSA` | fred |
| Continuing claims | L | weekly | FRED `CCSA` | fred |
| JOLTS quits rate (leading) | L | monthly | FRED `JTSQUR` | fred |
| JOLTS openings | L | monthly | FRED `JTSJOL` | fred |
| Temp help services employment | L | monthly | FRED `TEMPHELPS` | fred |
| Average weekly hours (mfg/overtime) | L | monthly | FRED `AWHMAN` | fred |
| Nonfarm payrolls / unemployment | C | monthly | BLS; FRED `PAYEMS`,`UNRATE` | fred / bls |

### View H — Global Trade & Shipping
| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| CPB World Trade Monitor (world trade volume + IP) | L | monthly | CPB Netherlands | csv |
| Baltic Dry Index | L | daily | *proprietary (Baltic Exchange)* — proxy/scrape | manual/proxy |
| Container freight (Freightos FBX / Drewry WCI) | L | weekly | partly public | scrape/manual |
| PMI export orders subindex | L | monthly | *S&P Global* — headline | manual |
| Korea / Taiwan exports (global tech-cycle tell) | L | monthly | DBnomics (national sources) | dbnomics |

### View I — Energy & Commodities
| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| Brent / WTI | L | daily | EIA; FRED `DCOILBRENTEU`,`DCOILWTICO` | fred / eia |
| US crude & product inventories, SPR | L | weekly | EIA (Weekly Petroleum Status) | eia |
| US production / STEO forecast | L | weekly/monthly | EIA | eia |
| Henry Hub nat gas | L | daily | FRED `DHHNGSP` | fred |
| Copper ("Dr Copper") | L | monthly/daily | FRED `PCOPPUSDM`; market for daily | fred / market |
| **Copper/gold ratio** (growth/reflation proxy) | L | derived | — | transform |
| Gold | C | daily | FRED `IR14270`/LBMA; market | fred / market |
| Broad commodity index (BCOM / GSCI proxy) | L | daily | market | market |

### View J — Consumer & Housing
| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| UMich consumer sentiment | L | monthly | FRED `UMCSENT` (1-mo delay) / UMich | fred |
| Conference Board consumer confidence | L | monthly | *proprietary* — headline | manual |
| Building permits (housing/cycle lead) | L | monthly | FRED `PERMIT` | fred |
| Housing starts | L | monthly | FRED `HOUST` | fred |
| NAHB homebuilder sentiment | L | monthly | *NAHB* — headline | manual |
| MBA mortgage applications | L | weekly | *MBA* — headline | manual |
| Retail sales (ex-autos, ex-gas control group) | C | monthly | Census; FRED `RSAFS`,`RRSFS` | fred / census |
| Household debt & delinquency | Lag | quarterly | NY Fed HHDC | csv |

### View K — Markets & Sentiment
| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| Equity indices (S&P 500, global) | C | daily | FRED `SP500` (10y); Stooq/yfinance for full history | fred / market |
| VIX | L | daily | FRED `VIXCLS` | fred |
| Broad trade-weighted USD | L | daily | FRED `DTWEXBGS` | fred |
| AAII bull-bear / put-call | L | weekly | AAII / CBOE | scrape/manual |
| Crypto (BTC) as risk-on proxy *(optional)* | L | daily | market | market |

### View L — China & Cyclical Leaders
China's credit cycle leads the *global* industrial cycle by ~6–12 months — arguably the single most valuable non-US view.

| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| **China credit impulse** (Δ in TSF/aggregate financing as % of GDP) | L | monthly | PBoC TSF + nominal GDP → derive | dbnomics + transform |
| Caixin / official PMI | L | monthly | *S&P Global / NBS* — headline | manual / dbnomics |
| China IP / retail sales / FAI | C | monthly | NBS; DBnomics | dbnomics |
| BIS credit-to-GDP gap (global early-warning) | L | quarterly | BIS; DBnomics | dbnomics |
| Semiconductor billings (SIA, tech cycle) | L | monthly | *SIA* — headline | manual |

### View M — Uncertainty & Geopolitical Risk (overlay)
A thin overlay strip that annotates spikes across the other panels.

| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| Economic Policy Uncertainty (US, daily) | L | daily | FRED `USEPUINDXD` | fred |
| Global EPU | L | monthly | FRED `GEPUCURRENT`; policyuncertainty.com | fred / csv |
| Geopolitical Risk Index (GPR, Caldara–Iacoviello) | L | monthly/daily | matteoiacoviello.com | csv |

### View N — Bubbles / Froth / Fragility (the speedometer)

**Read this view as *speed relative to road conditions*, not as a countdown.** Bubble gauges do not time the pop — timing is genuinely uncertain (fat tails; other agents have agency). What they measure is **how little margin of safety is left**: at a high CAPE with record margin debt, the system is "driving fast," so any ordinary perturbation that would otherwise be recoverable becomes convex to the downside. The actionable read is the *interaction with the windscreen*: high speed on a straight road (froth + healthy leads) is elevated-but-not-imminent; high speed into a curve (froth + deteriorating financial conditions/credit) is the brake signal. Pair every gauge here with View A/B.

Group the dial into four sub-bands:

**Equity valuation (the speedometer dial)**

| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| Shiller CAPE (PE10) | fragility | monthly | Shiller (shillerdata.com); multpl | csv/scrape |
| Excess CAPE Yield (ECY) = 1/CAPE − real 10y | fragility | monthly | derive (CAPE, `DFII10`) | transform |
| Buffett indicator = Wilshire 5000 / GDP | fragility | monthly | FRED `WILL5000PRFC` ÷ `GDP` | fred + transform |
| Tobin's Q (nonfin. corp) | fragility | quarterly | Fed Z.1 (FRED) | fred + transform |
| Equity risk premium (earnings yield − real yield) | fragility | monthly | derive | transform |

**Leverage & speculation fuel (how hard the pedal is pressed)**

| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| FINRA margin debt + YoY change | leading | monthly | FINRA Rule 4521 stats | csv |
| Margin debt / GDP (or / market cap) | fragility | monthly | derive | transform |
| NAAIM Exposure Index (active mgr equity exposure) | leading | weekly | naaim.org | scrape |
| Real 10y yield (cheap-money fuel) | overlay | daily | FRED `DFII10` | fred |
| HY OAS at extreme tights (complacency) | leading | daily | FRED `BAMLH0A0HYM2` (cross-ref C) | fred |

**Behavioral / mania structure (passengers egging you on)**

| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| Crypto total market cap / BTC (speculation barometer) | leading | daily | CoinGecko API (free) | api |
| Equal-weight vs cap-weight (RSP/SPY) — concentration proxy | leading | daily | derive from prices | market/transform |
| Breadth: % S&P > 200-dma; new highs − lows | leading | daily | derive from prices | market/transform |
| Google Trends speculative search interest | leading | weekly | Google Trends (pytrends) | api |
| IPO / SPAC issuance & first-day pops | leading | monthly | *proprietary* — proxy via Renaissance IPO ETF | manual/proxy |

**Housing & systemic credit (same physics, different vehicle)**

| Indicator | Class | Freq | Source | Access |
|---|---|---|---|---|
| Case-Shiller HPI & price/rent ratio | fragility | monthly | FRED `CSUSHPINSA` ÷ rent `CUSR0000SEHA` | fred + transform |
| OECD house price-to-income / price-to-rent | fragility | quarterly | OECD via DBnomics | dbnomics |
| Household debt-service ratio | fragility | quarterly | FRED `TDSP` | fred |
| BIS credit-to-GDP gap (financial-cycle early warning) | leading | quarterly | BIS via DBnomics (cross-ref L) | dbnomics |

A useful summary tile: a **froth composite** = mean z-score of {CAPE, margin-debt/GDP, −ECY, concentration proxy} vs. own history. Treat it as a fragility thermometer, never an entry/exit trigger.

---

## 3. Signature signals (the gauges that earn the top row)

If you want a small set of composites that summarize the whole board, these are the investor classics:

1. **Curve recession probability + Sahm rule** — the recession dyad (one leads, one confirms early).
2. **NFCI / net liquidity** — is policy a tailwind or headwind for risk assets right now.
3. **HY OAS** — the market's real-time credit-stress thermometer.
4. **Global PMI new orders / OECD CLI** — cycle direction.
5. **China credit impulse** — the global cyclical pulse, 2–3 quarters ahead.
6. **Copper/gold ratio + 5y5y breakeven** — growth/reflation vs. deflation regime.
7. **Froth composite (CAPE + margin-debt/GDP + concentration)** — the speedometer: how little margin of safety is left, read *against* the windscreen rather than alone.

A nice pattern: render each as a z-score vs. its own history (or percentile), so heterogeneous units become comparable and "how stretched is this" is immediate.

---

## 4. Data-access strategy

**Tier 0 — backbone (do ~80% of the work here):**
- **FRED API** (St. Louis Fed). Free key, ~800k series, mirrors BEA / BLS / Fed / NY Fed / Census / ICE BofA credit spreads / Treasury / UMich (delayed). Most US series *and* VIX, credit spreads, the curve, EPU live here — so you avoid brittle market-price APIs for a lot of the risk panel. R: `fredr`. Python: `fredapi`. **Use ALFRED / the `realtime_start`/`realtime_end` params for point-in-time vintages** — essential if you ever backtest a leading-indicator signal without lookahead bias.
- **DBnomics** (Banque de France / CEPREMAP). Free, **no key**, unified Web API over Eurostat, ECB, BIS, IMF, OECD, World Bank + many national sources. Use for everything non-US and for international comparability. R: `rdbnomics` (CRAN) — fits your stack. Python: `dbnomics`.

**Tier 1 — direct official APIs** (source-of-truth, or where FRED/DBnomics lag):
BEA, BLS, EIA, US Treasury `fiscaldata`, Census, ECB SDW (SDMX), Eurostat (SDMX/REST), OECD (SDMX), World Bank (REST), IMF (SDMX). Each has free, documented endpoints; some need a free key (BLS, EIA, BEA).

**Tier 2 — market prices** (only where FRED can't): **Stooq** (free CSV, global EOD — the underrated workhorse), `yfinance` (works but unofficial and rate-limited — wrap with backoff), or a keyed free tier (Alpha Vantage, Financial Modeling Prep, Finnhub, Tiingo, Twelve Data) as fallback.

**Tier 3 — proprietary / paywalled (architect around these):**
S&P Global PMIs incl. Caixin, ISM, Conference Board LEI & confidence, NAHB, MBA, JPM EMBI, ICE MOVE, Baltic Dry (real-time), Drewry, SIA. You can scrape the **headline print** from release pages, but there's no clean free historical API without a license. Treat each as a **`manual`/`headline` tile** (a small ingester that scrapes the latest number on release day) or substitute a free proxy. Flag these visually so you never mistake a stale headline for a live feed.

---

## 5. Ingestion architecture notes (for Claude Code)

Make the pipeline **registry-driven**: `sources.yaml` is the single source of truth; the ingestion layer iterates it and dispatches on the `access` field. Suggested shape:

1. **Fetchers**, one per `access` type: `fred`, `dbnomics`, `sdmx`, `api`, `csv`, `scrape`, `manual`. Each takes a registry entry, returns a normalized frame.
2. **Normalize to tidy long format**: `date, series_id, value, provider, theme, indicator_class, frequency, units, vintage`. Keep native frequency; align in a view layer, never on ingest.
3. **Storage**: DuckDB (columnar, plays beautifully with R `arrow`/`duckdb` and Python; great for time-series slicing) or SQLite for simplicity. Cache raw API responses separately so you can re-normalize without re-fetching.
4. **Latest vintage only** (monitoring, not backtesting): fetch the current print; no ALFRED/vintage plumbing here (backtesting is out of scope for this project). The store is therefore a **cache, not a warehouse**: its job is to make views fast and absorb rate limits, keyed by `series_id` with a `fetched_at` timestamp.
5. **Transform layer**: YoY/MoM/annualized, z-scores & percentiles vs. own history, diffusion indexes, leads/lags, plus the derived composites (net liquidity, copper/gold, HY−IG, China credit impulse).
6. **Cache TTL per `frequency`** (this replaces any cron schedule under fetch-on-view): a daily series stays fresh for hours, weekly for ~a day, monthly/quarterly for days. Drive the TTL from the registry `frequency` field; optionally shorten it inside known release windows (BLS/BEA/EIA publish on fixed calendars).
7. **Secrets**: keys in env vars (`FRED_API_KEY`, `BLS_API_KEY`, `EIA_API_KEY`, `BEA_API_KEY`); never commit `.env`. DBnomics/Stooq need none.
8. **Resilience**: retries with backoff, and a staleness flag per series (last-successful-fetch vs. expected cadence) surfaced on the dashboard so a silently dead feed is obvious.

### Fetch-on-view, done right

Fetch-on-view does **not** mean re-hitting every API on every open — that would be slow and would trip the tight free tiers. It means **lazy, cache-backed loading**:

- **Read-through cache + TTL.** On open, serve any series within its frequency-based TTL instantly; only fetch the stale ones. The cold (first) open is the only full fetch; repeat opens are warm.
- **Stale-while-revalidate.** Past TTL, render the cached value immediately with a subtle "updating…" marker, refresh in the background, swap in the fresh value when it lands. This is what makes fetch-on-view feel instant while staying current, and it reuses the staleness flag above.
- **Per-provider rate limiter + bounded concurrency.** Wrap each provider in a token bucket at its documented limit; fetch a view's stale series in parallel up to that cap so wall-clock ≈ the slowest provider, not the sum. Single-flight (dedupe in-flight requests) if the dashboard is ever multi-user. (R: `httr2::req_perform_parallel` + `future`; Python: `asyncio`/`httpx`.)
- **Batch where the API allows.** BLS v2 takes up to ~50 series per request; many SDMX endpoints accept multi-key queries. One call per view beats one per series.
- **Resolve transforms as a small DAG.** A `transform` entry's `inputs` are fetched/read-from-cache first, then the `formula` evaluates (net liquidity, copper/gold, ECY, Buffett indicator, froth composite). Cache the computed result too.
- **Degrade per tile, not per view.** If one provider is throttled or down, render the rest and mark that single tile stale/unavailable — never fail the whole view.
- **Keep the tight tiers off the interactive path.** Alpha Vantage (25/day, 5/min) and Google Trends (unofficial, aggressive blocking) can't survive fetch-on-view — give them long TTLs and refresh out-of-band. CoinGecko's public tier is unstable (5–15/min); register the free Demo key for a steady 30/min, or use Finnhub (60/min). FRED (~120/min) and DBnomics (no key) should carry the interactive load.
- **Proprietary/headline tiles are inherently cache-backed.** PMI/ISM/LEI/NAHB/MBA/Baltic Dry/IPO-SPAC update only on release and can't be scraped on every open. Update them out-of-band (tiny triggered scraper or manual entry) into the same cache; the view reads the last value with its `as-of` date. So the system is a **hybrid**: fetch-on-view for API feeds, write-through cache for the manual ones.
- **Optional: prefetch the landing view** on app start so the first screen is already warm.

If you build in R given your stack: `fredr`, `rdbnomics`, `eurostat`, `OECD`, `wbstats`, `imf.data`/`imfr`, `eia`, `bea.R`, and `tidyquant`/`quantmod` (Stooq, Yahoo) cover nearly the whole registry.

---

## 6. Open design questions (to refine the views)

These are the choices that would most change the layout — worth deciding before Claude Code scaffolds:

- **Geographic scope**: US-centric with a global overlay, or genuinely multi-region with parallel panels per bloc (US / euro area / China)?
- **Proprietary tolerance**: are you willing to scrape PMI/ISM/LEI headlines (fragile, but they're top-tier leads), or stay strictly to free-API series and accept the gaps?
- **Backtest ambition**: *settled — monitoring only.* No vintage/ALFRED plumbing needed here; point-in-time data belongs to separate backtesting work, outside this project. The ingestion layer can fetch latest-vintage only, which simplifies caching considerably.
- **Refresh model**: *settled — fetch-on-view*, implemented as a lazy frequency-TTL cache with stale-while-revalidate (see §5). No cron warehouse; the tight free tiers and proprietary headline tiles are kept off the interactive path.
