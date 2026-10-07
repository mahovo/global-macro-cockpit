# help.R — short interpretation notes shown in each tab header (panel help) and
# in an info-popover on each card (how to read it / what to watch / why it matters).

VIEW_HELP <- list(
  recession  = "The 'are we okay?' panel — the most battle-tested recession signals. A curve inversion leads recessions by 6–18 months; the Sahm rule confirms a downturn early. Worry when several flash at once.",
  conditions = "Financial conditions and liquidity lead everything else — look here first. Tight conditions (positive NFCI) and shrinking net liquidity are headwinds for risk assets; loosening is a tailwind.",
  credit_rates = "Credit spreads are the market's real-time stress thermometer; the rate structure sets the cost of money. Widening HY spreads and HY−IG decompression flag rising risk before equities react.",
  inflation  = "Market-implied expectations (breakevens) lead; realized CPI/PCE is coincident-to-lagging but moves markets most on surprises. Anchored near ~2% is healthy — un-anchoring either way is the risk.",
  cycle      = "Growth momentum and turning points. PMIs, the OECD CLI and regional surveys lead activity by months; IP and GDP confirm. Above-trend & rising = expansion; rolling over is the early warning. The first five tiles place the US, the euro area, the UK, Japan and China in Ray Dalio's four economic regimes.",
  labor      = "Labor leads at the margin and lags at the core. Claims, quits, openings and temp-help turn first; payrolls and the unemployment rate confirm later. Rising claims off the lows is the first crack.",
  trade_energy = "Global demand and the real-economy pulse. Shipping and trade volumes lead; energy and copper read demand and cost-push inflation. Falling copper/freight flags softening global activity.",
  consumer   = "Consumer and housing — rate-sensitive and cycle-leading. Permits, starts and sentiment turn before spending; retail sales confirm. Housing usually cracks first when rates bite.",
  markets    = "What the other 'drivers' are doing — risk appetite in real time. VIX = fear; a strong broad dollar tightens global conditions; equities discount the future. Read alongside conditions & credit.",
  china      = "China's credit cycle leads the global industrial cycle by ~6–12 months — arguably the most valuable non-US read. (Most tiles here still await provider wiring.)",
  bubbles    = "The speedometer: how little margin of safety is left — NOT a crash countdown. High valuations + leverage make any ordinary shock convex to the downside. Read against the windscreen (Recession Watch / Conditions): froth into deteriorating conditions is the brake signal."
)

CARD_HELP <- list(
  # --- recession watch ---
  curve_10y_3m = "10-year minus 3-month Treasury yield, the Fed's preferred curve gauge. Below 0 (inverted) has preceded nearly every US recession by 6–18 months; positive and steepening is normal/expansionary.",
  curve_10y_2y = "10-year minus 2-year yield — the classic recession curve. Inversion (below 0) is an early lead; the re-steepening that follows often coincides with the downturn actually beginning.",
  sahm_realtime = "Real-time Sahm rule: the rise in the 3-month unemployment rate vs its prior-year low. Crossing +0.5pp has marked the start of every recession since the 1970s — a fast, reliable confirmation.",
  recession_prob_chauvet_piger = "Model-based smoothed probability the US is currently in recession. Above ~20% warrants attention, above ~50% is a strong signal. Coincident — it confirms rather than predicts.",
  # --- financial conditions ---
  nfci = "Chicago Fed National Financial Conditions Index. 0 = average; positive = tighter than average (a growth/risk headwind), negative = looser (tailwind). One of the best single 'is policy helping or hurting' reads.",
  anfci = "NFCI adjusted for the state of the economy — isolates conditions that are unusually tight/loose given growth and inflation. Positive = unusually tight.",
  stl_financial_stress = "St. Louis Fed Financial Stress Index. 0 = normal; positive = above-average market stress. Jumps flag funding/market strain in real time.",
  # --- liquidity ---
  fed_balance_sheet = "Total Fed assets (WALCL). Expansion (QE) adds market liquidity; contraction (QT) drains it. A slow tide that lifts or lowers risk assets.",
  treasury_general_account = "The Treasury's account at the Fed (TGA). A rising TGA pulls cash out of the banking system (a drain); a falling TGA releases it. Watch around debt-ceiling episodes.",
  reverse_repo = "Overnight reverse-repo balances (RRP) — cash parked at the Fed and out of markets. Falling RRP releases liquidity back into the system. A component of net liquidity.",
  net_liquidity = "Fed balance sheet minus TGA minus RRP — the cash actually available to markets. Rising = tailwind for risk assets, falling = headwind. One of the cleaner liquidity reads.",
  m2 = "M2 money supply. Growth supports nominal activity and asset prices with a lag; the rare year-over-year contraction (2022–23) is a strong tightening signal.",
  # --- credit ---
  sloos_ci_tightening = "Senior Loan Officer survey: net % of banks tightening business (C&I) lending standards. Tightening leads slower credit and activity by 2–4 quarters — a genuine leading indicator.",
  hy_oas = "High-yield credit spread (option-adjusted) — the market's real-time credit-stress thermometer. Under ~3% = complacent/risk-on; past ~5% signals rising stress; >8% is risk-off.",
  ig_oas = "Investment-grade credit spread. Lower-beta than HY but the same signal: widening = tightening conditions and rising risk aversion, often before equities react.",
  hy_minus_ig = "Riskiest credit minus safer credit (HY − IG). Compression = reach-for-yield/complacency; decompression (widening) means investors are discriminating on risk — an early stress tell.",
  ust10y_realized_vol = "Realized volatility of the 10-year Treasury yield: the standard deviation of daily yield changes over the past month, annualized, in basis points. A free, backward-looking stand-in for the ICE MOVE index (implied volatility); spikes flag rate and funding stress.",
  # --- rates ---
  ust_3m = "3-month Treasury yield — effectively the front-end / policy-rate proxy and the short anchor of the recession curve.",
  ust_2y = "2-year Treasury yield — the market's expected average policy rate over ~2 years. A falling 2y often front-runs Fed cuts.",
  ust_10y = "10-year Treasury yield — the benchmark long rate (growth + inflation expectations + term premium) and the discount rate for risk assets.",
  effr = "Effective federal funds rate — where policy actually trades. Coincident: it tells you the current stance everything else trades around.",
  ecb_policy_rate = "ECB deposit facility rate — the euro-area policy rate. A step series: the latest level holds until the next change. Frames euro-area conditions and the EUR.",
  # --- inflation ---
  breakeven_5y = "5-year TIPS breakeven — market-implied average CPI inflation over 5 years. Leading; ~2–2.5% is anchored. Drift shifts the expected central-bank path.",
  breakeven_10y = "10-year inflation breakeven — longer-horizon market inflation expectations, anchored near ~2.3% (≈2% PCE). Un-anchoring is what central banks fear most.",
  breakeven_5y5y_fwd = "5-year, 5-year-forward breakeven — expected inflation over years 5–10, stripping near-term noise. The cleanest read on whether long-run expectations stay anchored.",
  umich_inflation_exp_1y = "UMich 1-year consumer inflation expectations. Survey-based and leading for spending; sharp rises can become self-fulfilling.",
  cpi_headline = "Headline CPI (index — watch the year-over-year change). Coincident-to-lagging but the single most market-moving release; surprises drive big rate repricings.",
  cpi_core = "Core CPI (ex food & energy) — the stickier underlying trend the Fed watches. Turns more slowly than headline.",
  pce_core = "Core PCE — the Fed's preferred gauge and the basis for its 2% target. Lagging but decisive for policy.",
  ppi_final_demand = "Producer prices (final demand) — pipeline/input-cost inflation that often leads consumer prices. A look upstream of CPI.",
  # --- cycle ---
  growth_inflation_regime = "Which of Ray Dalio's four economic environments the US is in: growth rising or falling, crossed with inflation rising or falling. Growth: the 3-month change in the OECD leading indicator for the US, which runs about six to nine months ahead of activity. Inflation: headline CPI inflation minus its average over the past 12 months, so a price spike counts as rising until it fades. The strip shows each month's regime. Pick a period with the handles under it, by dragging across the strip, or (on the public site) with the zoom; the quadrant traces that period, its last 12 months dark and earlier months light. Since 1970, stocks did best in Goldilocks and worst in stagflation; Treasuries did best when growth and inflation both fell and worst when both rose. The regime tilts those odds rather than deciding them; read it with Stocks vs bonds — US. The chart is the same in every display mode. The OECD revises recent CLI months, and October 2025 CPI (never published) is interpolated.",
  regime_euro_area = "Ray Dalio's four economic environments for the euro area, built like the US tile: growth rising or falling, crossed with inflation rising or falling, read by direction rather than level. Growth: the 3-month change in the OECD leading indicators for Germany, France, Italy and Spain, averaged with GDP weights (the OECD publishes no euro-area indicator). Inflation: euro-area HICP inflation (Eurostat) minus its average over the past 12 months. The history starts in late 2001, when HICP data for the 20-country euro area begin. Pick a period with the handles under the strip, by dragging across the strip, or (on the public site) with the zoom. The chart is the same in every display mode.",
  regime_uk = "Ray Dalio's four economic environments for the UK, built like the US tile: growth rising or falling, crossed with inflation rising or falling, read by direction rather than level. Growth: the 3-month change in the OECD leading indicator for the UK. Inflation: CPI inflation (ONS) minus its average over the past 12 months. The history starts at the end of 1989, when the ONS CPI series begins. Pick a period with the handles under the strip, by dragging across the strip, or (on the public site) with the zoom. The chart is the same in every display mode.",
  regime_japan = "Ray Dalio's four economic environments for Japan, built like the US tile: growth rising or falling, crossed with inflation rising or falling, read by direction rather than level. Growth: the 3-month change in the OECD leading indicator for Japan. Inflation: CPI inflation minus its average over the past 12 months, from the IMF's CPI dataset (a few weeks behind the national release). Consumption-tax rises (1989, 1997, 2014, 2019) show up as year-long jumps in inflation. Pick a period with the handles under the strip, by dragging across the strip, or (on the public site) with the zoom. The chart is the same in every display mode.",
  regime_china = "Ray Dalio's four economic environments for China, built like the US tile: growth rising or falling, crossed with inflation rising or falling, read by direction rather than level, so inflation rising from below 1% still counts as rising. Growth: the 3-month change in the OECD leading indicator for China. Inflation: CPI inflation minus its average over the past 12 months, from the IMF's CPI dataset (a few weeks behind the national release); food, pork above all, drives much of it. Pick a period with the handles under the strip, by dragging across the strip, or (on the public site) with the zoom. The chart is the same in every display mode.",
  oecd_cli = "OECD Composite Leading Indicator (G20) — purpose-built to anticipate turning points. 100 = trend; above & rising = expansion; rolling below 100 flags a slowdown. Broad global read incl. China/India.",
  core_capex_orders = "New orders for nondefense capital goods excluding aircraft (Census) — companies' investment plans, a classic leading indicator for capex and factory activity. Watch the trend over several months; single months are noisy.",
  cli_usa = "OECD composite leading indicator for the US — designed to signal turning points in activity about six to nine months ahead. 100 = trend; below & falling flags a slowdown.",
  empire_state_mfg = "NY Fed (Empire State) manufacturing survey — an early regional read on factory activity. Volatile but timely; >0 = expansion.",
  philly_fed_mfg = "Philadelphia Fed manufacturing survey — another early regional factory gauge. Pairs with Empire State to preview national ISM/IP.",
  industrial_production = "Industrial production — actual factory/mine/utility output. Coincident; confirms what the surveys led.",
  real_gdp = "Real GDP — the broadest activity measure. Lagging and quarterly; the official scorecard rather than a leading signal.",
  # --- labor ---
  initial_claims = "Initial jobless claims — the highest-frequency (weekly) labor read. Low and stable = firm; a sustained rise off the lows is the first crack in the cycle.",
  continuing_claims = "Continuing jobless claims — how long people stay unemployed. Rising means harder re-hiring; a slower-burning weakening signal than initial claims.",
  jolts_quits_rate = "Quits rate — workers quit when confident, so a falling quits rate leads slower wage growth and a softening labor market.",
  jolts_openings = "Job openings (JOLTS). Falling openings cool the labor market before layoffs hit payrolls; openings-to-unemployed is a key tightness gauge.",
  temp_help_employment = "Temporary-help employment — firms cut temps first when demand softens, so this leads broader payrolls at turning points.",
  avg_weekly_hours_mfg = "Average weekly manufacturing hours — employers trim hours before headcount, so falling hours lead outright job cuts.",
  nonfarm_payrolls = "Nonfarm payrolls — the monthly 'big one.' Coincident, but large surprises move markets sharply.",
  unemployment_rate = "Unemployment rate — lagging (it rises after a downturn is underway), but feeds the Sahm rule and the Fed's mandate.",
  # --- trade / energy / commodities ---
  gscpi = "New York Fed Global Supply Chain Pressure Index — shipping costs, delivery times, backlogs and inventories combined, in standard deviations from the historical average. Above 1 = strained supply chains and cost-push inflation risk; below 0 = slack. Recent months are revised with each monthly update.",
  brent = "Brent crude — the global oil benchmark. Rising oil is both a demand signal and an inflation/cost input; spikes can tip the cycle.",
  wti = "WTI crude — the US oil benchmark. Same read as Brent; the Brent–WTI gap reflects US vs global supply/demand.",
  henry_hub_gas = "Henry Hub natural gas — the US gas price. Drives heating/industrial input costs; very weather- and storage-sensitive.",
  copper_global = "Copper ('Dr. Copper') — used across industry, so its price reads global growth/demand. Rising = firm demand; rolling over flags softening activity ahead.",
  # --- consumer / housing ---
  umich_sentiment = "UMich consumer sentiment — leading for discretionary spending (the expectations component leads). Sharp drops precede pullbacks. (1-month FRED publication delay.)",
  retail_sales_control_group = "Retail sales 'control group' (ex autos/gas/building materials) — the cleanest consumer-spending read, feeding directly into GDP. Coincident.",
  building_permits = "Building permits — the earliest housing signal (you permit before you build). Rate-sensitive and a classic cycle leader.",
  housing_starts = "Housing starts — construction actually begun. Housing turns first in the cycle; starts follow permits.",
  new_home_sales = "New single-family home sales (Census; seasonally adjusted annual rate, thousands) — builders' real-time demand and a leading read on housing activity; highly rate-sensitive.",
  mortgage_rate_30y = "Average 30-year fixed mortgage rate (Freddie Mac weekly survey) — the price of housing credit; rising rates cool purchase demand within weeks.",
  # --- markets / uncertainty ---
  sp500 = "S&P 500 — the broad US equity market, which discounts the future and is itself a leading indicator. (FRED history is ~10y.)",
  vix = "VIX — S&P 500 implied volatility, the market's 'fear gauge.' Calm under ~20; >20 elevated; >30 signals stress/risk-off.",
  broad_usd = "Broad trade-weighted US dollar. A strong dollar tightens global financial conditions (hurts EM, commodities, US exporters) — a key cross-asset driver.",
  epu_us_daily = "US Economic Policy Uncertainty (daily, news-based). Spikes around policy/political shocks; an overlay that helps explain risk-off moves elsewhere.",
  epu_global = "Global Economic Policy Uncertainty (monthly). A broad gauge of worldwide policy risk; sustained highs weigh on investment and growth.",
  # --- bubbles ---
  buffett_indicator = "Corporate equity value ÷ GDP (the Z.1 'Buffett indicator') — how richly the whole market is valued vs the economy. ~1.0 historically normal; ~2.0+ is very stretched. Read as low margin of safety, not crash timing.",
  stocks_vs_bonds_euro_area = "Expected real returns, stocks vs bonds, for the euro area, built like the US tile from ECB data. Stocks: the after-tax earnings yield of euro-area non-financial corporations, their net entrepreneurial income minus taxes on income over the last four quarters, over the value of all the equity they have issued (listed and unlisted shares and other equity). Bonds: the 10-year yield on AAA-rated euro-area government bonds minus the longer-term inflation expectation in the ECB's Survey of Professional Forecasters. The value is the gap. Unlisted equity is valued differently from country to country, so the level isn't comparable with the US tile: the badge reads the gap against its own history since 2004. The accounts are quarterly and about three months behind, and cover the 21 countries in the euro area since 2026. The stocks line moves in quarterly steps because the accounts value shares only at quarter ends; the bond line is daily, so between steps only bonds move the gap.",
  stocks_vs_bonds_real = "Expected real returns, stocks vs bonds (after Ray Dalio). Stocks: the earnings yield of US nonfinancial corporations — after-tax profits over the market value of their shares, the real return priced into stocks in steady state. Bonds: the expected real yield on 10-year Treasuries, the nominal yield minus the Cleveland Fed's 10-year expected inflation. The value is the gap; near zero, stocks pay no extra expected return for their risk (the lines last crossed in 1999–2002). Earnings are quarterly and lag about three months: the stocks line moves in quarterly steps because the accounts value shares only at quarter ends, while the bond line is daily, so between steps only bonds move the gap.",
  real_10y_yield = "10-year TIPS (real) yield — the inflation-adjusted cost of money and the 'cheap-money fuel' gauge. Deeply negative real yields inflate valuations; rising real yields deflate them.",
  ipo_spac_issuance = "IPO & SPAC issuance — speculative supply that floods in at manias and dries up in busts. No free, republishable data; the tile links to public trackers.",
  case_shiller_price_rent = "Home price-to-rent ratio — housing's valuation gauge (a P/E for houses). Far above its history = stretched and rate-sensitive; same 'margin of safety' read as equity valuation.",
  household_debt_service_ratio = "Household debt-service ratio — debt payments as a share of disposable income. Rising = households more fragile to shocks; a slow-burning systemic-risk gauge.",
  # --- global (G1) ---
  ea_10y = "Euro-area 10-year government bond yield — the ECB's long-term interest rate for convergence purposes, averaged across member states; the benchmark long rate for the bloc. Rising yields tighten conditions.",
  de_10y = "German 10-year Bund yield — the euro area's risk-free benchmark and safe haven; the anchor other euro yields are spread against.",
  fr_10y = "French 10-year OAT yield — its spread over the Bund gauges core-euro political/fiscal risk.",
  it_10y = "Italian 10-year BTP yield — the BTP–Bund spread is the classic euro-area stress/fragmentation gauge; widening signals periphery risk.",
  uk_10y = "UK 10-year Gilt yield — the benchmark long rate for the UK; reflects growth, inflation and fiscal risk.",
  jp_10y = "Japanese 10-year JGB yield — long suppressed by BoJ policy; a rising JGB yield can ripple into global rates as Japanese capital repatriates.",
  ca_10y = "Canadian 10-year yield — a commodity-economy benchmark that tends to track US rates closely.",
  cli_g7 = "OECD CLI for the G7 — the developed-world cycle. 100 = trend; above & rising = expansion, rolling below 100 flags a slowdown.",
  cli_uk = "OECD CLI for the UK — built to lead UK turning points. 100 = trend.",
  cli_japan = "OECD CLI for Japan — leads the Japanese cycle. 100 = trend.",
  cli_germany = "OECD CLI for Germany — the euro area's largest economy and a useful euro-cycle proxy (no euro-area aggregate CLI is published). 100 = trend.",
  cli_china = "OECD CLI for China — China's cycle leads the global industrial cycle by ~6–12 months. Below & falling is an early global-slowdown warning. 100 = trend.",
  cli_india = "OECD CLI for India — leads the cycle of the fastest-growing large economy. 100 = trend.",
  cli_korea = "OECD CLI for Korea — an early global tech/trade-cycle tell. 100 = trend.",
  cli_brazil = "OECD CLI for Brazil — a major EM/commodity economy. 100 = trend.",
  unemp_uk = "UK unemployment rate from the ONS Labour Force Survey (aged 16+, seasonally adjusted; each month is the middle of a rolling three-month period). Lagging, but the trend signals labor-market health and feeds BoE policy.",
  unemp_japan = "Japan harmonised unemployment rate — structurally very low, so upticks are meaningful.",
  unemp_germany = "Germany harmonised unemployment rate — a read on the euro area's core economy.",
  hicp_ea = "Euro-area HICP inflation (year-over-year) — the ECB's target gauge; ~2% is target. The key euro-area inflation print.",
  hicp_eu = "EU-wide HICP inflation (YoY) — broader than the euro area; ~2% target.",
  hicp_de = "German HICP inflation (YoY) — the largest euro-area member; ~2% target.",
  hicp_fr = "French HICP inflation (YoY) — second-largest euro-area economy; ~2% target.",
  # --- global (G2) ---
  rate_3m_euro = "3-month spot yield on AAA-rated euro-area government bonds, from the ECB's daily yield curve — a market-based read of where the ECB policy rate is expected over the next three months.",
  rate_3m_uk = "SONIA, the sterling overnight risk-free rate run by the Bank of England. It moves with Bank Rate, so it shows the BoE's current policy stance.",
  rate_3m_japan = "Uncollateralized overnight call rate (daily average), the Bank of Japan's policy target — its level shows how far Japan has moved away from ultra-loose policy.",
  rate_3m_canada = "Canada 3-month interbank rate — a current proxy for the Bank of Canada policy stance.",
  cpi_uk = "UK CPI inflation (year-over-year). ~2% is the BoE target. From the IMF's CPI dataset, which runs a few weeks behind the national release.",
  cpi_japan = "Japan CPI inflation (YoY) — meaningful given decades of deflation; the BoJ targets ~2%. From the IMF's CPI dataset, a few weeks behind the national release.",
  cpi_china = "China CPI inflation (YoY) — persistently low/deflationary inflation has been a key signal of weak domestic demand. From the IMF's CPI dataset, a few weeks behind the national release.",
  cpi_india = "India CPI inflation (YoY) — the RBI's target gauge (~4% midpoint). From the IMF's CPI dataset, a few weeks behind the national release.",
  pmi_euro = "Euro-area Composite/Manufacturing PMI. 50 = expansion/contraction line; the new-orders subindex is among the best leading signals. Licensed: manual tile.",
  pmi_uk = "UK PMI. 50 = expansion line; a timely lead on activity. Licensed: manual tile.",
  pmi_japan = "Japan PMI (au Jibun Bank). 50 = expansion line. Licensed: manual tile.",
  pmi_china = "China Caixin PMI — the private-sector read (vs the official NBS PMI), a key global-cycle tell. 50 = expansion line. Licensed: manual tile.",
  pmi_india = "India PMI. 50 = expansion line; India's manufacturing/services momentum. Licensed: manual tile."
)

#' Panel help text for a view id (empty string if none).
view_help <- function(view_id) VIEW_HELP[[view_id]] %||% ""

#' Card help text for an entry (falls back to a generic line).
card_help <- function(entry) {
  CARD_HELP[[entry$id]] %||%
    sprintf("%s — %s indicator (%s, %s).", display_title(entry),
            entry$indicator_class %||% "", entry$provider %||% "source",
            entry$frequency %||% "")
}
