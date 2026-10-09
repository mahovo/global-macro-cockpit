<!-- Consumer & Housing. Every statement is sourced; see .claude/guide_checklist.md.
     Code: R/views.R, R/display.R, R/fetch.R (retail_sales_control_group = .yoy_tile("RRSFS")),
     instructions/sources*.yaml (classes; new_home_sales and mortgage_rate_30y replace NAHB and MBA).
     Publisher documentation: FRED notes, units and copyright tags (UMCSENT, PERMIT, HOUST, HSN1F,
     MORTGAGE30US, RRSFS, RSAFS); Census new residential construction release of 17 Sep 2026 and
     new residential sales release of 24 Sep 2026; Census advance retail sales page (August 2026);
     University of Michigan Surveys of Consumers home page (preliminary October 2026); Freddie Mac
     PMMS page (8 Oct 2026, methodology).
     History: computed 2026-10-09 (scratch consumer.R); FRED PERMIT updated 24 Sep 2026. -->

{{tab consumer}}

US households and housing:

- **Sentiment**: the University of Michigan's [consumer sentiment](#umich_sentiment)
  index.
- **Housing**: [building permits](#building_permits), [housing starts](#housing_starts)
  and [new home sales](#new_home_sales) from the Census Bureau and HUD, and the
  [30-year mortgage rate](#mortgage_rate_30y) from Freddie Mac.
- **Spending**: [real retail sales](#retail_sales_control_group), the Census Bureau's
  advance retail and food services sales deflated by CPI.

The dashboard classes all but retail sales as leading indicators and real retail sales as
coincident. None of the tiles carries a badge. The three housing measures are seasonally
adjusted annual rates, the form in which the Census Bureau reports them.

<!-- tiles -->

{{tile umich_sentiment lag="monthly; FRED shows it a month late at the source's request (August 2026 was the latest on FRED on 9 October 2026)"}}

#### What it is

The University of Michigan's Index of Consumer Sentiment, from its Surveys of Consumers
(1966 first quarter = 100).

#### Computation

Published by the University of Michigan via FRED (UMCSENT); the dashboard shows it
unchanged. FRED's notes say the data are delayed by one month at the request of the
source.

#### Reading it

There is no badge or reference line. FRED's series begins in November 1952, with only 92
observations before 1978, and is monthly from 1978. Its highest value was 112.0 (January
2000) and its lowest 44.8 (May 2026); the latest on FRED was 51.7, for August 2026. The
University's own site gave a preliminary 46.3 for October 2026, against 48.1 for September
and 53.6 for October 2025.

#### Use in practice

The University also publishes indexes of current economic conditions and of consumer
expectations (44.7 and 47.3 in the preliminary October 2026 results); the tile shows the
overall sentiment index.

#### Caveats

- **A month behind on FRED**, as above.
- **A survey index**, not a measure of spending; compare it with
  [real retail sales](#retail_sales_control_group).

{{tile building_permits lag="monthly; August 2026 was available by 9 October 2026"}}

#### What it is

New privately owned housing units authorized by building permits, in thousands at a
seasonally adjusted annual rate (Census Bureau and HUD).

#### Computation

Published by the Census Bureau and HUD via FRED (PERMIT); the dashboard shows it
unchanged. FRED's notes say the universe of permit-issuing places rose from 19,000 to
20,000 places with the release of 16 February 2005.

#### Reading it

There is no badge or reference line. From January 1960 the rate ranged from 513,000 (March
2009) to 2,419,000 (December 1972). For August 2026 the Census release of 17 September gave
1,394,000; FRED's series, updated on 24 September, shows 1,403,000.

#### Use in practice

Its highest month in the 36 months before each NBER peak since 1969:

| NBER peak | Highest month | Months before the peak |
|---|---|---|
| Dec 1969 | Feb 1969 | 10 |
| Nov 1973 | Dec 1972 | 11 |
| Jan 1980 | Jun 1978 | 19 |
| Jul 1981 | Dec 1978 | 31 |
| Jul 1990 | Jan 1990 | 6 |
| Mar 2001 | Dec 1998 | 27 |
| Dec 2007 | Sep 2005 | 27 |
| Feb 2020 | Nov 2019 | 3 |

#### Caveats

- **Figures change after release**: the August 2026 example above.

{{tile housing_starts lag="monthly; August 2026 was available by 9 October 2026"}}

#### What it is

New privately owned housing units started, in thousands at a seasonally adjusted annual
rate (Census Bureau and HUD). FRED's notes: a start occurs when excavation begins for the
footings or foundation of a building, and all units in a multifamily building count as
started at that point.

#### Computation

Published by the Census Bureau and HUD via FRED (HOUST); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From January 1959 the rate ranged from 478,000 (April
2009) to 2,494,000 (January 1972); in August 2026 it was 1,275,000. The Census release of
17 September 2026 put August 2.6% below July, with a range of ±12.0% attached to that
change.

#### Use in practice

Its highest month in the 36 months before each NBER peak since 1969:

| NBER peak | Highest month | Months before the peak |
|---|---|---|
| Dec 1969 | Jan 1969 | 11 |
| Nov 1973 | Jan 1972 | 22 |
| Jan 1980 | Apr 1978 | 21 |
| Jul 1981 | Nov 1978 | 32 |
| Jul 1990 | Sep 1987 | 34 |
| Mar 2001 | Dec 1998 | 27 |
| Dec 2007 | Jan 2006 | 23 |
| Feb 2020 | Jan 2020 | 1 |

#### Caveats

- **Wide sampling ranges**: in August 2026 the monthly changes in starts and new home
  sales were smaller than the ranges Census attached to them; read the trend.

{{tile new_home_sales lag="monthly; August 2026 was available by 9 October 2026"}}

#### What it is

New single-family houses sold, in thousands at a seasonally adjusted annual rate (Census
Bureau and HUD). The dashboard uses it in place of the licensed NAHB builder survey of the
original design.

#### Computation

Published by the Census Bureau and HUD via FRED (HSN1F); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From January 1963 the rate ranged from 270,000
(February 2011) to 1,389,000 (July 2005); in August 2026 it was 684,000. The Census release
of 24 September 2026 put August 6.4% above July, with a range of ±19.5% attached to that
change, and the seasonally adjusted number of new houses for sale at the end of August at
483,000.

#### Use in practice

Its highest month in the 36 months before each NBER peak since 1969:

| NBER peak | Highest month | Months before the peak |
|---|---|---|
| Dec 1969 | Oct 1967 | 26 |
| Nov 1973 | Oct 1972 | 13 |
| Jan 1980 | Mar 1977 | 34 |
| Jul 1981 | Oct 1978 | 33 |
| Jul 1990 | Jul 1989 | 12 |
| Mar 2001 | Nov 1998 | 28 |
| Dec 2007 | Jul 2005 | 29 |
| Feb 2020 | Jun 2019 | 8 |

#### Caveats

- **Wide sampling ranges**, as for starts.

{{tile mortgage_rate_30y lag="weekly, as of Thursday; 8 October 2026 was available by 9 October"}}

#### What it is

Freddie Mac's 30-year fixed-rate mortgage average in the United States, from its Primary
Mortgage Market Survey, weekly. The dashboard uses it in place of the licensed MBA
mortgage-applications index of the original design.

#### Computation

Published by Freddie Mac via FRED (MORTGAGE30US); the dashboard shows it unchanged. FRED's
notes say Freddie Mac changed the survey's method on 17 November 2022: the weekly rate is
now based on applications lenders across the country submit to Freddie Mac. Freddie Mac's
page describes the earlier survey as covering first-lien prime conventional conforming
home-purchase mortgages with a loan-to-value ratio of 80%.

#### Reading it

There is no badge or reference line. From 2 April 1971 the rate ranged from 2.65% (7
January 2021) to 18.63% (9 October 1981); on 8 October 2026 it was 7.40%.

#### Use in practice

Compare it with the [10-year Treasury yield](#ust_10y) on the Credit & Rates tab and with
[new home sales](#new_home_sales).

#### Caveats

- **Method change in November 2022**, as above.

{{tile retail_sales_control_group lag="monthly; August 2026 was available by 9 October 2026"}}

#### What it is

Real retail and food services sales: the Census Bureau's advance retail and food services
sales, deflated by the consumer price index, shown as the change over twelve months. The
St. Louis Fed computes the real series (FRED RRSFS, millions of 1982–84 dollars) from the
Census series RSAFS and CPI (CPIAUCSL).

#### Computation

Computed by the dashboard from RRSFS ([Appendix A.1](#a-notation)):

$$
g_t = 100\left(\frac{S_t}{S_{t-12}} - 1\right),
$$

for months where both are published. FRED's CPI has no October 2025 value, so RRSFS has
none, and the tile has no value for October 2025 or October 2026. FRED's notes add that the
latest month is an advance estimate from a subsample of firms, later replaced by the full
Monthly Retail Trade Survey.

#### Reading it

The reference line is at zero; there is no badge. From January 1993 the rate ranged from
−19.9% (April 2020) to +45.8% (April 2021) and was negative in 16% of months; in August
2026 it was 2.6%. In nominal terms the Census Bureau reported August 2026 sales of \$773.9
billion, 6.0% above a year earlier.

#### Use in practice

At the NBER peaks in its history the rate was −2.6% (March 2001), −1.2% (December 2007)
and +2.4% (February 2020). It was also negative in many months of 2023 and 2024 without a
recession.

#### Caveats

- **Not the control group.** Despite the tile's internal id, it covers all retail and
  food services sales.
- **Deflated by the overall CPI**, which includes services that retail sales don't cover.
