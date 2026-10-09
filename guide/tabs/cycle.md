<!-- Cycle & Growth. Every statement is sourced; see .claude/guide_checklist.md.
     Code: R/views.R, R/display.R, R/assess.R (REGIMES, assess_cli, BADGE_PARAMS$cli),
     R/fetch.R (.regime_series, .regime_fetch, .cli_euro_area, .yoy_tile), R/tiles.R
     (regime_body, regime_quadrant, regime_strip), scripts/build_site.R (site_from, strip zoom),
     instructions/sources*.yaml (classes, PMI urls).
     Publisher documentation: OECD DF_CLI dataflow description (SDMX API; oecd.org itself refuses
     automated requests); Bridgewater "The All Weather Story"; FRED notes (NEWORDER, INDPRO,
     A191RL1Q225SBEA, GACDISA066MSFRBNY, GACDFSA066MSFRBPHI); NY Fed Empire State survey overview
     and September 2026 report; BEA GDP page (Q2 2026 third estimate). S&P Global's PMI pages refuse
     automated requests: PMI facts are pending.
     History: computed 2026-10-09 (scratch cycle.R). -->

{{tab cycle}}

Where the cycle is heading and how fast, from three angles:

- **Growth and inflation regimes.** The first five tiles place the
  [US](#growth_inflation_regime), the [euro area](#regime_euro_area), the
  [UK](#regime_uk), [Japan](#regime_japan) and [China](#regime_china) in one of four
  regimes, combining the direction of a leading indicator with the direction of
  inflation.
- **Leading indicators.** The OECD's composite leading indicators for the
  [G20](#oecd_cli), the [US](#cli_usa), the [G7](#cli_g7), the [UK](#cli_uk),
  [Japan](#cli_japan) and [Germany](#cli_germany), with the licensed purchasing managers'
  indices for the [euro area](#pmi_euro), the [UK](#pmi_uk) and [Japan](#pmi_japan) as
  links.
- **US activity.** [Core capital goods orders](#core_capex_orders), the
  [Empire State](#empire_state_mfg) and [Philadelphia Fed](#philly_fed_mfg) manufacturing
  surveys, [industrial production](#industrial_production) and [real GDP](#real_gdp). The
  dashboard classes the orders and surveys as leading, industrial production as
  coincident and GDP as lagging.

The OECD describes its leading indicators as built from component series that show a
reasonably consistent relationship with a reference series (GDP since March 2012,
industrial production before) at turning points. It says they give qualitative rather
than quantitative information, so their main message is whether they rise or fall, and
that turning points in the reference series have been found about 4 to 8 months, on
average, after the indicator signalled them.

<!-- tiles -->

{{tile growth_inflation_regime lag="monthly; August 2026 was the latest month on 9 October 2026"}}

#### What it is

Which of four growth-and-inflation regimes the US economy is in, month by month. The idea
comes from Bridgewater Associates, whose account of its All Weather strategy describes
four economic environments: inflation rising, inflation falling, growth rising and growth
falling, each relative to expectations. The tile measures direction instead of surprises,
and the four names are the dashboard's own.

#### Computation

Computed by the dashboard ([Appendix A.10](#a-regimes)) from the OECD composite leading
indicator for the US and CPI inflation:

$$
g_t = \text{CLI}_t - \text{CLI}_{t-3}, \qquad
m_t = \pi_t - \frac{1}{12}\sum_{k=0}^{11}\pi_{t-k},
$$

with $\pi_t$ CPI inflation over twelve months. Growth is rising when $g_t > 0$ and
inflation when $m_t > 0$. FRED has no October 2025 CPI; the tile fills that month in
log-linearly.

#### Reading it

{{badge growth_inflation_regime}}

The tile shows the current regime, the month its spell began and the regime before it.
Below it, a strip colours every month by regime; pick a period with the strip's handles,
by dragging across the strip or, on the public site, with the zoom, and the quadrant above
traces that period, its last twelve months dark. On the public site the history starts in
1960. In August 2026 the US was in Reflation, since March 2026 and after Goldilocks:
$g = +0.30$ and $m = +0.24$ (CPI inflation 3.35% against a 12-month average of 3.12%).

#### Use in practice

From January 1960 to August 2026 (800 months):

- the regime changed 158 times, about 2.4 times a year, and the median spell lasted
  3 months;
- Goldilocks covered 30% of months, Stagflation 29%, Reflation 21% and Disinflationary
  slowdown 20%.

The regime in the month of each NBER business-cycle peak since 1969:

| NBER peak | Regime |
|---|---|
| Dec 1969 | Stagflation |
| Nov 1973 | Stagflation |
| Jan 1980 | Stagflation |
| Jul 1981 | Disinflationary slowdown |
| Jul 1990 | Stagflation |
| Mar 2001 | Disinflationary slowdown |
| Dec 2007 | Stagflation |
| Feb 2020 | Reflation |

The dashboard's inflation rule changes regime less often than a common alternative:
since 1970 the tile changes regime 2.28 times a year, while the same tile with inflation
momentum measured as the 3-month change in CPI inflation would change 3.23 times a year.

#### Caveats

- **Direction only.** A tiny positive $g_t$ or $m_t$ counts as rising; the quadrant shows
  how far from zero each month is.
- **Revisions.** The OECD revises recent months of its leading indicators, so recent
  months' regimes can change.

{{tile regime_euro_area lag="monthly; September 2026 was the latest month on 9 October 2026"}}

#### What it is

The four regimes for the euro area, built like the [US tile](#growth_inflation_regime).

#### Computation

Growth: the 3-month change in a euro-area leading indicator that the dashboard builds from
the OECD indicators for Germany, France, Italy and Spain, weighted by nominal GDP; the
OECD's dataset has no euro-area series ([Appendix A.10](#a-regimes)). Inflation: Eurostat's
HICP annual rate for the euro area in its changing composition, minus its average over
the past 12 months.

#### Reading it

The same rules as the US tile. The history starts in December 1997. In September 2026 the
euro area was in Reflation, since August 2026 and after Stagflation ($g = +0.16$,
$m = +1.19$; HICP inflation 3.8% against a 12-month average of 2.61%).

#### Use in practice

From December 1997 to September 2026 (346 months) the regime changed 63 times, about 2.2
times a year, with a median spell of 4 months. Goldilocks covered 29% of months,
Reflation 26%, Disinflationary slowdown 25% and Stagflation 21%.

#### Caveats

- **A constructed indicator.** The growth input covers four countries, weighted by GDP.

{{tile regime_uk lag="monthly; August 2026 was the latest month on 9 October 2026"}}

#### What it is

The four regimes for the UK, built like the [US tile](#growth_inflation_regime).

#### Computation

Growth: the 3-month change in the OECD composite leading indicator for the UK.
Inflation: the ONS CPI annual rate (D7G7), minus its average over the past 12 months.

#### Reading it

The same rules as the US tile. The history starts in December 1989, as the ONS CPI annual
rate begins in January 1989. In August 2026 the UK was in Goldilocks, since June 2026 and
after Disinflationary slowdown ($g = +0.70$, $m = -0.03$).

#### Use in practice

From December 1989 to August 2026 (441 months) the regime changed 94 times, about 2.6 times
a year, with a median spell of 3 months. Goldilocks covered 29% of months, Disinflationary
slowdown 25%, Stagflation 24% and Reflation 22%.

#### Caveats

- **Close calls.** In August 2026 inflation momentum was −0.03, close to the boundary.

{{tile regime_japan lag="monthly; August 2026 was the latest month on 9 October 2026"}}

#### What it is

The four regimes for Japan, built like the [US tile](#growth_inflation_regime).

#### Computation

Growth: the 3-month change in the OECD composite leading indicator for Japan. Inflation:
CPI inflation from the IMF's CPI dataset, minus its average over the past 12 months.

#### Reading it

The same rules as the US tile. The history starts in 1960. In August 2026 Japan was in
Goldilocks, since August 2026 and after Reflation ($g = +0.14$, $m = -0.01$).

#### Use in practice

From January 1960 to August 2026 (800 months) the regime changed 174 times, about 2.6
times a year, with a median spell of 3 months. Goldilocks covered 29% of months,
Stagflation 26%, Disinflationary slowdown 23% and Reflation 22%.

#### Caveats

- **Inflation from a copy.** The IMF's figures are not Japan's statistics bureau's own
  release.

{{tile regime_china lag="monthly; August 2026 was the latest month on 9 October 2026"}}

#### What it is

The four regimes for China, built like the [US tile](#growth_inflation_regime). The rule
reads direction, not level, so inflation rising from below 1% still counts as rising.

#### Computation

Growth: the 3-month change in the OECD composite leading indicator for China. Inflation:
CPI inflation from the IMF's CPI dataset, minus its average over the past 12 months.

#### Reading it

The same rules as the US tile. The history starts in December 1994. In August 2026 China
was in Stagflation, since August 2026 and after Disinflationary slowdown ($g = -0.78$,
$m = +0.07$; CPI inflation 0.80% against a 12-month average of 0.73%).

#### Use in practice

From December 1994 to August 2026 (381 months) the regime changed 78 times, about 2.5 times
a year, with a median spell of 3 months. Goldilocks covered 29% of months, Stagflation
26%, Disinflationary slowdown 24% and Reflation 21%.

#### Caveats

- **Level versus direction.** "Stagflation" here means inflation momentum is positive; in
  August 2026 inflation itself was 0.80%.
- **Inflation from a copy**, as for Japan.

{{tile oecd_cli lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The OECD's composite leading indicator for the G20, amplitude adjusted, which the OECD
names as its headline CLI.

#### Computation

From the OECD's data API (dataset DF_CLI, area G20, amplitude adjusted, OECD harmonised
methodology); the dashboard shows it unchanged. The OECD computes CLIs for the G20
countries, Spain and five zone aggregates.

#### Reading it

{{badge oecd_cli var="\text{CLI}_n"}}

The badge rules and reading 100 as trend are the dashboard's. From January 1961 the G20
indicator averaged 100.3 and was at or above 100 in 64% of months; its highest value was
104.9 (January 1973) and its lowest 89.4 (April 2020). In September 2026 it was 100.14,
down from 100.16 the month before.

#### Use in practice

Read its direction, as the OECD advises, and compare it with the [G7](#cli_g7) and
national indicators below.

#### Caveats

- **Revised.** The OECD revises recent months.

{{tile core_capex_orders lag="monthly; August 2026 was the latest on 9 October 2026"}}

#### What it is

US manufacturers' new orders for nondefense capital goods excluding aircraft, from the
Census Bureau: the change over twelve months, in %.

#### Computation

Computed by the dashboard from the published level (NEWORDER, US\$ millions, seasonally
adjusted, from February 1992) ([Appendix A.1](#a-notation)):

$$
g_t = 100\left(\frac{O_t}{O_{t-12}} - 1\right).
$$

FRED's notes say the data were reconstructed on 21 May 2001 to switch from the SIC to the
NAICS classification.

#### Reading it

The reference line is at zero; there is no badge. From February 1993 the range was −32.1%
(April 2009) to +24.7% (April 2021); growth was positive in 67% of months. In August 2026 it
was 14.1%.

#### Use in practice

The dashboard classes it as a leading indicator; compare it with
[industrial production](#industrial_production) and the regional surveys.

#### Caveats

- **Nominal.** Orders are in current dollars, so the rate includes price changes.

{{tile cli_usa lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The OECD's composite leading indicator for the US, amplitude adjusted: the growth input
of the [US regime tile](#growth_inflation_regime).

#### Computation

From the OECD's data API (DF_CLI, area USA); the dashboard shows it unchanged.

#### Reading it

{{badge cli_usa var="\text{CLI}_n"}}

From January 1955 it averaged 100.0 and was at or above 100 in 54% of months; its highest
value was 103.8 (December 1972) and its lowest 92.9 (April 2020). In September 2026 it was
101.00, up from 100.95.

#### Use in practice

In today's series, its highest value in the 26 months before each NBER peak:

| NBER peak | Highest value in the 26 months before | Months before the peak | Value at the peak |
|---|---|---|---|
| Aug 1957 | Jul 1955 | 25 | 98.6 |
| Apr 1960 | Apr 1959 | 12 | 99.8 |
| Dec 1969 | Dec 1968 | 12 | 98.9 |
| Nov 1973 | Dec 1972 | 11 | 100.9 |
| Jan 1980 | Jul 1978 | 18 | 98.4 |
| Jul 1981 | May 1979 | 26 | 98.8 |
| Jul 1990 | Sep 1988 | 22 | 98.9 |
| Mar 2001 | Dec 1999 | 15 | 98.4 |
| Dec 2007 | Jun 2007 | 6 | 101.6 |
| Feb 2020 | Apr 2018 | 22 | 99.2 |

The indicator was below 100 at eight of these ten peaks.

#### Caveats

- **Today's series, not real time.** The OECD revises the indicator, so this history is
  not what was published at the time.

{{tile empire_state_mfg lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The New York Fed's Empire State Manufacturing Survey: the general business conditions
index for New York State, the survey's headline index (seasonally adjusted). The NY Fed
sends the survey on the first day of each month to the same pool of about 200
manufacturing executives in the state, typically the president or CEO; about 100 reply.

#### Computation

Published by the New York Fed via FRED (GACDISA066MSFRBNY); the dashboard shows it
unchanged. It is a diffusion index built from the shares of respondents reporting
increases and decreases.

#### Reading it

The reference line is at zero; there is no badge. Above zero, more firms reported
improving than worsening conditions; the NY Fed's September 2026 report described a
reading of 7.6 as business activity increasing modestly. From July 2001 the index ranged
from −80.0 (April 2020) to 39.0 (April 2004) and was positive in 67% of months.

#### Use in practice

It describes the current month: the NY Fed says most responses are completed by the
tenth. Compare it with the [Philadelphia Fed survey](#philly_fed_mfg).

#### Caveats

- **One state's manufacturers.** It covers New York manufacturing only.

{{tile philly_fed_mfg lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The Philadelphia Fed's Manufacturing Business Outlook Survey: the current general activity
diffusion index for manufacturing firms in its district (seasonally adjusted), which FRED
describes as the survey's broadest measure.

#### Computation

Published by the Philadelphia Fed via FRED (GACDFSA066MSFRBPHI); the dashboard shows it
unchanged. FRED's notes: the percentage of firms reporting increases minus the percentage
reporting decreases.

#### Reading it

The reference line is at zero; there is no badge. From May 1968 the index ranged from
−58.7 (April 2020) to 58.5 (March 1973) and was positive in 73% of months; in September
2026 it was 37.8.

#### Use in practice

Compare it with the [Empire State survey](#empire_state_mfg); together they cover two
districts' manufacturers.

#### Caveats

- **One district's manufacturers.**

{{tile industrial_production lag="monthly; August 2026 was the latest on 9 October 2026"}}

#### What it is

US industrial production: the Federal Reserve's index of the real output of
manufacturing, mining, and electric and gas utilities, shown as the change over twelve
months in %. FRED's notes add that the industrial sector, together with construction,
accounts for the bulk of the variation in national output over the business cycle.

#### Computation

Computed by the dashboard from the published index (INDPRO, 2017 = 100, seasonally
adjusted, from January 1919) ([Appendix A.1](#a-notation)).

#### Reading it

The reference line is at zero; there is no badge. From January 1920 the range was −33.7%
(February 1946) to +62.0% (July 1933); since 1960 the rate was negative in 24% of months.
In August 2026 it was 1.4%.

#### Use in practice

The dashboard classes it as coincident. Compare it with the leading tiles above it.

#### Caveats

- **Industry only**: services aren't covered.

{{tile real_gdp lag="quarterly; the third estimate for the second quarter of 2026 was the latest on 9 October 2026"}}

#### What it is

US real GDP growth as BEA reports it in its headline: the percent change from the
preceding quarter at a seasonally adjusted annual rate. BEA reported the second quarter of
2026 as "an annual rate of 2.2 percent" in its third estimate.

#### Computation

Published by BEA via FRED (A191RL1Q225SBEA); the dashboard shows it unchanged.

#### Reading it

The reference line is at zero; there is no badge. From the second quarter of 1947 the
range was −28.0% (second quarter of 2020) to +34.9% (third quarter of 2020); growth was
negative in 44 quarters, most recently the first quarter of 2022.

#### Use in practice

The dashboard classes it as lagging: it arrives after the quarter ends and is revised in
later estimates. Compare it with [industrial production](#industrial_production) and the
leading indicators.

#### Caveats

- **Annualized**: a quarter's change is expressed as if it continued for a year.
- **Estimates are revised**; the series shows the latest estimate for each quarter.

{{tile cli_g7 lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The OECD's composite leading indicator for the G7, amplitude adjusted.

#### Computation

From the OECD's data API (DF_CLI, area G7); the dashboard shows it unchanged.

#### Reading it

{{badge cli_g7 var="\text{CLI}_n"}}

From January 1959 it averaged 100.0 and was at or above 100 in 53% of months; its highest
value was 104.0 (January 1973) and its lowest 92.4 (April 2020). In September 2026 it was
100.94, up from 100.86.

#### Use in practice

Compare it with the [G20 indicator](#oecd_cli) and the national indicators.

#### Caveats

- **Revised**, as for all CLIs.

{{tile cli_uk lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The OECD's composite leading indicator for the UK, amplitude adjusted: the growth input
of the [UK regime tile](#regime_uk).

#### Computation

From the OECD's data API (DF_CLI, area GBR); the dashboard shows it unchanged.

#### Reading it

{{badge cli_uk var="\text{CLI}_n"}}

From December 1957 it averaged 100.0 and was at or above 100 in 58% of months; its highest
value was 106.8 (May 1972) and its lowest 87.0 (April 2020). In September 2026 it was
101.38, up from 101.14.

#### Use in practice

Compare it with the UK's [regime tile](#regime_uk).

#### Caveats

- **Revised**, as for all CLIs.

{{tile cli_japan lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The OECD's composite leading indicator for Japan, amplitude adjusted: the growth input of
the [Japan regime tile](#regime_japan).

#### Computation

From the OECD's data API (DF_CLI, area JPN); the dashboard shows it unchanged.

#### Reading it

{{badge cli_japan var="\text{CLI}_n"}}

From January 1959 it averaged 100.0 and was at or above 100 in 50% of months; its highest
value was 106.0 (March 1973) and its lowest 94.5 (January 1975). In September 2026 it was
100.35, up from 100.32.

#### Use in practice

Compare it with Japan's [regime tile](#regime_japan).

#### Caveats

- **Revised**, as for all CLIs.

{{tile cli_germany lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The OECD's composite leading indicator for Germany, amplitude adjusted: one of the four
national indicators the dashboard combines into its euro-area indicator.

#### Computation

From the OECD's data API (DF_CLI, area DEU); the dashboard shows it unchanged.

#### Reading it

{{badge cli_germany var="\text{CLI}_n"}}

From January 1961 it averaged 100.0 and was at or above 100 in 51% of months; its highest
value was 103.7 (May 1969) and its lowest 90.8 (April 2020). In September 2026 it was
101.01, up from 100.90.

#### Use in practice

Compare it with the [euro-area regime tile](#regime_euro_area).

#### Caveats

- **Revised**, as for all CLIs.

{{tile pmi_euro}}

#### What it is

S&P Global's purchasing managers' index (PMI) for the euro area. The data are licensed,
so the tile shows no figures and links to S&P Global's PMI site.

#### Reading it

The tile has no data, badge or reference line.

{{tile pmi_uk}}

#### What it is

S&P Global's purchasing managers' index for the UK; licensed, so the tile links to S&P
Global's PMI site.

#### Reading it

The tile has no data, badge or reference line.

{{tile pmi_japan}}

#### What it is

S&P Global's purchasing managers' index for Japan; licensed, so the tile links to S&P
Global's PMI site.

#### Reading it

The tile has no data, badge or reference line.
