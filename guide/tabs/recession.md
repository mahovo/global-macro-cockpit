<!-- Recession Watch. Every statement is sourced; see .claude/guide_checklist.md.
     Code: R/views.R, R/display.R, R/assess.R (BADGE_BANDS), instructions/sources.yaml
     (indicator classes). Publisher documentation: FRED series notes (T10Y3M, T10Y2Y,
     SAHMREALTIME, RECPROUSM156N); Estrella and Trubin (2006, NY Fed Current Issues 12-5, PDF);
     NY Fed Prob_Rec file (updated 2026-09-06); Piger's recession-probability page and FAQ
     (jeremypiger.com); Hamilton Project page for Sahm (2019); NBER business-cycle dates
     (data.nber.org JSON and the NBER dating page).
     Signal timings: computed 2026-10-07 from FRED data (monthly averages of T10Y3M, T10Y2Y;
     SAHMREALTIME; RECPROUSM156N) against the NBER peaks and troughs. Data lags: latest dates
     in the cache on 2026-10-07. -->

{{tab recession}}

Four US recession signals kept together so they can be read as a set. The dashboard
classes the two yield curves as *leading* and the Sahm rule and the recession probability
as *coincident*, and their histories bear that out:

- **The yield curves.** Before each recession since the [10Y–3M](#curve_10y_3m) series
  began in 1982, its monthly average turned negative 8 to 16 months before the NBER's
  business-cycle peak. The [10Y–2Y](#curve_10y_2y) did so 10 to 22 months before each
  peak from 1980 to 2007, but not before the February 2020 peak.
- **The Sahm rule and the recession probability.** The [Sahm rule](#sahm_realtime)
  crossed its 0.5 trigger between two months before and four months after each peak
  from 1969 to 2020. The [recession probability](#recession_prob_chauvet_piger) reached
  50% one to eight months after each peak in that period except 2001, when its highest
  value was 30%.

The tiles below give the dates for each recession. The NBER, which dates US business
cycles, treats the months from a peak in economic activity to the following trough as a
recession; its most recent peak is February 2020 and its most recent trough April 2020.

The sidebar's **Recession signals** count (red badges on this tab) and **Cautions** count
(amber badges) summarise the tab ([Appendix A.3](#a-status)).

<!-- tiles -->

{{tile curve_10y_3m lag="the value for 6 October 2026 was available on 7 October"}}

#### What it is

The 10-year Treasury yield minus the 3-month Treasury yield. A negative value, an
*inverted* curve, means the 10-year yield is below the 3-month yield.

#### Computation

FRED computes the spread from the Treasury Department's constant-maturity yields; the
dashboard shows it unchanged. With $y^{10y}_t$ and $y^{3m}_t$ the 10-year and 3-month
constant-maturity yields on day $t$, in percent:

$$
S_t = y^{10y}_t - y^{3m}_t .
$$

The FRED series starts in January 1982.

#### Reading it

{{badge curve_10y_3m var="S_n"}}

The reference line is at zero. The 0.5-point boundary between "flat" and "positively
sloped" is the dashboard's own convention.

#### Use in practice

**What the research found.** Estrella and Trubin (2006), at the New York Fed, examined
this spread as a recession predictor and reported that:

- the monthly average of the 10-year minus 3-month spread turned negative before each
  recession from January 1968 to July 2006;
- all six recessions since 1968 were preceded by at least three negative monthly
  averages in the twelve months before the recession began, and inversion on a
  monthly-average basis gave no false signals over that period;
- inversions seen only in daily or intraday data often proved false signals, so the
  spread is best read on at least a monthly average.

The New York Fed publishes a monthly
[probability of recession twelve months ahead](https://www.newyorkfed.org/medialibrary/media/research/capital_markets/Prob_Rec.xlsx)
computed from this spread's monthly average; its update of 6 September 2026 put the
probability for August 2027 at 13.9%.

**What the FRED series shows.** Monthly averages of this tile's series around each
NBER peak since it began:

| NBER peak | First negative month | Lead (months) | Negative months in the 12 before the peak | First month back above zero |
|---|---|---|---|---|
| Jul 1990 | Jun 1989 | 13 | 4 | Jan 1990 (6 months before the peak) |
| Mar 2001 | Jul 2000 | 8 | 7 | Feb 2001 (1 month before) |
| Dec 2007 | Aug 2006 | 16 | 6 | Jun 2007 (6 months before) |
| Feb 2020 | May 2019 | 9 | 5 | Mar 2020 (1 month after) |

Every negative monthly average in this series up to 2020 came within 16 months before an
NBER peak. Since then the monthly average was negative from November 2022 to November
2024 (25 months) and again in March–April and June–August 2025, and no NBER peak has
been dated as of October 2026. In daily data the spread was below zero continuously from
25 October 2022 to 12 December 2024.

#### Caveats

- **Not the researchers' exact measure.** Estrella and Trubin obtained their best results
  with the secondary-market 3-month bill rate on a bond-equivalent basis; this tile, like
  FRED's series, uses the constant-maturity 3-month yield.
- **US only.** Other economies' yields are on the Credit & Rates tab.

{{tile curve_10y_2y lag="the value for 6 October 2026 was available on 7 October"}}

#### What it is

The 10-year Treasury yield minus the 2-year Treasury yield, the other common measure of
the curve's slope.

#### Computation

FRED computes the spread from the Treasury Department's constant-maturity yields; the
dashboard shows it unchanged:

$$
S_t = y^{10y}_t - y^{2y}_t .
$$

The FRED series starts in June 1976.

#### Reading it

The same badge rules as the 10Y–3M curve:

{{badge curve_10y_2y var="S_n"}}

Estrella and Trubin (2006) note that this spread tends to turn negative earlier and more
often than the 10-year minus 3-month spread, which is usually larger.

#### Use in practice

Monthly averages of this tile's series around each NBER peak since it began:

| NBER peak | First negative month | Lead (months) | Negative months in the 12 before the peak | First month back above zero |
|---|---|---|---|---|
| Jan 1980 | Sep 1978 | 16 | 12 | May 1980 (4 months after the peak) |
| Jul 1981 | Sep 1980 | 10 | 10 | Nov 1981 (4 months after) |
| Jul 1990 | Jan 1989 | 18 | 3 | Apr 1990 (3 months before) |
| Mar 2001 | Feb 2000 | 13 | 10 | Jan 2001 (2 months before) |
| Dec 2007 | Feb 2006 | 22 | 5 | Jun 2007 (6 months before) |
| Feb 2020 | none | — | 0 | — |

Before the February 2020 peak the monthly average did not turn negative; the daily
spread was below zero on three days, 27–29 August 2019. The 10Y–3M monthly average, by
contrast, was negative for five months before that peak.

#### Caveats

- **Inversions without a following recession.** The monthly average was also negative in
  June 1998 and from July 2022 to August 2024 (26 months); no NBER peak followed within
  24 months of either. It was negative from February to June 1982 too, inside the
  1981–82 recession.
- **US only.**

{{tile sahm_realtime lag="the September 2026 value was available on 7 October 2026"}}

#### What it is

A recession indicator from the unemployment rate alone. Claudia Sahm proposed it in a
Hamilton Project policy proposal of 16 May 2019 as the trigger for stimulus payments to
individuals, to be paid when the three-month average national unemployment rate rose by
at least 0.50 percentage points above its low of the previous 12 months.

#### Computation

Published by Claudia Sahm on FRED. With $u_t$ the US unemployment rate (U-3, %) and
$\bar u_t$ its three-month average,

$$
\bar u_t = \tfrac{1}{3}\left(u_t + u_{t-1} + u_{t-2}\right), \qquad
\text{Sahm}_t = \bar u_t - \min\left(\bar u_{t-1}, \dots, \bar u_{t-12}\right),
$$

in percentage points. FRED's notes describe the series as real-time: each month's value
uses the unemployment rates available in that month. They add that the BLS revises the
unemployment rate each year in January, when it publishes the December rate, and that
otherwise the rate isn't revised. Because the low is taken over the previous twelve
months, the value can be negative.

#### Reading it

{{badge sahm_realtime var="\text{Sahm}_n"}}

The reference line marks the rule's 0.5-point trigger. The 0.3 "watch" level is the
dashboard's own.

#### Use in practice

The first month the series crossed 0.5 around each NBER peak (FRED data from December
1959):

| NBER peak | First month at or above 0.5 | Relative to the peak |
|---|---|---|
| Apr 1960 | Dec 1959 (the series' first month, already 0.77) | 4 months before |
| Dec 1969 | Oct 1969 | 2 months before |
| Nov 1973 | Mar 1974 | 4 months after |
| Jan 1980 | Apr 1980 | 3 months after |
| Jul 1981 | Nov 1981 | 4 months after |
| Jul 1990 | Nov 1990 | 4 months after |
| Mar 2001 | Jun 2001 | 3 months after |
| Dec 2007 | Apr 2008 | 4 months after |
| Feb 2020 | Apr 2020 | 2 months after |

It was at or above 0.5 at two other times: November 1976 (one month) and July to
September 2024 (0.53, 0.57 and 0.50). No NBER peak followed either, as of October 2026.

#### Caveats

- **It confirms rather than predicts.** From 1969 to 2020 it crossed the trigger between
  two months before and four months after the peak.
- **Monthly and US only.**

{{tile recession_prob_chauvet_piger lag="the August 2026 value was released on 30 September 2026"}}

#### What it is

The estimated probability, in percent, that the US economy was in recession in a given
month, from a statistical model of four monthly measures of activity.

#### Computation

Published by Jeremy Piger on FRED; the dashboard shows it unchanged. Piger's FAQ and FRED's
notes describe it as a smoothed probability from a dynamic-factor Markov-switching model
applied to four monthly coincident variables: non-farm payroll employment, the index of
industrial production, real personal income excluding transfer payments, and real
manufacturing and trade sales. The model was developed in Chauvet (1998); Piger estimates
it with Bayesian methods. The value for month $t$ is

$$
p_t = 100 \cdot P\left(\text{recession in month } t \mid \text{data available at the latest release}\right).
$$

The FAQ says the probabilities are updated each time a full month of data for all four
series is available, generally on or just before the first of each month, and that since
the release of 23 December 2020 the model allows its parameters to change for March to
July 2020. Releases are posted on [Piger's page](https://jeremypiger.com/recession_probs/).

#### Reading it

{{badge recession_prob_chauvet_piger var="p_n"}}

The 20% and 50% boundaries are the dashboard's own. Piger's FAQ gives a different rule:
three consecutive months above 80% has historically been a reliable signal that a
recession has started, and three consecutive months below 20% that an expansion has
started.

#### Use in practice

From the current FRED series (back to June 1967) around each NBER peak:

| NBER peak | First month at or above 50% | First month at or above 80% | Highest value in the recession |
|---|---|---|---|
| Dec 1969 | Jan 1970 (1 month after) | Oct 1970 (10 after) | 80.5% |
| Nov 1973 | Jul 1974 (8 after) | Aug 1974 (9 after) | 100% |
| Jan 1980 | Mar 1980 (2 after) | Mar 1980 (2 after) | 99.6% |
| Jul 1981 | Sep 1981 (2 after) | Sep 1981 (2 after) | 94.3% |
| Jul 1990 | Oct 1990 (3 after) | never | 63.9% |
| Mar 2001 | never | never | 30.4% |
| Dec 2007 | Mar 2008 (3 after) | May 2008 (5 after) | 100% |
| Feb 2020 | Mar 2020 (1 after) | Mar 2020 (1 after) | 100% |

In the 618 months outside recessions, the probability was below 2% in 93% of them and
below 5% in 98%; its highest value outside a recession was 40.9%, in November 1969, the
month before the December 1969 peak.

#### Caveats

- **Revisions.** Piger's FAQ explains that smoothed probabilities are revised as new data
  arrive and earlier data are revised, which smooths away some of the spikes seen in real
  time. The table uses today's smoothed series, not the values published at the time; in
  it, the 1990 and 2001 recessions never reach 80%.
- **Coincident.** It describes the current month rather than forecasting.
