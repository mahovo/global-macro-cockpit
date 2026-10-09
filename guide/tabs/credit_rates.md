<!-- Credit & Rates. Every statement is sourced; see .claude/guide_checklist.md.
     Code: R/views.R, R/display.R, R/assess.R (BADGE_BANDS hy, hy_ig; ASSESSORS), R/fetch.R
     (ust10y_realized_vol, ecb_policy_rate), R/transforms.R (hy_minus_ig), registry.
     Publisher documentation: FRED notes and citations (DRTSCILM, BAMLH0A0HYM2, BAMLC0A0CM, DGS3MO,
     DGS2, DGS10, EFFR, DFEDTARL/U, IRLTLT01*, IR3TIB01CAM156N); Fed SLOOS page and July 2026
     SLOOS release; H.15 release notes; ECB key-rates page and ECB data API titles (FM DFR, IRS,
     YC SR_3M); Bank of England SONIA page and IADB titles (IUDSOIA, IUDBEDR); Bank of Japan
     statistics page and the 18 Sep 2026 policy statement (k260918b.pdf).
     History: computed 2026-10-07 from FRED, ECB, BoE and BoJ data (scratch credit.R,
     credit2.R). ICE BofA values are licensed: none are quoted. -->

{{tab credit_rates}}

Credit spreads and the structure of interest rates: what borrowing costs, and how much
extra investors demand to lend to riskier borrowers. The tab has four groups:

- **US credit**: banks' lending standards from the Fed's
  [loan officer survey](#sloos_ci_tightening), and the option-adjusted spreads of
  [high-yield](#hy_oas) and [investment-grade](#ig_oas) corporate bonds with the
  [gap between them](#hy_minus_ig). The three ICE BofA spread tiles are licensed data:
  the local app shows them, the public site links to them.
- **US rates**: the [effective federal funds rate](#effr), Treasury yields at
  [3 months](#ust_3m), [2 years](#ust_2y) and [10 years](#ust_10y), and the
  [realized volatility](#ust10y_realized_vol) of the 10-year yield.
- **Other policy and short rates**: the [ECB deposit rate](#ecb_policy_rate), the
  euro-area [3-month AAA yield](#rate_3m_euro), [SONIA](#rate_3m_uk) for the UK, the
  [overnight call rate](#rate_3m_japan) for Japan and a
  [3-month rate](#rate_3m_canada) for Canada.
- **Other 10-year government yields**: the [euro area](#ea_10y), [Germany](#de_10y),
  [France](#fr_10y), [Italy](#it_10y), the [UK](#uk_10y), [Japan](#jp_10y) and
  [Canada](#ca_10y).

The two yield-curve spreads built from these Treasury yields are on the Recession Watch
tab.

<!-- tiles -->

{{tile sloos_ci_tightening lag="the July 2026 survey, covering the second quarter, was FRED's latest on 7 October 2026"}}

#### What it is

From the Federal Reserve Board's Senior Loan Officer Opinion Survey on Bank Lending
Practices (SLOOS): the net percentage of domestic banks that tightened their standards
for commercial and industrial (C&I) loans to large and middle-market firms. The survey
release defines large and middle-market firms as those with annual sales of \$50 million
or more.

#### Computation

Published by the Federal Reserve Board via FRED (DRTSCILM); the dashboard shows it
unchanged. The SLOOS release defines the net percentage as the fraction of banks
reporting tightened standards ("tightened considerably" or "tightened somewhat") minus
the fraction reporting eased standards:

$$
\text{Net}_q = 100 \left( \frac{n^{\text{tightened}}_q}{n_q} - \frac{n^{\text{eased}}_q}{n_q} \right) \quad (\%).
$$

The Fed surveys up to eighty large domestic banks and twenty-four US branches and
agencies of foreign banks, generally quarterly, timed so that results are available for
the FOMC meetings in January/February, April/May, August and October/November, and
occasionally runs one or two extra surveys a year.

#### Reading it

Positive values mean more banks tightened than eased; negative values, more eased. The
tile has no badge or reference line. In the FRED series (from the second quarter of
1990):

- the highest reading was 83.6% (October 2008 survey) and the lowest −32.4% (July 2021
  survey);
- readings were positive in 49% of surveys;
- the latest, the July 2026 survey (covering the second quarter), was 0%.

#### Use in practice

The survey readings nearest each NBER peak since 1990:

| NBER peak | Latest survey at or before the peak | Highest reading in the year after |
|---|---|---|
| Jul 1990 | 46.7% (July 1990) | 54.2% |
| Mar 2001 | 59.6% (January 2001) | 50.9% |
| Dec 2007 | 19.2% (October 2007) | 83.6% |
| Feb 2020 | 0% (January 2020) | 71.2% |

FRED dates each survey by the quarter in which it was taken (for example 1 July 2026 for
the July 2026 survey).

#### Caveats

- **A survey of standards**, not of loan volumes or prices; the release also covers loan
  demand and other loan categories, which this tile doesn't show.
- **Quarterly**, so it changes four times a year (occasionally more).

{{tile hy_oas lag="the value for 6 October 2026 was available on 7 October"}}

#### What it is

The option-adjusted spread (OAS) of the ICE BofA US High Yield Index: the extra yield
that US dollar, below-investment-grade corporate bonds (rated BB or below) pay over US
Treasuries.

#### Computation

Published by ICE Data Indices via FRED; the dashboard shows it unchanged. FRED's notes:
an OAS index is built from each constituent bond's OAS, weighted by market
capitalisation, and the spread is measured between that index and a spot Treasury curve.
To enter the index a bond must be rated below investment grade on an average of Moody's,
S&P and Fitch, have more than a year to maturity, a fixed coupon schedule and at least
\$100 million outstanding, among other rules.

#### Reading it

{{badge hy_oas var="\text{OAS}_n"}}

These thresholds are the dashboard's own. The tile has no reference line.

#### Use in practice

Read it with the [investment-grade spread](#ig_oas) and the [gap](#hy_minus_ig) between
them, and with the conditions indices on the Conditions & Liquidity tab.

#### Caveats

- **Licensed.** ICE's terms don't allow republication, so the public site shows a link;
  the local app shows the data. This guide quotes no values.
- **Three years of history.** FRED's notes say that from April 2026 the series includes
  only three years of observations; longer history is available from ICE.

{{tile ig_oas lag="the value for 6 October 2026 was available on 7 October"}}

#### What it is

The option-adjusted spread of the ICE BofA US Corporate Index, which FRED's notes describe
as an index of bonds considered investment grade (rated BBB or better).

#### Computation

Published by ICE Data Indices via FRED; the dashboard shows it unchanged. The spread is
built the same way as the high-yield spread.

#### Reading it

There is no badge or reference line.

#### Use in practice

It covers the higher-rated part of the US corporate bond market; the
[high-yield spread](#hy_oas) covers the lower-rated part, and the
[HY − IG tile](#hy_minus_ig) shows the gap between the two.

#### Caveats

- **Licensed** (link-only on the public site) and **three years of history** on FRED
  since April 2026, as for the high-yield spread.

{{tile hy_minus_ig lag="the value for 6 October 2026 was available on 7 October"}}

#### What it is

The high-yield spread minus the investment-grade spread: how much more the market charges
below-investment-grade borrowers than investment-grade ones.

#### Computation

Computed by the dashboard from the two ICE BofA spreads ([Appendix A.5](#a-hy-ig)):

$$
D_t = \text{OAS}^{HY}_t - \text{OAS}^{IG}_t \quad (\text{pp}).
$$

#### Reading it

{{badge hy_minus_ig var="D_n"}}

These thresholds are the dashboard's own. The tile has no reference line.

#### Use in practice

A narrowing gap means high-yield spreads are falling relative to investment-grade
spreads; a widening gap, the reverse.

#### Caveats

- **Licensed inputs**: link-only on the public site; three years of history on FRED.

{{tile ust10y_realized_vol lag="the value for 6 October 2026 was available on 7 October"}}

#### What it is

How much the 10-year Treasury yield has moved day to day over the last month, expressed as
an annual rate in basis points. The dashboard uses it in place of the licensed ICE BofA
MOVE index.

#### Computation

Computed by the dashboard from the 10-year constant-maturity yield (DGS10)
([Appendix A.7](#a-realized-vol)):

$$
\sigma_t = \sqrt{252}\;\operatorname{sd}\left(\Delta y_{t-20}, \dots, \Delta y_t\right),
\qquad \Delta y_t = 100\,(y_t - y_{t-1}) \ \text{bp}.
$$

#### Reading it

There is no badge or reference line. Computed over the whole DGS10 history (from January
1962):

- the median was 77.8 bp; from October 2021 to October 2026 it was 91.5 bp;
- the highest values were 436 bp (12 March 1980) and 408 bp (12 January 1981); since
  October 2021 the highest was 172 bp (12 July 2022);
- on 6 October 2026 it was 85.5 bp.

#### Use in practice

A rising value means larger daily moves in the 10-year yield. Compare it with its own
history using the z-score or percentile mode.

#### Caveats

- **Backward-looking**: it measures moves that have already happened over 21 trading
  days.

{{tile ust_3m lag="the value for 5 October 2026 was available by 7 October"}}

#### What it is

The yield on US Treasury securities at a constant 3-month maturity.

#### Computation

Published by the Federal Reserve Board in its H.15 release, via FRED (DGS3MO); the
dashboard shows it unchanged. The H.15 notes explain that constant-maturity yields are
interpolated by the US Treasury from the daily yield curve for non-inflation-indexed
Treasury securities, based on closing market bid yields on actively traded securities.

#### Reading it

There is no badge or reference line. The FRED series starts on 1 September 1981, when it
stood at 17.01%, its highest; it was 0.00% on 10 December 2008, and 4.22% on 5 October
2026.

#### Use in practice

From December 2008 to October 2026 it tracked the [effective federal funds rate](#effr)
closely: the daily difference averaged 0.02 percentage points (standard deviation 0.16)
and the correlation was 0.997.

#### Caveats

- **Constant maturity**: an interpolated point on the curve, not a specific bill.

{{tile ust_2y lag="the value for 5 October 2026 was available by 7 October"}}

#### What it is

The yield on US Treasury securities at a constant 2-year maturity.

#### Computation

Published by the Federal Reserve Board in its H.15 release, via FRED (DGS2); interpolated
by the Treasury as described for the [3-month yield](#ust_3m). The dashboard shows it
unchanged.

#### Reading it

There is no badge or reference line. The FRED series starts in June 1976; its highest
value was 16.95% (8 September 1981), its lowest 0.09% (5 February 2021), and it was
4.84% on 5 October 2026.

#### Use in practice

It is one leg of the [10Y–2Y curve](#curve_10y_2y) on the Recession Watch tab; comparing
it with the [3-month yield](#ust_3m) shows how far yields two years out differ from
those three months out.

#### Caveats

- **Constant maturity**, as for the 3-month yield.

{{tile ust_10y lag="the value for 6 October 2026 was available on 7 October"}}

#### What it is

The yield on US Treasury securities at a constant 10-year maturity, the long end of the
two yield curves on the Recession Watch tab.

#### Computation

Published by the Federal Reserve Board in its H.15 release, via FRED (DGS10); interpolated
by the Treasury as described for the [3-month yield](#ust_3m). The dashboard shows it
unchanged.

#### Reading it

There is no badge or reference line. The FRED series starts in January 1962; its highest
value was 15.84% (30 September 1981), its lowest 0.52% (4 August 2020), and it was 5.27%
on 6 October 2026.

#### Use in practice

It is the input to the dashboard's [realized volatility](#ust10y_realized_vol) tile and
to the bond side of the US stocks-vs-bonds tile ([Appendix A.8](#a-stocks-bonds)).

#### Caveats

- **Nominal**: for the stocks-vs-bonds tile the dashboard subtracts the Cleveland Fed's
  10-year expected inflation to get a real yield.

{{tile effr lag="the value for 6 October 2026 was available on 7 October"}}

#### What it is

The effective federal funds rate, published by the Federal Reserve Bank of New York. FRED's
notes describe the federal funds market as domestic unsecured borrowing in US dollars by
depository institutions from other depository institutions and certain other entities,
mainly government-sponsored enterprises.

#### Computation

Calculated by the New York Fed as a volume-weighted median of overnight federal funds
transactions reported in the FR 2420 Report of Selected Money Market Rates; the dashboard
shows it unchanged.

#### Reading it

There is no badge or reference line. Since 16 December 2008, when FRED's series for the
lower and upper limits of the FOMC's federal funds target range begin, the rate has been
inside the range on all but four of 4,474 days (16 and 31 December 2015, 14 December 2016 and 17 September 2019). On
6 October 2026 it was 3.88%, in a target range of 3.75–4.00%.

#### Use in practice

Because it has stayed inside the FOMC's target range, its level shows where the FOMC has
set policy.

#### Caveats

- **The FRED series starts in July 2000**; FRED's notes point to daily federal funds rate
  data for 1928–1954 elsewhere.

{{tile ecb_policy_rate lag="changes on the dates the ECB sets; the latest change took effect on 16 September 2026"}}

#### What it is

The ECB's deposit facility rate: the rate on the deposit facility, which banks may use to
make overnight deposits with the Eurosystem. The ECB's key-rates page says the Governing
Council decided in March 2024 to continue to steer the monetary policy stance through
this rate.

#### Computation

From the ECB Data Portal (dataset FM, "Deposit facility - date of changes (raw data) -
Level"); the dashboard shows it unchanged as a step series. The registry's frequency for
this tile is *event*, so it never shows the amber freshness dot.

#### Reading it

There is no badge or reference line. In the ECB's data since 1999:

- the rate was negative from 11 June 2014 (−0.10%) until 27 July 2022, when it rose to
  0%; it was −0.50% from 18 September 2019;
- it rose to 4.00% on 20 September 2023 and held there until 12 June 2024;
- it was cut to 2.00% by 11 June 2025, and raised to 2.25% on 17 June 2026 and 2.50% on
  16 September 2026.

#### Use in practice

Compare it with the [3-month AAA yield](#rate_3m_euro), which markets set from day to
day.

#### Caveats

- **A step series**: the value changes only on decision dates.

{{tile ea_10y lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

The ECB's "long-term interest rate for convergence purposes" for the euro area: a 10-year
government bond yield for the euro area in its changing composition, in euros.

#### Computation

From the ECB Data Portal (dataset IRS); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From December 1990 its highest monthly value was
10.16% (August 1992) and its lowest −0.22% (December 2020); it was 3.60% in August 2026.

#### Use in practice

Compare it with the [German](#de_10y), [French](#fr_10y) and [Italian](#it_10y) yields
below.

#### Caveats

- **Changing composition**: the euro area's membership changes over the series'
  history.

{{tile de_10y lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

Germany's 10-year government bond yield, from the OECD's long-term interest rate series
("Long-Term Government Bond Yields: 10-Year: Main (Including Benchmark)").

#### Computation

Published by the OECD via FRED (IRLTLT01DEM156N); monthly, in percent. The dashboard shows
it unchanged.

#### Reading it

There is no badge or reference line. From May 1956 its highest value was 10.80% (July
1974) and its lowest −0.65% (August 2019); it was below zero in 38 months between June
2016 and January 2022, and was 3.18% in August 2026.

#### Use in practice

It is the base for the spreads of the [French](#fr_10y) and [Italian](#it_10y) yields
discussed below.

#### Caveats

- **Monthly averages via FRED** rather than daily market yields.

{{tile fr_10y lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

France's 10-year government bond yield, from the same OECD series as Germany's.

#### Computation

Published by the OECD via FRED (IRLTLT01FRM156N); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. Its spread over Germany's yield, computed from the
two monthly series since January 1999, was widest at 1.54 percentage points (November
2011) and narrowest at 0.02 (January 2005); in August 2026 it was 0.82, with the French
yield at 4.00%.

#### Use in practice

The dashboard shows the levels; the spread over Germany's yield can be read by comparing
the two tiles.

#### Caveats

- **Monthly averages via FRED.**

{{tile it_10y lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

Italy's 10-year government bond yield, from the same OECD series.

#### Computation

Published by the OECD via FRED (IRLTLT01ITM156N); the dashboard shows it unchanged. The
FRED series starts in March 1991.

#### Reading it

There is no badge or reference line. Its spread over Germany's yield, computed from the
two monthly series since January 1999, was widest at 5.18 percentage points (November
2011) and narrowest at 0.13 (February 2005); in August 2026 it was 0.81, with the Italian
yield at 3.99%.

#### Use in practice

As for France, the spread over Germany's yield can be read by comparing the tiles.

#### Caveats

- **Monthly averages via FRED.**

{{tile uk_10y lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

The UK's 10-year government bond yield, from the same OECD series.

#### Computation

Published by the OECD via FRED (IRLTLT01GBM156N); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From January 1960 its highest value was 16.34%
(October 1981) and its lowest 0.21% (July 2020); it was 4.99% in August 2026.

#### Use in practice

Compare it with the UK's short rate, [SONIA](#rate_3m_uk).

#### Caveats

- **Monthly averages via FRED.**

{{tile jp_10y lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

Japan's 10-year government bond yield, from the same OECD series.

#### Computation

Published by the OECD via FRED (IRLTLT01JPM156N); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From January 1989 its highest value was 8.03%
(September 1990) and its lowest −0.28% (August 2019); it was below zero in 24 months
between February 2016 and April 2020, and was 2.94% in August 2026.

#### Use in practice

Compare it with Japan's policy rate, the [overnight call rate](#rate_3m_japan).

#### Caveats

- **Monthly averages via FRED.**

{{tile ca_10y lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

Canada's 10-year government bond yield, from the same OECD series.

#### Computation

Published by the OECD via FRED (IRLTLT01CAM156N); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From January 1955 its highest value was 17.00%
(September 1981) and its lowest 0.52% (July 2020); it was 3.67% in August 2026.

#### Use in practice

Compare it with Canada's [3-month rate](#rate_3m_canada) and the [US 10-year
yield](#ust_10y).

#### Caveats

- **Monthly averages via FRED.**

{{tile rate_3m_euro lag="the value for 6 October 2026 was available on 7 October"}}

#### What it is

The 3-month spot rate of the ECB's AAA yield curve: the yield on euro-area government
bonds of all issuers rated triple A, at a 3-month maturity, estimated each day.

#### Computation

From the ECB Data Portal (dataset YC; Svensson model, continuous compounding); the
dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From September 2004 its highest value was 4.33%
(14 August 2008) and its lowest −0.93% (29 December 2016); it was 2.54% on 6 October 2026.

#### Use in practice

Compared with the [deposit facility rate](#ecb_policy_rate) in force each day since
September 2004, it was on average 0.12 percentage points higher (standard deviation
0.48); over the last 250 observations to October 2026 the average difference was 0.05.

#### Caveats

- **Model-based**: a point on a fitted curve, not a traded bill.

{{tile rate_3m_uk lag="the value for 5 October 2026 was available by 7 October"}}

#### What it is

SONIA, the Sterling Overnight Index Average. The Bank of England, which administers it,
describes it as based on actual transactions and reflecting the average of the interest
rates that banks pay to borrow sterling overnight from other financial institutions and
other institutional investors. It is published every London business day.

#### Computation

From the Bank of England's database (IUDSOIA, "Daily Sterling overnight index average
(SONIA) rate"); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From 23 April 2018 to October 2026 it was within
0.12 percentage points of Official Bank Rate (IUDBEDR) on every day, on average 0.05
below it; it was 3.73% on 5 October 2026, with Bank Rate at 3.75%.

#### Use in practice

Because it stays close to Bank Rate, its level shows where the Bank of England has set
policy.

#### Caveats

- **Overnight**: despite the tile's id it is an overnight rate, not a 3-month rate.

{{tile rate_3m_japan lag="the value for 5 October 2026 was available by 7 October"}}

#### What it is

The uncollateralized overnight call rate (average), published by the Bank of Japan. It
is the rate the Bank's guideline for money market operations targets: on 18 September
2026 the Bank raised its short-term policy rate to "around 1.25%" (uncollateralized
overnight call rate), from "around 1.0%".

#### Computation

From the Bank of Japan's statistics (FM01, STRDCLUCON); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. In the Bank of Japan's data from January 1998 it was
below zero on every day from 17 March 2016 to 19 March 2024; it was 0.98% before the
September 2026 decision and 1.23% from 24 September 2026.

#### Use in practice

It shows the Bank of Japan's policy stance directly; compare it with Japan's
[10-year yield](#jp_10y).

#### Caveats

- **Overnight**, not a 3-month rate, despite the tile's id.

{{tile rate_3m_canada lag="August 2026 was the latest on 7 October 2026"}}

#### What it is

Canada's 3-month interbank rate, from the OECD's short-term interest rate series
("3-Month or 90-Day Rates and Yields: Interbank Rates").

#### Computation

Published by the OECD via FRED (IR3TIB01CAM156N); monthly, in percent. The dashboard shows
it unchanged.

#### Reading it

There is no badge or reference line. From January 1956 its highest value was 22.01%
(August 1981) and its lowest 0.06% (January 2021); it was 2.28% in August 2026.

#### Use in practice

Compare it with Canada's [10-year yield](#ca_10y).

#### Caveats

- **Monthly, via FRED**, rather than daily.
