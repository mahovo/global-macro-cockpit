<!-- Trade & Commodities. Every statement is sourced; see .claude/guide_checklist.md.
     Code: R/views.R, R/display.R, R/assess.R (BADGE_BANDS$gscpi, assess_copper, BADGE_PARAMS$copper),
     instructions/sources_global.yaml (gscpi replaces baltic_dry_index).
     Publisher documentation: NY Fed Staff Report 1017 (Benigno, di Giovanni, Groen and Noble, May
     2022; method, inputs, countries, standardisation; abstract on PPI inflation); EIA spot-price
     definitions pages (Brent, WTI Cushing, Henry Hub, spot price; source Refinitiv); FRED notes
     and copyright tags (DCOILBRENTEU, DCOILWTICO, DHHNGSP public domain; PCOPPUSDM copyrighted,
     citation required; IMF benchmark definition).
     History: computed 2026-10-09 (scratch trade.R). -->

{{tab trade_energy}}

Supply-chain pressure and four commodity prices:

- The New York Fed's [Global Supply Chain Pressure Index](#gscpi), which combines
  shipping and airfreight costs with purchasing managers' survey measures of supply
  delays for seven economies.
- Oil: [Brent](#brent) and [West Texas Intermediate](#wti) crude, two benchmark prices
  the EIA describes as reference prices for other crude streams.
- [Henry Hub natural gas](#henry_hub_gas), the US benchmark gas price.
- The IMF's global [copper price](#copper_global).

The dashboard classes all five as leading indicators. Only the supply-chain index and
copper carry badges; their rules are the dashboard's own.

<!-- tiles -->

{{tile gscpi lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The Global Supply Chain Pressure Index (GSCPI), published by the Federal Reserve Bank of
New York and introduced in its Staff Report 1017 (Benigno, di Giovanni, Groen and Noble,
May 2022). It summarises pressure in global supply chains in one number. The dashboard
uses it in place of the Baltic Dry Index tile of the original design; the Baltic Dry Index
is one of the GSCPI's inputs.

#### Computation

Published by the New York Fed; the dashboard shows it unchanged. The staff report builds
it in two steps from two sets of inputs:

- **Transport costs**: the Baltic Dry Index (shipping costs for raw materials such as coal
  or steel), the Harpex index of container-ship charter rates, and the BLS price indices
  for airfreight to and from the US, for Asia and Europe.
- **Manufacturing PMI components** for China, the euro area, Japan, South Korea, Taiwan,
  the UK and the US: delivery times, backlogs and purchased stocks.

First, each input is cleaned of demand effects by regressing it on PMI measures of demand
(new orders, and for transport costs also quantities purchased) and keeping the
residuals. Second, a principal component analysis extracts the inputs' common component,
which is the index:

$$
\text{GSCPI}_t = \frac{c_t - \bar c}{s_c},
$$

with $c_t$ the common component, expressed in standard deviations from its average since
1997.

#### Reading it

{{badge gscpi var="\text{GSCPI}_n"}}

The reference line is at zero, the index's average. From September 1997 to September
2026 the index read "Normal range" in 84% of months, "Severe pressure" in 6%, "Elevated
pressure" in 5% and "Slack" in 5%. Its highest value was 4.43 (December 2021) and its
lowest −1.56 (May 2023); in September 2026 it was 1.28.

#### Use in practice

It was at 2 or above from March to July 2020 and from February 2021 to June 2022. The
staff report found recent inflationary pressures closely related to the index, especially
US producer price inflation; compare it with the
[PPI final demand](#ppi_final_demand) tile on the Inflation tab.

#### Caveats

- **Relative to its own history**: zero is the 1997–2026 average, and the scale is in
  standard deviations.

{{tile brent lag="daily; the price for 6 October 2026 was available by 9 October"}}

#### What it is

The Brent crude oil spot price in US dollars per barrel, from the US Energy Information
Administration (EIA). The EIA defines Brent as a blended crude stream produced in the
North Sea region that serves as a reference, or "marker", for pricing a number of other
crude streams.

#### Computation

Published by the EIA via FRED (DCOILBRENTEU); the dashboard shows it unchanged. The EIA
names Refinitiv, an LSEG business, as the source of its spot prices.

#### Reading it

There is no badge or reference line. From 20 May 1987 the price ranged from $9.10 (10
December 1998) to $143.95 (3 July 2008); on 6 October 2026 it was $125.44.

#### Use in practice

The gap between Brent and [WTI](#wti), computed from the two daily series:

| Period | Average Brent minus WTI |
|---|---|
| 1987–2010 | −$1.29 |
| 2011–2014 | +$12.48 |
| 2015–October 2026 | +$4.37 |

Its widest point was +$54.34 on 20 April 2020, the day WTI closed below zero; on
6 October 2026 it was +$29.20.

#### Caveats

- **Nominal dollars**, not adjusted for inflation.
- **Spot prices**, which can differ from futures prices.

{{tile wti lag="daily; the price for 6 October 2026 was available by 9 October"}}

#### What it is

The West Texas Intermediate (WTI) crude oil spot price at Cushing, Oklahoma, in US dollars
per barrel (EIA). The EIA defines WTI as a crude stream produced in Texas and southern
Oklahoma that serves as a reference for pricing other crude streams and is traded in the
domestic spot market at Cushing.

#### Computation

Published by the EIA via FRED (DCOILWTICO); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From 2 January 1986 the price ranged from −$36.98
(20 April 2020, the only negative day) to $145.31 (3 July 2008); on 6 October 2026 it was
$96.24.

#### Use in practice

Compare it with [Brent](#brent): the gap between the two is in the Brent section.

#### Caveats

- **Nominal dollars; spot prices**, as for Brent.

{{tile henry_hub_gas lag="daily; the price for 6 October 2026 was available by 9 October"}}

#### What it is

The Henry Hub natural gas spot price in US dollars per million British thermal units
(EIA). The EIA's notes say the prices are based on delivery at the Henry Hub in
Louisiana, and define a spot price as the price of a one-time open-market transaction for
immediate delivery.

#### Computation

Published by the EIA via FRED (DHHNGSP); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From 7 January 1997 the price ranged from $1.21 (8
November 2024) to $30.72 (23 January 2026); on 6 October 2026 it was $3.03.

#### Use in practice

Its range since 1997 spans a factor of about 25 ($1.21 to $30.72), so spikes dominate the
level chart; the percentile mode shows where a price sits within the window instead.

#### Caveats

- **Daily spot prices** can spike: in January 2026 the price rose from $3.06 on the 16th
  to $30.72 on the 23rd and was back at $4.40 on 2 February.

{{tile copper_global lag="monthly; July 2026 was the latest on 9 October 2026"}}

#### What it is

The IMF's global price of copper, in US dollars per metric ton (via FRED). FRED's notes
say the IMF's commodity prices are benchmark prices representative of the global market,
determined by the largest exporter of each commodity, and are period averages in nominal
dollars.

#### Computation

Published by the IMF via FRED (PCOPPUSDM); the dashboard shows it unchanged.

#### Reading it

{{badge copper_global var="P_n"}}

The badge compares the latest month with three months earlier. From January 1992 it read
"Rising — demand firm" in 54% of months, "Falling — softening" in 39% and "Flat" in 7%.
The price ranged from $1,377 (October 2001) to $13,552 (June 2026); in July 2026 it was
$13,543, 5.1% above three months earlier.

#### Use in practice

The badge's three-month window reads the recent direction; compare it with the leading
indicators on the Cycle & Growth tab.

#### Caveats

- **Monthly averages, published with a lag**: July 2026 was the latest month in early
  October.
- **Nominal dollars.**
