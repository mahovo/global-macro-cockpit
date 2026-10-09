# Part IV · Appendices {#part-appendices}

## Appendix A · Formulas {#appendix-formulas}

Every calculation the dashboard performs itself, written out. Series computed by their
publishers (spreads and breakevens on FRED, the Sahm rule, the NFCI, the OECD leading
indicators and so on) are described in their tiles' sections in Part III. Each formula
names the function that implements it.

### A.1 Notation and alignment {#a-notation}

<!-- R/transforms.R .align_locf; R/fetch.R .yoy_from_index, .regime_series -->

$t$ is the date of an observation: a business day, week, month or quarter, as the series
is published. $n$ is the latest observation in the window shown. $x_t$ is a series in its
own unit; "pp" means percentage points and "bp" basis points (0.01 pp).

**Carrying the last observation forward.** Series published at different frequencies are
combined on the union of their dates. A series observed at dates $d_1 < d_2 < \dots < d_m$
takes, at any date $\tau \ge d_1$, its latest value published for a date on or before
$\tau$:

$$
x(\tau) = x_{d_j}, \qquad j = \max\{\, i : d_i \le \tau \,\}.
$$

The dates here are the periods the data refer to, not the days they were released (see
the note at the end of [A.8](#a-stocks-bonds)). (`.align_locf` in `R/transforms.R`.)

**Annual rates.** From a monthly index $P_t$, $\pi_t = 100\,(P_t / P_{t-12} - 1)$ in %.
How a missing month is treated depends on the tile:

- **US price tiles** (CPI, core CPI, core PCE, PPI final demand): published months only.
  A month whose index, or whose index a year earlier, is missing gets no value. FRED's CPI
  and core CPI have no value for October 2025, so those tiles have none for October 2025
  and October 2026. (`.yoy_published`, `.yoy_tile` in `R/fetch.R`.)
- **Regime tiles**: a missing month of a price index is filled in log-linearly from its
  neighbours before the rate is taken, and where the source publishes the annual rate
  itself, an isolated missing month is filled in linearly. M2 growth uses the same
  function; its index has no gaps. (`.yoy_from_index`, `.regime_series` in `R/fetch.R`.)

### A.2 Display modes {#a-modes}

<!-- R/display.R apply_mode, mode_ref, format_value_mode; R/tiles.R change_tag -->

Over the $N$ observations $x_1, \dots, x_N$ in the window (the public site: the last five
years; the app: since "Show history since"), the z-score and percentile of $x_t$ are

$$
z_t = \frac{x_t - \bar x}{s}, \qquad
\bar x = \frac{1}{N}\sum_{i=1}^{N} x_i, \qquad
s = \sqrt{\frac{1}{N-1}\sum_{i=1}^{N} (x_i - \bar x)^2},
$$

with $s$ set to 1 if it is zero or undefined, and

$$
p_t = \frac{100}{N}\left( \#\{i : x_i < x_t\} + \frac{\#\{i : x_i = x_t\} + 1}{2} \right),
$$

the rank of $x_t$ among the window's values (ties share their average rank) as a share
of $N$. The highest value has $p = 100$. Reference lines become 0 for z-scores and 50 for
percentiles. The headline's change versus prior is $v_n - v_{n-1}$ in the mode shown,
where $v$ is $x$, $z$ or $p$. Badges always read the level $x_n$. (`apply_mode`,
`mode_ref` in `R/display.R`; `change_tag` in `R/tiles.R`.)

### A.3 Freshness and the recession count {#a-status}

<!-- R/display.R .STALE_DAYS, is_stale; scripts/build_site.R and app.R (rw_ids) -->

The freshness dot is amber when $\text{today} - d_n > L_f$ days, where $d_n$ is the date of
the latest observation and $L_f$ is 7 for daily series, 12 weekly, 45 monthly, 130
quarterly, 45 for any other frequency, and never for event series such as policy
rates. (`is_stale` in `R/display.R`.)

The sidebar's recession count: with $R$ the Recession Watch tiles that have a badge and
data,

$$
\text{signals} = \#\{\, i \in R : \text{badge}_i \text{ is red} \,\} \text{ of } |R|,
\qquad
\text{cautions} = \#\{\, i \in R : \text{badge}_i \text{ is amber} \,\}.
$$

### A.4 Net liquidity {#a-net-liquidity}

<!-- R/fetch.R ENTRY_OVERRIDES$net_liquidity -->

The Federal Reserve's total assets less two of the factors that absorb reserve funds in
its H.4.1 release: the Treasury's general account and overnight reverse repos.

$$
\mathrm{NL}_\tau = W_\tau - T_\tau - 1000\, Q_\tau \quad (\text{US\$ millions}),
$$

where $W$ is the Fed's total assets (WALCL, Wednesday level, \$ millions), $T$ the
Treasury General Account (WDTGAL, Wednesday level, \$ millions) and $Q$ overnight reverse
repurchase agreements (RRPONTSYD, daily, \$ billions, hence the factor 1000). Each is
carried forward to every date any of them is published, so the series moves daily with
the reverse repo although its other two inputs are weekly.

### A.5 HY − IG {#a-hy-ig}

<!-- instructions/sources.yaml formula; R/transforms.R resolve_transform -->

$$
D_t = \text{OAS}^{HY}_t - \text{OAS}^{IG}_t \quad (\text{pp}),
$$

the option-adjusted spread of the ICE BofA US High Yield Index (BAMLH0A0HYM2; bonds rated
BB or below) minus that of the ICE BofA US Corporate Index (BAMLC0A0CM; bonds rated BBB or
better, investment grade), both daily in %, per FRED's notes.
Licensed data: computed in the local app, link-only on the public site.

### A.6 Case-Shiller price to rent {#a-price-rent}

<!-- instructions/sources.yaml formula; R/transforms.R resolve_transform -->

$$
\mathrm{PR}_t = \frac{H_t}{K_t},
$$

with $H$ the S&P Cotality Case-Shiller U.S. National Home Price Index (CSUSHPINSA,
January 2000 = 100, not seasonally adjusted) and $K$ the CPI for rent of primary residence
(CUSR0000SEHA, 1982–84 = 100, seasonally adjusted), both monthly. The two indices have
different base periods (January 2000 and 1982–84), so the ratio's level depends on those
choices; its percentage changes and its position in its own history don't. Licensed data: link-only on the public site.

### A.7 Realized 10-year Treasury volatility {#a-realized-vol}

<!-- R/fetch.R ENTRY_OVERRIDES$ust10y_realized_vol -->

A free stand-in for the licensed ICE BofA MOVE index. With $y_t$ the 10-year
constant-maturity Treasury yield (DGS10, %) on business day $t$ and
$\Delta y_t = 100\,(y_t - y_{t-1})$ its daily change in basis points (between consecutive
days with a published yield),

$$
\sigma_t = \sqrt{252}\;\operatorname{sd}\left(\Delta y_{t-20}, \dots, \Delta y_t\right)
\quad (\text{bp, annualised}),
$$

the sample standard deviation ($N - 1$ in the denominator) of the last 21 daily changes,
scaled to a year of 252 trading days. It measures how much the yield has actually moved
over the last 21 trading days.

### A.8 Stocks vs bonds {#a-stocks-bonds}

<!-- R/fetch.R .stocks_vs_bonds, .real_yield, .earnings_yield, .quarter_end, .gap_history,
     ENTRY_OVERRIDES$stocks_vs_bonds_real / _euro_area / _uk; R/assess.R assess_stocks_bonds,
     assess_stocks_bonds_history -->

The dashboard's code describes these tiles as comparing expected real returns, after Ray
Dalio: the earnings yield of the corporate sector against a real 10-year government bond
yield. For each day $t$ with a bond yield,

$$
G_t = \mathrm{EY}_{q(t)} - r_t \quad (\text{pp}),
$$

where $\mathrm{EY}_q$ is the earnings yield for quarter $q$ (in %), dated at the quarter's last
day, $q(t)$ the latest quarter that ended on or before $t$, and $r_t$ the real 10-year
yield in %. Where the real yield is a nominal yield $y_t$ less expected inflation $\pi^e$,
the latest expectation dated on or before $t$ is used: $r_t = y_t - \pi^e_{j(t)}$.

**US** (`stocks_vs_bonds_real`), from FRED:

$$
\mathrm{EY}_q = 100 \cdot \frac{1000\, \Pi_q}{E_q}, \qquad r_t = y^{10y}_t - \pi^{e,10y}_{m(t)},
$$

with $\Pi_q$ BEA's nonfinancial corporate business profits after tax, without inventory
valuation and capital consumption adjustments (NFCPATAX, a seasonally adjusted annual
rate in \$ billions), $E_q$ the Federal Reserve Board's nonfinancial corporate business
corporate equities liability, level (NCBEILQ027S, \$ millions, Financial Accounts),
$y^{10y}$ the 10-year Treasury constant-maturity yield (DGS10) and $\pi^{e,10y}_{m(t)}$
the Federal Reserve Bank of Cleveland's 10-year expected inflation for the latest month
$m(t)$ (EXPINF10YR; FRED's notes say the Cleveland Fed estimates it with a model that uses
Treasury yields, inflation data, inflation swaps and survey-based measures of inflation
expectations).

**Euro area** (`stocks_vs_bonds_euro_area`), from the ECB's quarterly sector accounts for
non-financial corporations in the euro area (area code I10, "Euro area 21 (fixed
composition) as of 1 January 2026"):

$$
\mathrm{EY}_q = 100 \cdot \frac{\sum_{k=0}^{3} \left(\mathrm{B4N}_{q-k} - \mathrm{D5}_{q-k}\right)}{\mathrm{F51}_q},
\qquad r_t = y^{AAA,10y}_t - \pi^{e,LT}_{s(t)},
$$

with $\mathrm{B4N}$ the net entrepreneurial income and $\mathrm{D5}$ the current taxes
payable of non-financial corporations (flows flagged by the ECB as neither seasonally nor
working-day adjusted; the dashboard sums four quarters), $\mathrm{F51}$ the equity they
have issued (end of quarter), $y^{AAA,10y}$ the ECB's AAA yield curve 10-year spot rate
(daily; government bonds of all issuers rated triple A, Svensson model) and
$\pi^{e,LT}_{s(t)}$ the average point forecast for longer-term HICP inflation in the
latest ECB Survey of Professional Forecasters (five calendar years ahead in the third-
and fourth-quarter rounds, four in the first and second).

**UK** (`stocks_vs_bonds_uk`), from ONS series for private non-financial corporations
and the Bank of England:

$$
P_q = \mathrm{BPI}_q + \mathrm{DIV}_q + \mathrm{REI}_q - \mathrm{CFC}_q - \mathrm{TAX}_q, \qquad
\mathrm{EY}_q = 100 \cdot \frac{\sum_{k=0}^{3} P_{q-k}}{\mathrm{EQ}_q},
$$

where, in the ONS titles, $\mathrm{BPI}$ is the gross balance of primary income (B.5g, RPBO),
$\mathrm{DIV}$ distributed income of corporations paid (D.42, ROCH), $\mathrm{REI}$
reinvested earnings on foreign direct investment paid (D.43, ROCI) and $\mathrm{TAX}$ taxes
on income (D.51, RPLA), all seasonally adjusted in £ million; $\mathrm{CFC} = \mathrm{GOS}
- \mathrm{NOS}$ is gross minus net operating surplus (LRWL − LRWM, from the ONS
profitability data), which the dashboard uses as depreciation; and $\mathrm{EQ} =
\mathrm{NLBZ} + \mathrm{NLCA} + \mathrm{NLCB}$ is listed UK shares, unlisted UK shares and
other UK equity issued (levels, not seasonally adjusted). The profitability data end at
2025 Q2 ($q^*$; as of October 2026), so for later quarters the dashboard continues
depreciation at its growth over the year before:

$$
\mathrm{CFC}_{q^*+h} = \mathrm{CFC}_{q^*} \left(\frac{\mathrm{CFC}_{q^*}}{\mathrm{CFC}_{q^*-4}}\right)^{h/4}, \qquad h = 1, 2, \dots
$$

The bond side is the Bank of England series IUDMRZC, "Yield from British Government
Securities - 10 year Real Zero Coupon"; no expectation is subtracted.

**Reading against history** (euro area and UK). Their levels aren't comparable with the
US tile's, so their badges rank the latest gap among all days since each history starts
(1999 for the euro area; for the UK, when the equity data begin):

$$
R = \frac{100}{N} \sum_{s=1}^{N} \mathbf{1}\left[G_s \le G_N\right],
$$

the share of days with a gap as narrow as today's or narrower. (`.gap_history`.)

US badge:

{{badge stocks_vs_bonds_real var="G_N"}}
Euro-area and UK badge (the year is when the history starts):

{{badge stocks_vs_bonds_euro_area var="G_N"}}

<p class="note">Dating note: earnings yields enter the history from the last day of the
quarter they describe, although they are published only after the quarter has ended. The
chart therefore shows each quarter's value earlier than it was known at the time; the
latest value uses the latest published quarter, whose date the tile shows.</p>

### A.9 Equity to GDP (Buffett indicator) {#a-buffett}

<!-- R/fetch.R ENTRY_OVERRIDES$buffett_indicator -->

$$
B_q = \frac{E_q}{1000\, Y_q} \quad (\text{times}),
$$

with $E_q$ the Federal Reserve Board's nonfinancial corporate business corporate equities
liability, level (NCBEILQ027S, \$ millions, Financial Accounts) and $Y_q$ gross domestic
product (GDP, a seasonally adjusted annual rate in \$ billions, BEA). A reading of 1 means
the equity equals one year of GDP. Only nonfinancial corporations' equity is included.

### A.10 Growth and inflation regimes {#a-regimes}

<!-- R/fetch.R .regime_series, .regime_fetch, .cli_euro_area, .yoy_from_index,
     ENTRY_OVERRIDES$growth_inflation_regime / regime_*; R/assess.R REGIMES;
     R/tiles.R regime_quadrant, regime_strip -->

After Ray Dalio's four economic environments, as the dashboard's code describes it:
growth and inflation each either rising or falling. For each month $t$, with $\text{CLI}_t$ the OECD composite leading indicator
(amplitude adjusted) and $\pi_t$ headline inflation year on year in %:

$$
g_t = \text{CLI}_t - \text{CLI}_{t-3}, \qquad
m_t = \pi_t - \frac{1}{12} \sum_{k=0}^{11} \pi_{t-k},
$$

growth momentum $g_t$ in index points and inflation momentum $m_t$ in pp (inflation
against its own average over the past twelve months, the current month included).
Above zero counts as rising:

{{badge growth_inflation_regime}}

"Since" is the first month of the current regime's unbroken spell.

**Inputs by economy.**

| Tile | Leading indicator | Inflation |
|---|---|---|
| US | OECD CLI, United States | CPI, all items (BLS via FRED, CPIAUCSL), annual rate per A.1 |
| Euro area | GDP-weighted CLI of Germany, France, Italy, Spain (below) | HICP annual rate, euro area in its changing composition (Eurostat, EA) |
| UK | OECD CLI, United Kingdom | CPI annual rate (ONS, D7G7) |
| Japan | OECD CLI, Japan | CPI year on year (IMF CPI dataset) |
| China | OECD CLI, China | CPI year on year (IMF CPI dataset) |

**Euro-area leading indicator.** The OECD's leading-indicator dataset (DF_CLI) has no
euro-area series (queries for the areas EA20, EA19 and EA return no data, October 2026),
so the dashboard weights the indicators for Germany, France, Italy and Spain by nominal
GDP:

$$
\text{CLI}^{EA}_t = \sum_{c \in \{DE, FR, IT, ES\}} w_c\, \text{CLI}^{c}_t, \qquad
w_c = \frac{\text{GDP}_c}{\sum_{c'} \text{GDP}_{c'}},
$$

with GDP at current prices for the latest year Eurostat has for all four, over the months
all four indicators cover.

**The quadrant.** It plots $(g_t, m_t)$ for the months in the period the regime strip
shows, the last twelve dark. Its axes are symmetric so the origin stays centred:
$\pm 1.3 \max(0.3, \max_t |g_t|)$ across and $\pm 1.3 \max(0.3, \max_t |m_t|)$ up, over
the months plotted.
