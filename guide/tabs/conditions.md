<!-- Conditions & Liquidity. Every statement is sourced; see .claude/guide_checklist.md.
     Code: R/views.R, R/display.R, R/assess.R (BADGE_BANDS$nfci), R/help.R (tab and card
     notes), R/fetch.R (net_liquidity, m2), instructions/sources_global.yaml.
     Publisher documentation: Chicago Fed "About the NFCI"; FRED notes (NFCI, ANFCI, STLFSI4,
     WALCL, WTREGEN, WDTGAL, RRPONTSYD, M2SL); H.4.1 release of 1 Oct 2026; H.6 release of
     22 Sep 2026; NY Fed reverse repo FAQ; FOMC statements of 4 May 2022 (balance-sheet plans),
     29 Oct 2025, 10 Dec 2025 and the implementation note of 10 Dec 2025.
     History: computed 2026-10-07 from FRED data (NFCI from 1971, STLFSI4 from 1993, WALCL,
     WRESBAL, WDTGAL, WTREGEN, RRPONTSYD, M2SL from 1959). -->

{{tab conditions}}

The first link in the dashboard's transmission chain. The tab holds two kinds of gauge:

- **Conditions indices** combine many market and financial measures into one number:
  the Chicago Fed's [NFCI](#nfci) and its [adjusted](#anfci) version, and the
  [St. Louis Fed Financial Stress Index](#stl_financial_stress). Each is scaled so that
  zero is its historical average.
- **Liquidity measures** track the dollar system's plumbing: the
  [Fed's balance sheet](#fed_balance_sheet), the
  [Treasury General Account](#treasury_general_account) and the
  [overnight reverse repo](#reverse_repo), the [net liquidity](#net_liquidity) that
  combines them, and the growth of the broad money stock [M2](#m2).

The liquidity tiles are linked through the Fed's weekly balance-sheet release (H.4.1).
It lists the factors that supply reserve funds, mainly the Fed's securities and loans,
and the factors other than reserve balances that absorb them, among them currency,
reverse repurchase agreements and the Treasury's account. Banks' reserve balances are
the difference. In the release of 1 October 2026, for Wednesday 30 September, factors
supplying reserve funds came to \$6,790,836 million and absorbing factors to \$3,842,746
million, leaving \$2,948,090 million of reserve balances.

<!-- tiles -->

{{tile nfci lag="week ending Friday; the week ending 2 October 2026 was available on 7 October"}}

#### What it is

The Chicago Fed's National Financial Conditions Index, a weekly update on US financial
conditions in money markets, debt and equity markets, and the traditional and "shadow"
banking systems. The Chicago Fed also publishes three subindexes: *risk* (volatility and
funding risk in the financial sector), *credit* (measures of credit conditions) and
*leverage* (debt and equity measures).

#### Computation

Published by the Chicago Fed; the dashboard shows it unchanged. The index is a weighted
average of 105 measures of financial activity, each expressed relative to its sample
average and scaled by its sample standard deviation:

$$
\tilde x_{it} = \frac{x_{it} - \bar x_i}{s_i}, \qquad
\text{NFCI}_t \propto \sum_{i=1}^{105} w_i\, \tilde x_{it},
$$

constructed to have an average of 0 and a standard deviation of 1 over a sample
extending back to 1971. How the weights $w_i$ are chosen is described in Brave and
Butters (2011), linked from the
[Chicago Fed's NFCI page](https://www.chicagofed.org/research/data/nfci/about).

#### Reading it

{{badge nfci var="\text{NFCI}_n"}}

The Chicago Fed describes positive values as historically associated with
tighter-than-average financial conditions and negative values with looser-than-average
ones. The reference line is at zero; the 0.5 boundary is the dashboard's own. The risk,
credit and leverage subindexes rise with higher risk, tighter credit and falling
leverage.

#### Use in practice

From the FRED series since January 1971:

- the index was above zero in 29% of weeks, most recently in the week of 1 May 2020;
- its highest reading was 5.22, in the week of 19 July 1974;
- from October 2021 to October 2026, a period that includes the Fed's rate increases of
  2022–23, its highest weekly reading was −0.10 (7 October 2022).

#### Caveats

- **Relative to 1971 onward.** Zero is the average of a history that includes the
  episodes above, so "looser than average" isn't the same as "loose".
- **US only.**

{{tile anfci lag="week ending Friday; the week ending 2 October 2026 was available on 7 October"}}

#### What it is

The adjusted NFCI measures financial conditions relative to the state of the economy.
The Chicago Fed describes positive values as historically associated with conditions
tighter than prevailing macroeconomic conditions would typically suggest, and negative
values with the opposite.

#### Computation

Published by the Chicago Fed. It is built like the NFCI from the same indicators, after
removing the variation in each indicator attributable to economic activity and
inflation. Like the NFCI it has an average of 0 and a standard deviation of 1 over a
sample extending back to 1971. The method is set out in the Chicago Fed's article
"Introducing the Chicago Fed's New Adjusted National Financial Conditions Index" (2017),
linked from its [NFCI page](https://www.chicagofed.org/research/data/nfci/about).

#### Reading it

The same badge rules as the NFCI:

{{badge anfci var="\text{ANFCI}_n"}}

Positive values mean conditions tighter than the economy would typically produce;
negative values, looser.

#### Use in practice

From October 2021 to October 2026 the adjusted index stayed below zero; its highest
weekly reading was −0.01 (1 July 2022).

#### Caveats

- **Model-based.** The part of conditions attributed to economic activity and inflation
  is an estimate.
- **US only.**

{{tile stl_financial_stress lag="week ending Friday; the week ending 25 September 2026 was available by 7 October"}}

#### What it is

The St. Louis Fed Financial Stress Index, version 4: a weekly measure of the degree of
financial stress in markets.

#### Computation

Published by the St. Louis Fed; the dashboard shows it unchanged. According to FRED's
notes it is constructed from 18 weekly data series (seven interest rates, six yield
spreads and five other indicators), each capturing some aspect of financial stress, on
the reasoning that the series move together as stress changes. The index's average
since it begins in late 1993 is designed to be zero. Version 4 is the third revision of
the original index; it uses the forward-looking 90-day SOFR rate in two of its spreads,
where version 3 used the backward-looking 90-day average. FRED's
[series notes](https://fred.stlouisfed.org/series/STLFSI4) link the papers describing
each version.

#### Reading it

FRED's notes: zero represents normal financial market conditions, values below zero
below-average stress and values above zero above-average stress. The tile's reference
line is at zero; there is no badge.

#### Use in practice

The highest weekly reading in each of the six highest years since 1993:

| Week ending | Value |
|---|---|
| 10 Oct 2008 | 9.66 |
| 20 Mar 2020 | 5.62 |
| 2 Jan 2009 | 4.97 |
| 30 Nov 2007 | 2.09 |
| 21 Sep 2001 | 2.02 |
| 9 Oct 1998 | 1.92 |

From October 2021 to October 2026 the highest reading was 1.14, in the week ending
17 March 2023.

#### Caveats

- **Earlier versions differ.** Earlier versions are separate, discontinued series on
  FRED; the tile uses version 4.
- **US only.**

{{tile fed_balance_sheet lag="Wednesday level; the H.4.1 release of Thursday 1 October 2026 covers Wednesday 30 September"}}

#### What it is

The total assets of the Federal Reserve System (less eliminations from consolidation),
from its weekly H.4.1 release.

#### Computation

Published by the Federal Reserve Board via FRED (WALCL): the Wednesday level, in US\$
millions. The dashboard shows it unchanged.

#### Reading it

There is no badge or reference line. Milestones in the FRED series and the FOMC's
decisions:

- In February 2020 total assets were \$4,159–4,183 billion.
- They peaked at \$8,965 billion on 13 April 2022.
- Under plans the FOMC published on 4 May 2022, from 1 June 2022 principal payments from
  its securities were reinvested only to the extent that they exceeded monthly caps, so
  its holdings declined.
- On 29 October 2025 the FOMC decided to conclude the reduction of its securities
  holdings on 1 December 2025. Total assets were \$6,557 billion on 17 December 2025.
- On 10 December 2025 it judged that reserve balances had declined to ample levels and
  directed purchases of Treasury bills (and, if needed, other Treasury securities with
  up to three years' remaining maturity) to maintain an ample level of reserves. Total
  assets were \$6,743 billion on 30 September 2026.

#### Use in practice

In the H.4.1 accounting, the Fed's assets supply reserve funds; how much ends up as bank
reserves depends also on the absorbing factors, which is why the dashboard also shows
[net liquidity](#net_liquidity).

#### Caveats

- **Total assets combine different items**, securities held outright and loans among
  them; the H.4.1 tables give the split.
- **A weekly snapshot**: the Wednesday level.

{{tile treasury_general_account lag="week ending Wednesday, in the H.4.1 release published the next day"}}

#### What it is

The US Treasury's general account at the Federal Reserve. In the H.4.1 release it is
one of the deposits with Federal Reserve Banks other than reserve balances, which count
among the factors absorbing reserve funds: other things equal, a higher balance means
lower bank reserves.

#### Computation

Published by the Federal Reserve Board via FRED (WTREGEN): the average of daily figures
for the week ending Wednesday, in US\$ millions. The dashboard shows it unchanged.
([Net liquidity](#net_liquidity) uses the Wednesday level instead, WDTGAL.)

#### Reading it

There is no badge or reference line. From mid-2019 to October 2026 the week average was
lowest at \$45 billion (week ending 7 June 2023) and highest at \$1,817 billion (week
ending 29 July 2020). In 2025 it fell to \$306 billion (week ending 9 April) and \$323
billion (23 July), then rose to \$941 billion by the week ending 5 November.

#### Use in practice

Because the account absorbs reserve funds, a rise in the balance drains bank reserves
unless other factors offset it. Compare its swings with the
[Fed's balance sheet](#fed_balance_sheet) and the [reverse repo](#reverse_repo), or see
the combined effect in [net liquidity](#net_liquidity).

#### Caveats

- **A week average**, unlike the Wednesday level of the Fed's total assets.
- **It reflects the Treasury's cash management**, not the FOMC's decisions.

{{tile reverse_repo lag="the operation for 7 October 2026 was on FRED the same day"}}

#### What it is

The amount of the Fed's overnight reverse repurchase (ON RRP) operations. In a reverse
repo the New York Fed's Open Market Desk sells a security to an eligible counterparty
with an agreement to buy it back at a specified price at a specified time. Eligible
counterparties are primary dealers and approved RRP counterparties, which include 2a-7
money market funds, banks and government-sponsored enterprises; the collateral is US
Treasuries. According to the New York Fed, the transaction shifts some of the Fed's
liabilities from bank reserves to reverse repos while it is outstanding.

#### Computation

Published by the Federal Reserve Bank of New York via FRED (RRPONTSYD): the aggregated
daily amount of overnight reverse repo transactions, in US\$ billions. The dashboard shows
it unchanged.

#### Reading it

The FOMC sets the offering rate; in its implementation note of 10 December 2025 it was
3.5%, the bottom of the 3.5–3.75% target range for the federal funds rate. There is no
badge or reference line. In the FRED series:

- usage peaked at \$2,554 billion on 30 December 2022;
- from 28 December 2022 to 25 December 2024 it fell by \$2,112 billion, while the Fed's
  total assets fell by \$1,665 billion and bank reserve balances (week average) rose by
  \$229 billion;
- since 5 August 2025 it has been below \$100 billion every day except 31 December 2025
  (\$106 billion); on 7 October 2026 it was \$2.3 billion.

#### Use in practice

In the H.4.1 accounting a fall in reverse repos, other things equal, adds to bank
reserves; with usage near zero there is little left to fall.

#### Caveats

- **Billions, not millions.** Unlike the two balance-sheet tiles this series is in US\$
  billions; [net liquidity](#net_liquidity) converts it.

{{tile net_liquidity lag="the Fed's balance sheet and the Treasury account carried forward between weekly releases"}}

#### What it is

The Fed's total assets minus the two absorbing factors shown on this tab, the Treasury
General Account and the overnight reverse repo. The dashboard computes it from three Fed
series.

#### Computation

Computed by the dashboard ([Appendix A.4](#a-net-liquidity)):

$$
\mathrm{NL}_\tau = W_\tau - T_\tau - 1000\, Q_\tau \quad (\text{US\$ millions}),
$$

with $W$ the Fed's total assets and $T$ the Treasury General Account, both Wednesday
levels in \$ millions (WALCL, WDTGAL), and $Q$ the daily reverse repo in \$ billions
(RRPONTSYD). Each input is carried forward to every date any of them is published, so the
series moves daily with the reverse repo.

#### Reading it

There is no badge or reference line. In the H.4.1 accounting, reserve balances are the
factors supplying reserve funds minus all the absorbing factors; net liquidity starts
from total assets and subtracts only two absorbing factors, so the others, currency
among them, remain in it. A rise therefore means more of the Fed's balance sheet is left
as bank reserves, currency and its other liabilities; a fall, less.

#### Use in practice

From 28 December 2022 to 25 December 2024 the Fed's total assets fell by \$1,665
billion, but net liquidity rose by about \$122 billion, because the reverse repo fell by
\$2,112 billion while the Treasury account (Wednesday level) rose by \$325 billion.

#### Caveats

- **Partial.** It leaves out the other absorbing factors, currency among them.
- **Timing.** The two weekly inputs are Wednesday levels; the reverse repo is daily.

{{tile m2 lag="the H.6 release of 22 September 2026 carried August 2026"}}

#### What it is

The growth of the US money stock M2 over the previous twelve months. The Federal Reserve
Board's H.6 release defines M2 as M1 (currency, demand deposits and other liquid
deposits) plus small-denomination time deposits (under \$100,000) and balances in retail
money market funds, less individual retirement account (IRA) and Keogh balances at
depository institutions and money market funds.

#### Computation

The dashboard computes the annual growth rate from the seasonally adjusted monthly level
(M2SL, US\$ billions) published by the Federal Reserve Board ([Appendix A.1](#a-notation)):

$$
g^{M2}_t = 100 \left( \frac{M2_t}{M2_{t-12}} - 1 \right) \quad (\%).
$$

#### Reading it

The reference line is at zero: below it, the money stock is smaller than a year earlier.
There is no badge. In the FRED series (from January 1959, so growth rates from January
1960):

- the fastest growth was 26.8%, in February 2021;
- the only months with negative growth were December 2022 to February 2024;
- growth was 5.7% in August 2026.

#### Use in practice

Read the growth rate against its own history with the z-score or percentile mode; the
zero line separates a growing money stock from a shrinking one.

#### Caveats

- **Definition change.** FRED's notes say savings deposits were summed separately into
  M2 before May 2020, and point to the H.6 announcements of 17 December 2020 on the
  regulatory change that created the "other liquid deposits" component of M1.
- **Seasonally adjusted, monthly.**
