<!-- Inflation. Every statement is sourced; see .claude/guide_checklist.md.
     Code: R/views.R, R/display.R, R/assess.R (BADGE_BANDS breakeven, cpi), R/fetch.R (.yoy_tile,
     .yoy_published), instructions/sources_global.yaml (hicp_*, cpi_uk, cpi_japan).
     Publisher documentation: FRED notes (T5YIE, T10YIE, T5YIFR, MICH, CPIAUCSL, CPILFESL, PCEPILFE,
     PPIFIS); FOMC Statement on Longer-Run Goals (PCE, 2 percent); ECB monetary policy strategy page
     (2% HICP, medium term, symmetric); Bank of England "Inflation and the 2% target" (CPI);
     Bank of Japan statement of 18 Sep 2026 (2 percent price stability target); Eurostat dataflow
     and code labels (prc_hicp_minr; EA changing composition; EA20 2023-2025; EU27_2020); ONS
     D7G7 and L55O titles; IMF CPI dataset description (national all-items headline indexes).
     Formulas: T5YIE = DGS5 - DFII5 and T10YIE = DGS10 - DFII10 on every day since 2003, and FRED's
     5y5y formula, checked against FRED data 2026-10-07. History: computed 2026-10-07 (infl.R). -->

{{tab inflation}}

Inflation, measured two ways:

- **Expected inflation**: market-implied [5-year](#breakeven_5y), [10-year](#breakeven_10y)
  and [5-year, 5-year forward](#breakeven_5y5y_fwd) breakevens from Treasury yields, and
  consumers' [one-year expectations](#umich_inflation_exp_1y) from the University of
  Michigan survey.
- **Price changes**: US [CPI](#cpi_headline), [core CPI](#cpi_core),
  [core PCE](#pce_core) and [producer prices](#ppi_final_demand), and consumer-price
  inflation for the [euro area](#hicp_ea), the [EU](#hicp_eu), [Germany](#hicp_de),
  [France](#hicp_fr), the [UK](#cpi_uk) and [Japan](#cpi_japan). All are changes over
  twelve months, in %.

The central banks' own targets:

| Central bank | Target |
|---|---|
| Federal Reserve | 2%, as measured by the annual change in the price index for personal consumption expenditures (FOMC Statement on Longer-Run Goals) |
| ECB | 2% inflation over the medium term, measured by the HICP; deviations on either side are equally undesirable |
| Bank of England | 2% CPI inflation, a target set by the Government |
| Bank of Japan | a price stability target of 2% |

The consumer-price tiles draw a reference line at 2 and carry the same badge, whose bands
are the dashboard's own:

{{badge hicp_ea var="\pi_n"}}

<!-- tiles -->

{{tile breakeven_5y lag="the value for 6 October 2026 was available on 7 October"}}

#### What it is

The 5-year breakeven inflation rate: the yield on 5-year Treasury securities minus the
yield on 5-year Treasury Inflation-Indexed Securities (TIPS). FRED's notes describe its
latest value as implying what market participants expect inflation to be over the next
five years, on average.

#### Computation

Published by FRED from the constant-maturity yields; the dashboard shows it unchanged:

$$
b^{5y}_t = y^{5y}_t - r^{5y}_t ,
$$

with $y^{5y}$ the nominal yield (DGS5) and $r^{5y}$ the inflation-indexed yield (DFII5).
This identity holds exactly on every day of the FRED data since 2003.

#### Reading it

{{badge breakeven_5y var="b_n"}}

The badge bands and the 2.3% reference line are the dashboard's own. From January 2003
to October 2026 the series was in the "Anchored" band on 60% of days, "Low" on 36%,
"Elevated" on 4% and "High" on 1%. Its highest value was 3.59% (25 March 2022) and its
lowest −2.24% (28 November 2008); on 6 October 2026 it was 2.37%.

#### Use in practice

Compare it with the [10-year breakeven](#breakeven_10y) and the
[5y5y forward](#breakeven_5y5y_fwd), which cover longer horizons, and with realized
inflation on this tab.

#### Caveats

- **A difference of two yields.** Anything that moves the nominal and inflation-indexed
  yields differently moves the breakeven.
- **CPI-based.** TreasuryDirect says it adjusts TIPS principal using a version of the BLS
  Consumer Price Index, while the Fed's 2% goal is defined on PCE inflation.

{{tile breakeven_10y lag="the value for 6 October 2026 was available on 7 October"}}

#### What it is

The 10-year breakeven inflation rate: the 10-year Treasury yield minus the 10-year TIPS
yield, which FRED describes as implying the average inflation market participants expect
over the next ten years.

#### Computation

Published by FRED; the dashboard shows it unchanged:

$$
b^{10y}_t = y^{10y}_t - r^{10y}_t ,
$$

with $y^{10y}$ the nominal yield (DGS10) and $r^{10y}$ the inflation-indexed yield
(DFII10); the identity holds exactly in the FRED data since 2003.

#### Reading it

{{badge breakeven_10y var="b_n"}}

The badge bands and the 2.3% reference line are the dashboard's own. Since January 2003
the series was "Anchored" on 79% of days, "Low" on 20% and "Elevated" on 1%; it never
reached the "High" band. Its highest value was 3.02% (21 April 2022), its lowest 0.04%
(20 November 2008), and it was 2.36% on 6 October 2026.

#### Use in practice

Over a longer horizon than the [5-year breakeven](#breakeven_5y); the gap between them
shows whether markets expect inflation to be higher in the near term or later.

#### Caveats

- **A difference of two yields**, and **CPI-based**, as for the 5-year breakeven.

{{tile breakeven_5y5y_fwd lag="the value for 6 October 2026 was available on 7 October"}}

#### What it is

The 5-year, 5-year forward inflation expectation rate: a measure of expected average
inflation over the five-year period that begins five years from today (FRED's notes).

#### Computation

FRED constructs it from the 10-year and 5-year breakevens:

$$
f_t = 100\left[\left(\frac{(1 + b^{10y}_t/100)^{10}}{(1 + b^{5y}_t/100)^{5}}\right)^{1/5} - 1\right],
$$

where FRED's formula writes each breakeven as the nominal minus the inflation-adjusted
Treasury yield. Applied to the two FRED breakevens, the formula reproduces the published
series to within 0.005 percentage points.

#### Reading it

{{badge breakeven_5y5y_fwd var="f_n"}}

The badge bands and the 2.3% reference line are the dashboard's own. Since January 2003
it was "Anchored" on 85% of days, "Low" on 9% and "Elevated" on 6%. Its highest and lowest
values both came in late 2008 (3.05% on 12 November, 0.43% on 29 December); from October
2021 to October 2026 its highest value was 2.67% (21 April 2022), and it was 2.35% on
6 October 2026.

#### Use in practice

It leaves out the next five years, so it reads expectations further ahead than either
breakeven alone.

#### Caveats

- **Derived from the two breakevens**, so it inherits their caveats.

{{tile umich_inflation_exp_1y lag="FRED shows it a month late by agreement with the source (August 2026 was the latest on 7 October 2026)"}}

#### What it is

From the University of Michigan's Surveys of Consumers: the median price change that
consumers expect over the next 12 months.

#### Computation

Published by the University of Michigan via FRED (MICH); the dashboard shows it
unchanged. FRED's notes say the most recent value is not shown, by agreement with the
source.

#### Reading it

There is no badge or reference line. From January 1978 the highest value was 10.4%
(January 1980) and the lowest 0.4% (November 2001); since 2020 the highest was 6.6% (May
2025). In August 2026 it was 4.0%.

#### Use in practice

It is the only household survey on the tab; compare it with the market-implied
[breakevens](#breakeven_5y) and with realized [CPI inflation](#cpi_headline).

#### Caveats

- **A month behind** on FRED, as above.
- **A median of survey answers**, not a price measure.

{{tile cpi_headline lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

US consumer price inflation: the change over twelve months in the Consumer Price Index
for All Urban Consumers, all items, US city average (BLS, seasonally adjusted).

#### Computation

Computed by the dashboard from the published index (CPIAUCSL, 1982–84 = 100)
([Appendix A.1](#a-notation)):

$$
\pi_t = 100\left(\frac{P_t}{P_{t-12}} - 1\right),
$$

for months where both $P_t$ and $P_{t-12}$ are published. FRED has no value for October
2025, so October 2025 and October 2026 have none.

#### Reading it

{{badge cpi_headline var="\pi_n"}}

The reference line is at 2, the bands are the dashboard's own, and the Fed's 2% goal
refers to PCE inflation, not CPI. From January 1948 the highest rate was 14.6% (March
1980) and the lowest −3.0% (August 1949); since 2019 the highest was 9.0% (June 2022).
Since 1990 the badge would have read "Near target" in 38% of months, "Above target" in 41%
and "High" in 14%. In August 2026 the rate was 3.35%.

#### Use in practice

Compare it with [core CPI](#cpi_core), which leaves out food and energy, and with
[core PCE](#pce_core), the core version of the measure the Fed's goal is defined on.

#### Caveats

- **Seasonally adjusted index.** The tile uses the seasonally adjusted index. Since 2021
  its rates differed from those of the unadjusted index (CPIAUCNS) by up to 0.14
  percentage points; in June 2022, 8.98% against 9.06%.
- **Missing month**, as above.

{{tile cpi_core lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

US core CPI inflation: the change over twelve months in the CPI for all urban consumers,
all items less food and energy (BLS, seasonally adjusted). FRED's notes call it "core CPI"
and say it is widely used because food and energy prices are volatile.

#### Computation

Computed by the dashboard from the published index (CPILFESL, 1982–84 = 100), as for
headline CPI; FRED has no October 2025 value, so October 2025 and October 2026 have none.

#### Reading it

{{badge cpi_core var="\pi_n"}}

From January 1958 the highest rate was 13.6% (June 1980) and the lowest 0.6% (October
2010); since 2019 the highest was 6.6% (September 2022). In August 2026 it was 2.45%.

#### Use in practice

The gap between [headline](#cpi_headline) and core inflation reflects food and energy
prices, which core leaves out.

#### Caveats

- **Missing month**, as for headline CPI.

{{tile pce_core lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

US core PCE inflation: the change over twelve months in the chain-type price index for
personal consumption expenditures excluding food and energy (BEA, seasonally adjusted).
The FOMC's 2% longer-run goal is defined on the annual change in the overall PCE price
index; this tile shows the version without food and energy.

#### Computation

Computed by the dashboard from the published index (PCEPILFE, 2017 = 100), as for CPI. The
PCE index has no missing months.

#### Reading it

{{badge pce_core var="\pi_n"}}

From January 1960 the highest rate was 10.2% (February 1975) and the lowest 0.6% (July
2009); since 2019 the highest was 5.6% (September 2022). In August 2026 it was 3.01%.

#### Use in practice

Compare it with [core CPI](#cpi_core): FRED's notes say the PCE and CPI indexes are
constructed differently, resulting in different inflation rates.

#### Caveats

- **Revisions.** FRED's notes say BEA revises previously published PCE data to reflect
  updated information or new methodology.

{{tile ppi_final_demand lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

US producer price inflation: the change over twelve months in the Producer Price Index
by Commodity, Final Demand (BLS, seasonally adjusted).

#### Computation

Computed by the dashboard from the published index (PPIFIS, November 2009 = 100), as for
CPI, so the rate starts in November 2010.

#### Reading it

There is no target, so no reference line or badge. From November 2010 the highest rate
was 11.6% (March 2022) and the lowest −1.5% (October 2015); in August 2026 it was 5.41%.

#### Use in practice

Compare it with consumer-price inflation on this tab; the dashboard classes it as a
leading indicator and the consumer-price measures as coincident.

#### Caveats

- **Short history**: the final-demand index starts in November 2009.

{{tile hicp_ea lag="September 2026 was available on 7 October 2026"}}

#### What it is

Euro-area inflation: the annual rate of change of the Harmonised Index of Consumer Prices
(HICP), from Eurostat, for the euro area in its changing composition. Eurostat's label
lists the compositions: 11 countries from 1999, 12 from 2001, rising to 20 from 2023 and
21 from 2026.

#### Computation

From Eurostat (dataset prc_hicp_minr, "HICP – ECOICOP ver.2 – indices and rates of change,
monthly data", unit "annual rate of change", geo EA); the dashboard shows it unchanged.

#### Reading it

{{badge hicp_ea var="\pi_n"}}

The ECB aims for 2% inflation over the medium term, measured by the HICP; the reference
line is at 2 and the bands are the dashboard's own. From January 1997 the highest rate
was 10.6% (October 2022) and the lowest −0.7% (July 2009); it was negative in 17 months
between June 2009 and December 2020. In September 2026 it was 3.8%.

#### Use in practice

Compare it with the [ECB deposit rate](#ecb_policy_rate) on the Credit & Rates tab and
with the members' rates below.

#### Caveats

- **Composition.** The series follows the euro area's membership; Eurostat also publishes
  fixed compositions (EA20 for 2023–2025, EA21 from 2026).

{{tile hicp_eu lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

HICP inflation for the European Union, 27 countries (Eurostat's "European Union – 27
countries (from 2020)").

#### Computation

From Eurostat (prc_hicp_minr, annual rate of change, geo EU27_2020); the dashboard shows
it unchanged.

#### Reading it

{{badge hicp_eu var="\pi_n"}}

From December 2000 the highest rate was 11.5% (October 2022) and the lowest −0.6%
(January 2015); it was negative in 8 months between December 2014 and May 2016. In August
2026 it was 3.2%.

#### Use in practice

It covers EU members outside the euro area too; compare it with the
[euro-area rate](#hicp_ea).

#### Caveats

- **Wider than the euro area**: Eurostat's EU series covers 27 countries, the euro area 21
  (from 2026), so the ECB's target applies to only part of it.

{{tile hicp_de lag="September 2026 was available on 7 October 2026"}}

#### What it is

HICP inflation for Germany (Eurostat).

#### Computation

From Eurostat (prc_hicp_minr, annual rate of change, geo DE); the dashboard shows it
unchanged.

#### Reading it

{{badge hicp_de var="\pi_n"}}

From January 1997 the highest rate was 11.6% (October 2022) and the lowest −0.7% (July
2009); it was negative in 15 months between May 2009 and December 2020. In September 2026
it was 3.3%.

#### Use in practice

Compare it with the [euro-area rate](#hicp_ea) and with [France](#hicp_fr).

#### Caveats

- **Monthly annual rates** as published by Eurostat.

{{tile hicp_fr lag="September 2026 was available on 7 October 2026"}}

#### What it is

HICP inflation for France (Eurostat).

#### Computation

From Eurostat (prc_hicp_minr, annual rate of change, geo FR); the dashboard shows it
unchanged.

#### Reading it

{{badge hicp_fr var="\pi_n"}}

From January 1997 the highest rate was 7.3% (February 2023) and the lowest −0.8% (July
2009); it was negative in 11 months between May 2009 and April 2016. In September 2026 it
was 3.4%.

#### Use in practice

Compare it with the [euro-area rate](#hicp_ea) and with [Germany](#hicp_de).

#### Caveats

- **Monthly annual rates** as published by Eurostat.

{{tile cpi_uk lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

UK consumer price inflation: the ONS's "CPI annual rate 00: all items" (series D7G7). The
Government sets the Bank of England an inflation target of 2%, and the Bank says CPI is
the measure of inflation it targets.

#### Computation

From the Office for National Statistics (D7G7); the dashboard shows it unchanged. The same
series feeds the [UK growth and inflation regime](#a-regimes).

#### Reading it

{{badge cpi_uk var="\pi_n"}}

From January 1989 the highest rate was 11.1% (October 2022) and the lowest −0.1% (April
2015); it was negative only in April, September and October 2015. In August 2026 it was
3.1%.

#### Use in practice

Compare it with [SONIA](#rate_3m_uk) on the Credit & Rates tab, which tracks Bank Rate.

#### Caveats

- **CPI, not CPIH.** The ONS also publishes a CPIH annual rate (series L55O), a different
  measure; this tile shows CPI, the measure the Bank of England targets.

{{tile cpi_japan lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

Japanese consumer price inflation, % change over twelve months, from the IMF's Consumer
Price Index dataset, which the IMF describes as holding each economy's national all-items
headline index. The Bank of Japan has a price stability target of 2%.

#### Computation

From the IMF data API (dataset IMF.STA CPI, Japan, all items, % change over 12 months);
the dashboard shows it unchanged.

#### Reading it

{{badge cpi_japan var="\pi_n"}}

From January 1960 the highest rate was 24.8% (February 1974) and the lowest −2.5%
(October 2009). Since 2000 it was negative in 133 months, most recently in August 2021,
and at or above 2% every month from April 2022 to December 2025 (45 months), its longest
such run in the data since 1990. In August 2026 it was 1.96%.

#### Use in practice

Compare it with the Bank of Japan's [overnight call rate](#rate_3m_japan) on the Credit &
Rates tab.

#### Caveats

- **A copy, not the producer's release.** The figures come from the IMF's dataset rather
  than from Japan's statistics bureau directly.
