<!-- Markets & Uncertainty. Every statement is sourced; see .claude/guide_checklist.md.
     Code: R/views.R, R/display.R, R/assess.R (BADGE_BANDS$vix), instructions/sources.yaml
     (classes: sp500 coincident, vix and broad_usd leading, EPU overlay).
     Publisher documentation: FRED notes, units and copyright tags (SP500, VIXCLS, DTWEXBGS,
     USEPUINDXD, GEPUCURRENT); Federal Reserve H.10 "About" page; FEDS Note "Revisions to the
     Federal Reserve Dollar Indexes" (15 Jan 2019: 26 economies, trade weights, formula, 2017
     weights); policyuncertainty.com (US daily index method; Global EPU: 18 countries,
     re-normalised to 100 over 1997-2015, IMF WEO GDP weights, two versions); Crossref for Baker,
     Bloom and Davis (2016). S&P 500 values are licensed: none are quoted.
     History: computed 2026-10-09 (scratch markets.R). -->

{{tab markets}}

What markets and the news say about risk appetite and uncertainty:

- **Market prices**: the [S&P 500](#sp500) (licensed: the public site links to it), the
  [VIX](#vix) measure of expected equity volatility, and the Federal Reserve's
  [broad dollar index](#broad_usd).
- **News-based uncertainty**: Baker, Bloom and Davis's economic policy uncertainty
  indexes for the [US](#epu_us_daily), daily, and the [world](#epu_global), monthly.

The dashboard classes the S&P 500 as coincident, the VIX and the dollar as leading, and the
two uncertainty indexes as overlays. Only the VIX carries a badge, with bands that are the
dashboard's own.

<!-- tiles -->

{{tile sp500 lag="daily, at the close"}}

#### What it is

The S&P 500 price index from S&P Dow Jones Indices. FRED's notes: the daily index value at
market close; 500 leading companies listed on the NYSE or Nasdaq, covering 75% of US
equities; a price index, so it does not include dividends.

#### Computation

Published by S&P Dow Jones Indices via FRED (SP500); the local app shows it unchanged.

#### Reading it

There is no badge or reference line. The data are licensed: S&P's terms require prior
written permission for reproduction, so the public site shows only a link, and this guide
quotes no values.

#### Use in practice

Compare it with the [VIX](#vix), whose option prices are on stock indexes.

#### Caveats

- **Ten years of history.** FRED's notes say an agreement with S&P Dow Jones Indices limits
  FRED to 10 years of daily history for S&P series.
- **No dividends**: as a price index it understates total returns.

{{tile vix lag="daily, at the close; 8 October 2026 was available by 9 October"}}

#### What it is

The Cboe Volatility Index (VIX). FRED's notes: it measures the market's expectation of
near-term volatility conveyed by stock index option prices.

#### Computation

Published by the Chicago Board Options Exchange via FRED (VIXCLS); the dashboard shows it
unchanged.

#### Reading it

{{badge vix var="\text{VIX}_n"}}

From 2 January 1990 the index ranged from 9.14 (3 November 2017) to 82.69 (16 March 2020),
with a median of 17.6. It was "Calm" on 63% of days, "Elevated" on 29% and at 30 or above
on 8%. On 8 October 2026 it closed at 15.41.

#### Use in practice

The highest close in each of the six highest years since 1990:

| Date | Close |
|---|---|
| 16 Mar 2020 | 82.69 |
| 20 Nov 2008 | 80.86 |
| 20 Jan 2009 | 56.65 |
| 8 Apr 2025 | 52.33 |
| 8 Aug 2011 | 48.00 |
| 20 May 2010 | 45.79 |

Around the NBER peaks since 1990 it first closed at 30 or above on 6 August 1990 (a month
after the July 1990 peak), 14 April 2000 (11 months before the March 2001 peak), 15 August
2007 (4 months before the December 2007 peak) and 27 February 2020 (the month of the
February 2020 peak). It also closed above 30 in years without a recession, among them 2010,
2011 and 2025.

#### Caveats

- **Expectations, not outcomes**: it reads option prices, not realised volatility; the
  10-year Treasury tile on the Credit & Rates tab is the realised measure for bonds.

{{tile broad_usd lag="daily, released weekly on Mondays (H.10); 2 October 2026 was the latest on 9 October"}}

#### What it is

The Federal Reserve's nominal broad US dollar index (January 2006 = 100). The Federal
Reserve describes its dollar indexes as designed to help estimate the overall effects of
dollar exchange-rate movements on US international trade; the broad index covers the
currencies of the 26 economies whose bilateral trade with the US is at least 0.5% of the
total.

#### Computation

Published by the Federal Reserve Board (H.10 release) via FRED (DTWEXBGS); the dashboard
shows it unchanged. Following the Fed's note of January 2019, each day's index chains the
previous day's value by a geometrically weighted average of the changes in bilateral
exchange rates,

$$
I_t = I_{t-1} \prod_{j=1}^{N(t)} \left(\frac{e_{j,t}}{e_{j,t-1}}\right)^{w_{j,t}},
$$

with $e_{j,t}$ the price of the dollar in currency $j$ and $w_{j,t}$ that economy's share
of US bilateral trade in goods and services. In the note's 2017 weights the largest were
the euro area (18.6%), China (16.2%), Canada (13.6%) and Mexico (13.3%).

#### Reading it

There is no badge or reference line. A rise means a stronger dollar. From January 2006 the
index ranged from 85.47 (26 July 2011) to 130.04 (13 January 2025); on 2 October 2026 it
was 121.38, 0.8% above a year earlier.

#### Use in practice

Compare it with commodity prices on the Trade & Commodities tab, which are quoted in
dollars.

#### Caveats

- **Nominal**: the Fed also publishes real (inflation-adjusted) indexes, monthly; this tile
  shows the daily nominal index.

{{tile epu_us_daily lag="daily; 8 October 2026 was available by 9 October"}}

#### What it is

The daily US Economic Policy Uncertainty index of Scott Baker, Nicholas Bloom and Steven
Davis, built from US newspapers.

#### Computation

Published by its authors via FRED (USEPUINDXD); the dashboard shows it unchanged. Their
site describes the method: from US newspaper sources in the NewsBank service, count the
articles that contain at least one term from each of three sets: "economic" or "economy";
"uncertain" or "uncertainty"; and "legislation", "deficit", "regulation", "congress",
"federal reserve" or "white house". Because NewsBank's coverage grew from under 100
newspapers in 1985 to over 2,000 by 2020, the counts are normalised by the total number of
articles. The method is set out in Baker, Bloom and Davis (2016).

#### Reading it

There is no badge or reference line. From 1 January 1985 the daily index ranged from 3.32
(7 August 2015) to 1,048.95 (2 May 2026), with a median of 92. Its 30-day average peaked at
586 (4 May 2025) and was 276 on 8 October 2026, when the daily value was 353.79.

#### Use in practice

Daily values jump from day to day; read the level over several weeks, or the
[global index](#epu_global), which is monthly.

#### Caveats

- **Revised**: the authors update the previous 30 days each day.

{{tile epu_global lag="monthly; July 2026 was the latest on 9 October 2026"}}

#### What it is

The Global Economic Policy Uncertainty index of Baker, Bloom and Davis, the version
weighted by current-price GDP.

#### Computation

Published by its authors via FRED (GEPUCURRENT); the dashboard shows it unchanged. Their
site: each national index reflects the share of the country's own newspaper articles that
contain terms on the economy, policy and uncertainty. To build the global index they
re-normalise each national index to a mean of 100 over 1997 (or its first year) to 2015,
impute missing values to get a balanced panel of 18 countries from January 1997, and take
the GDP-weighted average using IMF World Economic Outlook data. The 18 countries are
Australia, Brazil, Canada, Chile, China, France, Germany, Greece, India, Ireland, Italy,
Japan, Russia, South Korea, Spain, Sweden, the UK and the US. (FRED's notes still list 20
countries, adding Mexico and the Netherlands.)

#### Reading it

There is no badge or reference line. From January 1997 the index ranged from 47.6 (July
2007) to 620.9 (April 2025), with a median of 123. Its five highest months were April,
May and March 2025, March 2026 and May 2020. In July 2026 it was 241.7.

#### Use in practice

Compare it with the [US daily index](#epu_us_daily) and with the [VIX](#vix).

#### Caveats

- **Newspaper-based**: it counts articles, not policy events.
