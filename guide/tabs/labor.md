<!-- Labor. Every statement is sourced; see .claude/guide_checklist.md.
     Code: R/views.R, R/display.R, R/assess.R (assess_claims, BADGE_PARAMS$claims), R/fetch.R
     (nonfarm_payrolls), instructions/sources.yaml (classes).
     Publisher documentation: FRED notes (ICSA, CCSA, JTSJOL, TEMPHELPS, AWHMAN, PAYEMS, UNRATE,
     LRHUTTTTJPM156S, LRHUTTTTDEM156S); FRED JOLTS release page (August 2026 data on 29 September);
     ONS MGSX title and series page (release 15 Sep 2026, next 20 Oct 2026) and the September 2026
     labour market bulletin (4.9% for May to July 2026; definition of unemployment). bls.gov
     refuses automated requests.
     History: computed 2026-10-09 (scratch labor.R); quits rate = 100 x JTSQUL / PAYEMS within
     0.1 in 99.7% of months. -->

{{tab labor}}

The US labour market from the weekly unemployment-insurance claims to the monthly jobs
report, with unemployment rates for the UK, Japan and Germany. The dashboard classes the
US tiles in three groups:

- **Leading**: [initial](#initial_claims) and [continuing](#continuing_claims) claims,
  the [quits rate](#jolts_quits_rate) and [job openings](#jolts_openings) from the JOLTS
  survey, [temporary-help employment](#temp_help_employment) and
  [manufacturing hours](#avg_weekly_hours_mfg).
- **Coincident**: [nonfarm payrolls](#nonfarm_payrolls), shown as the monthly change.
- **Lagging**: the [unemployment rate](#unemployment_rate), which also feeds the Sahm
  rule on the Recession Watch tab.

The two claims tiles carry the dashboard's own badge: amber when the latest week is more
than 15% above the lowest of the past 52 weeks.

{{badge initial_claims var="x_n"}}

Here $\min_{52}$ is the lowest of the 52 latest weekly values, the current week included.

<!-- tiles -->

{{tile initial_claims lag="week ending Saturday; the week ending 3 October 2026 was available by 9 October"}}

#### What it is

The number of initial claims for unemployment insurance in the US each week (Employment
and Training Administration, seasonally adjusted). FRED's notes: an initial claim is filed
by an unemployed individual after a separation from an employer and requests a
determination of basic eligibility for the unemployment insurance program.

#### Computation

Published by the Department of Labor via FRED (ICSA); the dashboard shows it unchanged.

#### Reading it

{{badge initial_claims var="x_n"}}

From January 1967 the weekly count ranged from 162,000 (week ending 30 November 1968) to
6,137,000 (4 April 2020). In the week ending 3 October 2026 it was 197,000, 4.2% above
the lowest of the past 52 weeks.

#### Use in practice

Since 1970 the badge read "Rising off lows" in 31% of weeks. It did so for four weeks
or more in 33 separate spells; 18 of them began outside the period from 13 months before
an NBER peak to 2 months after the following trough. The first such spell in the 13
months before to 6 months after each peak:

| NBER peak | Spell began | Weeks before (−) or after (+) the peak |
|---|---|---|
| Nov 1973 | 28 Jul 1973 | −14 |
| Jan 1980 | 23 Dec 1978 | −53 |
| Jul 1981 | 31 May 1980 (during the 1980 recession) | −57 |
| Jul 1990 | 27 May 1989 | −57 |
| Mar 2001 | 15 Jul 2000 | −33 |
| Dec 2007 | 15 Dec 2007 | +2 |
| Feb 2020 | 30 Nov 2019 | −9 |

#### Caveats

- **Frequent amber spells.** More than half of the four-week spells since 1970 came away
  from recessions; compare the [continuing claims](#continuing_claims) tile.
- **Weekly noise**: one week can move the badge.

{{tile continuing_claims lag="week ending Saturday; the week ending 26 September 2026 was available by 9 October"}}

#### What it is

Continued claims, also called insured unemployment (seasonally adjusted). FRED's notes:
the number of people who have already filed an initial claim, experienced a week of
unemployment and then filed a continued claim for that week; the data are based on the
week of unemployment, not the week the initial claim was filed.

#### Computation

Published by the Department of Labor via FRED (CCSA); the dashboard shows it unchanged.

#### Reading it

{{badge continuing_claims var="x_n"}}

From January 1967 the count ranged from 988,000 (31 May 1969) to 23,130,000 (9 May 2020).
In the week ending 26 September 2026 it was 1,716,000, 1.0% above the lowest of the past
52 weeks.

#### Use in practice

Since 1970 the badge read "Rising off lows" in 24% of weeks, in 13 spells of four weeks or
more; only one (from December 2022) began outside the period from 13 months before an NBER
peak to 2 months after the following trough. The first such spell around each peak:

| NBER peak | Spell began | Weeks before (−) or after (+) the peak |
|---|---|---|
| Nov 1973 | 15 Dec 1973 | +6 |
| Jan 1980 | 27 Oct 1979 | −9 |
| Jul 1981 | 31 May 1980 (during the 1980 recession) | −57 |
| Jul 1990 | 5 Aug 1989 | −47 |
| Mar 2001 | 9 Dec 2000 | −12 |
| Dec 2007 | 26 Jan 2008 | +8 |
| Feb 2020 | 2 Feb 2019 | −52 |

#### Caveats

- **A week later** than initial claims, and it counts people claiming, not everyone
  unemployed.

{{tile jolts_quits_rate lag="monthly; the August 2026 data were released on 29 September 2026"}}

#### What it is

The quits rate from the BLS Job Openings and Labor Turnover Survey (JOLTS): quits in the
month as a percentage of total nonfarm employment (seasonally adjusted).

#### Computation

Published by the BLS via FRED (JTSQUR); the dashboard shows it unchanged. In 99.7% of
months it equals the JOLTS quits level (JTSQUL) divided by total nonfarm payroll
employment (PAYEMS), times 100, to within 0.1.

#### Reading it

There is no badge or reference line. From December 2000 it ranged from 1.2% (August 2009)
to 3.0% (November 2021); in August 2026 it was 1.9%.

#### Use in practice

Compare it with [job openings](#jolts_openings), from the same survey.

#### Caveats

- **Starts in December 2000**, so it covers only the 2001, 2007 and 2020 recessions.

{{tile jolts_openings lag="monthly; the August 2026 data were released on 29 September 2026"}}

#### What it is

Job openings from JOLTS, in thousands (seasonally adjusted). FRED's notes: all jobs not
filled on the last business day of the month, where a specific position exists, work is
available and can start within 30 days, and the employer is actively recruiting.

#### Computation

Published by the BLS via FRED (JTSJOL); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From December 2000 openings ranged from 2.23 million
(July 2009) to 12.30 million (March 2022); in August 2026 there were 7.08 million.

#### Use in practice

FRED's notes describe openings as a measure of unmet demand for labour. Dividing by the
number of unemployed (BLS, FRED series UNEMPLOY) gives openings per unemployed person:
2.04 at the March 2022 high and 1.01 in August 2026.

#### Caveats

- **Openings can fall without hiring**: FRED's notes say they decline when filled or when
  employers withdraw them.

{{tile temp_help_employment lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The number of employees in temporary help services, in thousands (seasonally adjusted),
from the BLS Current Employment Statistics (establishment survey).

#### Computation

Published by the BLS via FRED (TEMPHELPS); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From January 1990 it ranged from 1.11 million (July
1991) to 3.16 million (March 2022); in September 2026 it was 2.49 million.

#### Use in practice

Its highest point before each recession since the series began:

| NBER peak | Highest month in the 36 before | Months before the peak |
|---|---|---|
| Mar 2001 | Apr 2000 | 11 |
| Dec 2007 | May 2006 | 19 |
| Feb 2020 | Oct 2018 | 16 |

#### Caveats

- **Three recessions** in the history, too few for a firm rule.

{{tile avg_weekly_hours_mfg lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

Average weekly hours of production and nonsupervisory employees in manufacturing (BLS,
seasonally adjusted). FRED's notes: the hours they were paid for, which differ from
standard or scheduled hours; unpaid absences, turnover, part-time work and stoppages make
them lower than scheduled hours.

#### Computation

Published by the BLS via FRED (AWHMAN); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From January 1939 the average ranged from 37.0 hours
(May 1939) to 45.7 (November 1943); in September 2026 it was 42.0.

#### Use in practice

Read its direction against [temporary-help employment](#temp_help_employment) and
[payrolls](#nonfarm_payrolls).

#### Caveats

- **Manufacturing only**, and production and nonsupervisory employees only.

{{tile nonfarm_payrolls lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The change in US total nonfarm payroll employment from the previous month, in thousands.
FRED's notes describe total nonfarm payrolls as excluding proprietors, private household
employees, unpaid volunteers, farm employees and the unincorporated self-employed, and as
accounting for about 80% of the workers who contribute to GDP.

#### Computation

Computed by the dashboard from the published level (PAYEMS, seasonally adjusted):

$$
\Delta E_t = E_t - E_{t-1} \quad (\text{thousands}),
$$

for consecutive published months.

#### Reading it

The reference line is at zero; there is no badge. From February 1939 the change ranged
from −20.47 million (April 2020) to +4.63 million (June 2020). It was negative in seven
months from January 2025 to September 2026 (January, June, August, October and December
2025, February and July 2026), and +29,000 in September 2026.

#### Use in practice

Compare it with the [unemployment rate](#unemployment_rate), which comes from the
household survey (Current Population Survey).

#### Caveats

- **Small against the level**: the September 2026 change of +29,000 compares with total
  payroll employment of 159.0 million.

{{tile unemployment_rate lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The US unemployment rate (U-3) from the Current Population Survey (household survey): the
unemployed as a percentage of the labour force, people aged 16 and over who live in the
50 states or DC, outside institutions and not on active military duty (FRED's notes).

#### Computation

Published by the BLS via FRED (UNRATE); the dashboard shows it unchanged. The
[Sahm rule](#sahm_realtime) is built on it.

#### Reading it

There is no badge or reference line. From January 1948 it ranged from 2.5% (May 1953) to
14.8% (April 2020); in September 2026 it was 4.2%.

#### Use in practice

Read its change through the Sahm rule on the Recession Watch tab, which turns a rise in
the three-month average into a signal.

#### Caveats

- **A survey estimate**, from a household sample.

{{tile unemp_uk lag="monthly, three-month averages; the ONS release of 15 September 2026 covered May to July 2026, and the next is due on 20 October"}}

#### What it is

The UK unemployment rate for people aged 16 and over, seasonally adjusted, from the ONS
Labour Force Survey (series MGSX). The ONS counts as unemployed people without a job who
have been actively seeking work in the last four weeks and are available to start within
the next two weeks, and expresses them as a share of the economically active population.

#### Computation

From the ONS (MGSX); the dashboard shows it unchanged. Each value covers three months and
the series dates it at the middle month: the ONS's 4.9% for May to July 2026 is the June
2026 point.

#### Reading it

There is no badge or reference line. From February 1971 it ranged from 3.4% (November 1973)
to 11.9% (March 1984); for May to July 2026 it was 4.9%.

#### Use in practice

Compare it with the [UK regime tile](#regime_uk) and the UK's [CPI inflation](#cpi_uk).

#### Caveats

- **Three-month averages**, so it moves slowly and lags by about a month and a half.

{{tile unemp_japan lag="monthly; July 2026 was the latest on FRED on 9 October 2026"}}

#### What it is

Japan's unemployment rate for people aged 15 and over, seasonally adjusted, from the
OECD's infra-annual labour statistics (via FRED).

#### Computation

Published by the OECD via FRED (LRHUTTTTJPM156S); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From January 1955 it ranged from 1.0% (November 1968)
to 5.5% (June 2002); in July 2026 it was 2.4%.

#### Use in practice

Compare it with Japan's [regime tile](#regime_japan) and [CPI inflation](#cpi_japan).

#### Caveats

- **An OECD copy via FRED**, not Japan's statistics bureau's own release.

{{tile unemp_germany lag="monthly; July 2026 was the latest on FRED on 9 October 2026"}}

#### What it is

Germany's unemployment rate for people aged 15 and over, seasonally adjusted, from the
OECD's infra-annual labour statistics (via FRED).

#### Computation

Published by the OECD via FRED (LRHUTTTTDEM156S); the dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. From January 1991 it ranged from 2.9% (April 2019) to
11.2% (April 2005); in July 2026 it was 4.0%.

#### Use in practice

Compare it with Germany's [HICP inflation](#hicp_de) and
[leading indicator](#cli_germany).

#### Caveats

- **An OECD copy via FRED**, not Germany's statistics office's own release.
