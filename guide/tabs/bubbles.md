<!-- Bubbles / Froth. Every statement is sourced; see .claude/guide_checklist.md.
     Code: R/views.R, R/display.R, R/assess.R (BADGE_BANDS buffett, stocks_bonds;
     assess_stocks_bonds_history), R/fetch.R (buffett_indicator, stocks_vs_bonds_*), R/tiles.R
     (pair_detail, crossed shading), instructions/sources*.yaml (classes; IPO/SPAC links).
     Design brief: instructions/global-macro-cockpit.md ("the speedometer is not a clock").
     Publisher documentation: as for Appendix A.6, A.8 and A.9; FRED notes (DFII10, TDSP); Federal
     Reserve household debt service release (new credit-bureau method from the 2024:Q2
     publication; new series from 2005:Q1; values match FRED TDSP).
     History: computed 2026-10-09 (scratch bubbles.R, t3.R). Case-Shiller values are licensed:
     none are quoted. -->

{{tab bubbles}}

The speedometer of the cockpit: how stretched valuations and household leverage are. The
design brief's rule for reading it is that the speedometer is not a clock: these tiles say
how little margin of safety is left, not when a fall will come, and they are meant to be
read against the windscreen (the Recession Watch and Conditions tabs) rather than alone.

- **Valuation**: [equity to GDP](#buffett_indicator) and the
  [house price to rent](#case_shiller_price_rent) ratio (licensed, link-only on the
  public site).
- **Stocks against bonds**: the gap between an earnings yield and a real bond yield for
  the [US](#stocks_vs_bonds_real), the [euro area](#stocks_vs_bonds_euro_area) and the
  [UK](#stocks_vs_bonds_uk), with the [real 10-year Treasury yield](#real_10y_yield).
- **Speculation and leverage**: [IPO and SPAC issuance](#ipo_spac_issuance) (links to
  public trackers) and the [household debt service ratio](#household_debt_service_ratio).

The badge bands on this tab are the dashboard's own, except that the euro-area and UK
stocks-vs-bonds badges rank the gap against its own history.

<!-- tiles -->

{{tile buffett_indicator lag="quarterly; the second quarter of 2026 was available by 9 October 2026"}}

#### What it is

US nonfinancial corporations' equity relative to the size of the economy, which the
dashboard calls the Buffett indicator: the Federal Reserve's Financial Accounts series for
the corporate equities of nonfinancial corporate business (a liability, level), divided by
GDP.

#### Computation

Computed by the dashboard ([Appendix A.9](#a-buffett)):

$$
B_q = \frac{E_q}{1000\, Y_q},
$$

with $E_q$ in US\$ millions (NCBEILQ027S) and $Y_q$ nominal GDP in US\$ billions at an
annual rate (GDP). A value of 1 means the equity equals one year of GDP.

#### Reading it

{{badge buffett_indicator var="B_n"}}

The reference line is at 1. From the first quarter of 1947 the ratio had a median of 0.69
and a mean of 0.84; it ranged from 0.32 (second quarter of 1982) to 2.55 (second quarter of
2026, the latest value). It first exceeded 1.5 in the fourth quarter of 1999 (1.55) and 2 in
the first quarter of 2021; it was 1.15 at the end of 2007 and 2.19 at the end of 2021. The
badge would have read "Moderate" in 90% of quarters, "Elevated" in 7% and "Very stretched"
in 4%.

#### Use in practice

Read it against its own history and with the [stocks-vs-bonds](#stocks_vs_bonds_real)
tile, which sets the same equity against profits and bond yields.

#### Caveats

- **Nonfinancial corporations only**: financial corporations' equity is not in the
  numerator.
- **Quarterly and revised**: FRED's notes say the Financial Accounts may revise data and
  structure with each quarterly release.

{{tile stocks_vs_bonds_real lag="daily bond yield; quarterly profits, the second quarter of 2026 the latest on 9 October 2026"}}

#### What it is

A comparison of two yields that the dashboard, after Ray Dalio, reads as expected real
returns: the earnings yield of US nonfinancial corporations, and the real yield on 10-year
Treasuries. The tile draws both lines and shows the gap between them as its value.

#### Computation

Computed by the dashboard ([Appendix A.8](#a-stocks-bonds)):

$$
G_t = \mathrm{EY}_{q(t)} - \left(y^{10y}_t - \pi^{e,10y}_{m(t)}\right),
$$

with the earnings yield $\mathrm{EY}_q$ = after-tax profits of nonfinancial corporations
(BEA, annual rate) over their corporate equities (Financial Accounts), the 10-year Treasury
yield $y^{10y}$ and the Cleveland Fed's 10-year expected inflation $\pi^{e,10y}$. The
history starts on 4 January 1982.

#### Reading it

{{badge stocks_vs_bonds_real var="G_N"}}

In level mode the tile shows both lines, the stocks line labelled with its quarter and
the bond line daily, and shades any stretch where stocks yield less than bonds; the z-score
and percentile modes show the gap. From January 1982 the gap ranged from −1.64 (28 March
2002) to 6.34 (25 July 2012), with a median of 2.36. The badge read "Stocks out-yield
bonds" on 78% of days, "Close to crossing" on 11% and "Crossed" on 11%. On 7 October 2026
the gap was 0.66: stocks 3.37% (second quarter of 2026), bonds 2.71%.

#### Use in practice

The gap was negative for spells of 20 days or more in 1987, 1990–92 and from May 1999 to
June 2002 (with a break in late 2001); its last negative day was 28 June 2002. Its narrowest
point since then was 0.63, on 5 October 2026.

#### Caveats

- **Dates of the profits.** Each quarter's earnings yield is dated at the quarter's end
  although it is published later (see the note in [Appendix A.8](#a-stocks-bonds)).
- **Quarterly steps**: between quarterly updates only the bond line moves the gap.

{{tile stocks_vs_bonds_euro_area lag="daily bond yield; quarterly accounts, the second quarter of 2026 the latest on 9 October 2026"}}

#### What it is

The same comparison for the euro area, from ECB data: the after-tax earnings yield of
euro-area non-financial corporations against a real 10-year AAA government yield.

#### Computation

Computed by the dashboard ([Appendix A.8](#a-stocks-bonds)): net entrepreneurial income
minus current taxes over four quarters, over the equity the corporations have issued, from
the ECB's quarterly sector accounts for the euro area of 21 countries; against the ECB's
AAA yield-curve 10-year spot rate minus the longer-term HICP expectation of the ECB Survey
of Professional Forecasters. The history starts on 6 September 2004.

#### Reading it

{{badge stocks_vs_bonds_euro_area var="G_N"}}

The badge ranks the latest gap among all days since the history starts. The gap has never
been negative; it ranged from 4.54 (28 September 2026, the narrowest) to 9.25 (28 September
2016). On 8 October 2026 it was 4.65, narrower than on 99.8% of days since 2004: stocks
6.14% (second quarter of 2026), bonds 1.48%.

#### Use in practice

Read it against its own history rather than against the US tile: the dashboard's code
treats the zones' levels as not comparable.

#### Caveats

- **Quarterly steps and dating**, as for the US tile.

{{tile stocks_vs_bonds_uk lag="daily bond yield; quarterly accounts, the second quarter of 2026 the latest on 9 October 2026"}}

#### What it is

The same comparison for the UK, from ONS and Bank of England data: the after-tax earnings
yield of UK private non-financial corporations against the Bank of England's 10-year real
zero-coupon gilt yield.

#### Computation

Computed by the dashboard ([Appendix A.8](#a-stocks-bonds)), with depreciation from the
ONS profitability data, which end in the second quarter of 2025; for later quarters the
dashboard continues depreciation at its growth over the year before. The history starts
on 31 December 1997.

#### Reading it

{{badge stocks_vs_bonds_uk var="G_N"}}

The gap has never been negative; it ranged from 3.79 (30 March 2001) to 11.90 (29 May
2020). On 7 October 2026 it was 5.18, narrower than on 90.7% of days since 1997: stocks
7.23% (second quarter of 2026), bonds 2.05%.

#### Use in practice

As for the euro area, read it against its own history.

#### Caveats

- **Estimated depreciation** after the second quarter of 2025, as above.
- **Quarterly steps and dating**, as for the US tile.

{{tile real_10y_yield lag="daily; 7 October 2026 was available by 9 October"}}

#### What it is

The yield on 10-year US Treasury inflation-indexed securities (TIPS) at constant maturity,
from the Federal Reserve's H.15 release.

#### Computation

Published by the Federal Reserve Board via FRED (DFII10); the dashboard shows it unchanged.
It is also the real leg of the [10-year breakeven](#breakeven_10y): the nominal 10-year
yield minus this yield.

#### Reading it

The reference line is at zero; there is no badge. From 2 January 2003 it ranged from −1.19%
(3 August 2021) to 3.15% (21 November 2008); it was negative on 16% of days, most recently on
28 April 2022. On 7 October 2026 it was 2.92%.

#### Use in practice

Compare it with the bond line of the [US stocks-vs-bonds tile](#stocks_vs_bonds_real),
which uses a survey-and-model estimate of expected inflation instead of TIPS.

#### Caveats

- **Starts in 2003** on FRED.

{{tile ipo_spac_issuance}}

#### What it is

A manual tile for US IPO and SPAC issuance. The dashboard has no free, republishable feed
for it, so the tile links to two public trackers: Renaissance Capital's US IPO market
statistics and SPACInsider's SPAC market statistics.

#### Reading it

The tile has no data, badge or reference line.

{{tile case_shiller_price_rent lag="monthly"}}

#### What it is

The ratio of the S&P Cotality Case-Shiller US national home price index to the CPI for
rent of primary residence: a measure of house prices relative to rents.

#### Computation

Computed by the dashboard in the local app ([Appendix A.6](#a-price-rent)).

#### Reading it

There is no badge or reference line. The home price index is licensed, so the public
site shows only a link and this guide quotes no values. The two indexes have different
base periods (January 2000 and 1982–84), so read the ratio's changes and its position in
its own history rather than its level.

#### Caveats

- **Licensed**: link-only on the public site.

{{tile household_debt_service_ratio lag="quarterly; the second quarter of 2026 was released on 22 September 2026"}}

#### What it is

The Federal Reserve's household debt service ratio: required household debt payments as
a percentage of disposable personal income, seasonally adjusted. It has two parts, the
mortgage ratio and the consumer-debt ratio, which sum to the total.

#### Computation

Published by the Federal Reserve Board via FRED (TDSP); the dashboard shows it unchanged.
Starting with the publication for the second quarter of 2024, the Board moved to a new
method based on credit-bureau data; the new series starts in the first quarter of 2005,
and FRED's series matches it.

#### Reading it

There is no badge or reference line. From the first quarter of 2005 it ranged from 9.05%
(first quarter of 2021) to 15.85% (fourth quarter of 2007); in the second quarter of 2026 it
was 11.11%.

#### Use in practice

Compare it with the [30-year mortgage rate](#mortgage_rate_30y) and the
[real retail sales](#retail_sales_control_group) tile.

#### Caveats

- **New method**: the Board's earlier series, from 1980, used a different method; FRED now
  carries only the new series, from 2005.
