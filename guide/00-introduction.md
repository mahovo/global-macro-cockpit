<!-- Part I. Every statement is sourced; see .claude/guide_checklist.md. Sources:
     instructions/global-macro-cockpit.md (design brief), R/views.R (tabs and zones),
     R/display.R (modes, staleness), R/tiles.R (tile anatomy), R/assess.R (badges), R/help.R
     (tab notes), R/licensing.R and instructions/data_licenses.csv (publication),
     scripts/build_site.R, app.R and .github/workflows/pages.yml (the two editions),
     registry and registry_coverage.csv (tile counts by class, 2026-10-07). -->

# Part I · How the dashboard works {#part-intro}

The Global Macro Cockpit is a leading-indicator-first dashboard of the business cycle for
the United States and the main global economies. It has 109 tiles on 11 tabs: 98 data
series shown on the public site, 5 licensed series shown there as links, and 6 manual
tiles. This guide explains how it is built, what each tab and tile shows, how every
number is computed and how each indicator's publisher and its history suggest reading
it.

The guide is written for readers who know the basics of macroeconomics and markets.
Terms are defined where they first matter; the formulas are collected in
[Appendix A](#appendix-formulas). Nothing here is investment advice.

## The idea: follow the transmission chain {#idea}

The dashboard is organised by **transmission** rather than by country. Its design brief
describes the chain along which a change in financial conditions works its way through
the economy:

<p class="note">financial conditions and liquidity → credit and risk appetite → orders and
sentiment → activity → labour → inflation → policy → back to financial conditions</p>

The brief's premise is that leads and lags live along this chain: money, credit and the
yield curve lead by quarters; orders, surveys and jobless claims by weeks to months;
activity and inflation are coincident to lagging; policy responds with a lag and feeds
back into conditions. The tabs follow the chain from left to right. For how far each
indicator has actually led in its own history, see its section in Part III.

Each tile carries an **indicator class**, shown in its header. In the brief's words the
emphasis is on *leading* indicators, with *coincident* and *lagging* ones included to
confirm or give context. Of the 109 tiles, 73 are tagged leading, 23 coincident and 5
lagging; the remaining 8 carry the tags fragility (3), overlay (3) and derived (2).

## The cockpit {#cockpit}

The second organising idea in the brief is a car's cockpit, which says how to read each
group. The brief describes the economy, like a road, as forecastable but not
deterministic, and the dashboard as a view that helps choose a safe speed for the next
bend rather than a crystal ball. Each tab is assigned to a zone (`R/views.R`); the
questions are the brief's:

| Zone | Question it answers | Tabs |
|---|---|---|
| Warning lights | Does something need attention now? | Recession Watch |
| Windscreen | Where are we heading; is there a bend ahead? | Conditions & Liquidity, Credit & Rates, Inflation, Cycle & Growth, Labor, Trade & Commodities (in part) |
| Weather | Conditions to adapt to but not control | Inflation (with the windscreen) |
| GPS | Where in the cycle are we? | Cycle & Growth (with the windscreen) |
| Mirrors | What has already happened, and what is catching up? | Trade & Commodities, Consumer & Housing |
| Side windows | What are the other drivers doing? | Markets & Uncertainty, China & Leaders |
| Speedometer | How fast are we going relative to a safe speed? | Bubbles / Froth |

The brief's reading rule for the speedometer: **the speedometer is not a clock.** A froth
gauge tells you the speed, not the time of a crash, and the brief says to read it against
the windscreen rather than alone.

## The two editions {#editions}

The same code produces two editions.

- **The local app** (R Shiny) is the private, live edition. It fetches every series,
  including licensed ones, lets you choose the start of the history shown ("Show history
  since", three years back by default) and refetches when you click *Refresh data*.
- **The public site** is a static snapshot rebuilt by a scheduled job every day at
  06:17 UTC and on every change to the code. It shows the last five years of each series with 1-, 3- and 5-year
  zoom buttons (3 years by default); the growth and inflation regime tiles carry their
  history from 1960. Series whose licences don't allow republication appear as link-only
  tiles that point to the provider (see [Data and licences](#licences)).

## Anatomy of a tile {#tile-anatomy}

Every data tile has the same parts, top to bottom:

1. **Title** in the form "name — zone" where a zone is needed (for example
   *10Y yield — Germany*).
2. **Badge** (where one exists): a short verdict on the latest value. The sidebar's
   legend gives the colours as <span class="tone good">good</span> on track,
   <span class="tone warn">warn</span> caution and <span class="tone bad">bad</span>
   recession signal; a few badges are <span class="tone neutral">neutral</span> grey.
   See [Badges](#badges).
3. **ⓘ** opens a short note on how to read the tile; this guide is the long version.
4. **Headline value** in the tile's unit, then the **change versus the prior
   observation** with an arrow. The arrow's colour shows direction only (green up, red
   down), not whether the move is good news: a rising Sahm rule gets a green arrow.
5. **The date of the latest observation** with a **freshness dot**.
6. **Mini-chart** with a **reference line** where the dashboard sets one (for example 0
   for the yield curves, 100 for the OECD leading indicators, 2 for most inflation rates).
7. **Footer**: in the app, the provider, series code and frequency; on the public site,
   the source credit with a link to the source.

The freshness dot turns amber when the latest observation is older than the series'
frequency would suggest:

| Frequency | Amber after |
|---|---|
| Daily | 7 days |
| Weekly | 12 days |
| Monthly | 45 days |
| Quarterly | 130 days |
| Event (policy rates) | never |

Each tile's fact box in Part III gives an example of how soon after its period the latest
value was available, so an amber dot can be checked against the series' normal lag.

A few tiles look different:

- **Two-line tiles** (*Stocks vs bonds*) draw two series that are compared, with the gap
  between them as the headline value.
- **Regime tiles** (*Growth & inflation*) place an economy in one of four growth and
  inflation regimes with a quadrant chart and a strip of past regimes.
- **Manual tiles** stand in for licensed indicators such as the regional PMIs: they
  explain the indicator and link to the publisher's release.
- **Link-only tiles** on the public site name a series the dashboard tracks but may not
  republish, with a link to it.

## Display modes {#display-modes}

The sidebar switches every chart between three modes. The badge always reads the level.

- **Level**: the series in its own unit.
- **Z-score**: how many standard deviations the value sits from its mean over the window
  shown. It makes series in different units comparable: "how stretched is this compared
  with its own recent past?"
- **Percentile**: the share of the window's observations at or below the value, from 0
  to 100.

The window is the history the edition holds: on the public site the full five years
whatever the zoom; in the app, the period since "Show history since". A z-score of +2 over
five years of a trending series means something different from +2 over thirty years, so
read the modes as relative to that window. In the z-score and percentile modes the
reference line moves to 0 and 50, and the change versus prior is measured in that mode's
units. The formulas are in [Appendix A.2](#a-modes).

## Badges and the recession count {#badges}

A badge appears only where a threshold gives the level a meaning, such as a yield curve
below zero or the Sahm rule at 0.5 points or above; the code's own rule is that it
doesn't fabricate thresholds. Some thresholds come from the indicator's publisher or
inventor, others are the dashboard's convention; each tile's section in Part III gives
the exact rules and says which is which.

The sidebar sums up the Recession Watch tab: **Recession signals** counts its tiles with
a red badge (out of the tiles with a badge) and **Cautions** counts the amber ones. How
each signal has behaved around past recessions is in its tile's section.

## Data and licences {#licences}

The dashboard takes each statistic from the organisation that produces it, through its
official API or download: FRED (St. Louis Fed) for most US series, the OECD, Eurostat,
the ECB, the IMF, the Bank of England, the ONS, the Bank of Japan and the New York Fed.
It avoids third-party benchmarks and vendor indices where an official series exists.

The public site republishes data only for series whose terms allow it: public-domain
data, data free to reuse with a citation, the OECD's and Eurostat's CC BY 4.0 licence, the
UK Open Government Licence and the reuse terms of the ECB, IMF, Bank of Japan and New
York Fed. Everything else (ICE BofA credit spreads, the S&P 500 and S&P Cotality
Case-Shiller house prices) is link-only there. Each tile's
fact box in Part III gives its licence, and the site's footer carries the notices some
providers require.

## A reading routine {#routine}

One way to work through the board, following the cockpit:

1. **Warning lights.** Check the recession count. Is anything red, and is it one of the
   tiles classed as leading (the curves) or as coincident (the Sahm rule, the recession
   probability)?
2. **Windscreen.** Are financial conditions tightening or easing, credit spreads
   widening, leading indicators rolling over, claims rising off their lows?
3. **Weather and GPS.** Which growth and inflation regime is each economy in, and how
   long has it been there?
4. **Mirrors and side windows.** Do consumers, housing, trade, markets and China confirm
   or contradict the windscreen?
5. **Speedometer.** How stretched are valuations, read against the windscreen?

Switching to z-scores shows which series are unusual against their own recent history.
Percentiles rank each value within the window, so a single extreme observation moves
them less than it moves z-scores.
