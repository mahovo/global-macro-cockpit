<!-- China & Leaders. Every statement is sourced; see .claude/guide_checklist.md.
     Code: R/views.R, R/display.R (cpi_india line 4; no line for cpi_china), R/assess.R
     (assess_cli; BADGE_BANDS$cpi_india; no badge for cpi_china), instructions/sources_global.yaml.
     Publisher documentation: OECD DF_CLI dataflow description (see Cycle & Growth); National Bureau
     of Statistics of China CPI releases for June, July and August 2026 (stats.gov.cn); Reserve Bank
     of India monetary policy framework page (target, band, 2016/2021/2026 reviews); IMF CPI dataset
     description. India's statistics ministry site renders by JavaScript; India values unchecked
     against the national release (pending).
     History: computed 2026-10-09 (scratch china.R). -->

{{tab china}}

Four large economies outside the G7, through the same OECD leading indicators used on the
Cycle & Growth tab ([China](#cli_china), [India](#cli_india), [Korea](#cli_korea),
[Brazil](#cli_brazil)), plus consumer-price inflation for [China](#cpi_china) and
[India](#cpi_india) from the IMF's CPI dataset, and licensed purchasing managers' indexes for
[China](#pmi_china) and [India](#pmi_india) as links. China's leading indicator is also the
growth input of the [China regime tile](#regime_china).

The leading-indicator tiles carry the same badge as the other OECD indicators. Of the two
inflation tiles, only India's has a badge, read against the Reserve Bank of India's own
target band.

<!-- tiles -->

{{tile cli_china lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The OECD's composite leading indicator for China, amplitude adjusted.

#### Computation

From the OECD's data API (DF_CLI, area CHN); the dashboard shows it unchanged. The OECD's
description of its CLIs is in the [Cycle & Growth](#tab-cycle) section.

#### Reading it

{{badge cli_china var="\text{CLI}_n"}}

From May 1992 it averaged 100.0 and was at or above 100 in 57% of months; its highest value
was 106.4 (September 2007) and its lowest 85.6 (March 2020). In September 2026 it was 97.41,
down from 97.64.

#### Use in practice

Its 3-month change is the growth input of the [China regime tile](#regime_china), which
placed China in Stagflation in August 2026.

#### Caveats

- **Revised**, as for all CLIs.

{{tile cli_india lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The OECD's composite leading indicator for India, amplitude adjusted.

#### Computation

From the OECD's data API (DF_CLI, area IND); the dashboard shows it unchanged.

#### Reading it

{{badge cli_india var="\text{CLI}_n"}}

From April 1994 it averaged 100.0 and was at or above 100 in 49% of months; its highest
value was 104.4 (February 2000) and its lowest 67.1 (April 2020). In September 2026 it was
102.00, up from 101.82.

#### Use in practice

Compare it with India's [CPI inflation](#cpi_india).

#### Caveats

- **Revised**, as for all CLIs.

{{tile cli_korea lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The OECD's composite leading indicator for Korea, amplitude adjusted.

#### Computation

From the OECD's data API (DF_CLI, area KOR); the dashboard shows it unchanged.

#### Reading it

{{badge cli_korea var="\text{CLI}_n"}}

From January 1990 it averaged 100.0 and was at or above 100 in 49% of months; its highest
value was 105.5 (September 1999) and its lowest 94.8 (March 1998). In September 2026 it was
102.53, down from 102.66.

#### Use in practice

Compare it with the [G20](#oecd_cli) and [China](#cli_china) indicators.

#### Caveats

- **Revised**, as for all CLIs.

{{tile cli_brazil lag="monthly; September 2026 was available by 9 October 2026"}}

#### What it is

The OECD's composite leading indicator for Brazil, amplitude adjusted.

#### Computation

From the OECD's data API (DF_CLI, area BRA); the dashboard shows it unchanged.

#### Reading it

{{badge cli_brazil var="\text{CLI}_n"}}

From January 1989 it averaged 100.0 and was at or above 100 in 50% of months; its highest
value was 104.2 (January 2021) and its lowest 93.3 (April 2020). In September 2026 it was
102.36, down from 102.44.

#### Use in practice

Compare it with the [G20 indicator](#oecd_cli).

#### Caveats

- **Revised**, as for all CLIs.

{{tile cpi_china lag="monthly; August 2026 was the latest on 9 October 2026 (the NBS released August on 10 September)"}}

#### What it is

Chinese consumer price inflation, % change over twelve months, from the IMF's CPI dataset,
which carries each economy's national all-items headline index.

#### Computation

From the IMF data API (dataset IMF.STA CPI, China, all items, % change over 12 months); the
dashboard shows it unchanged. For June, July and August 2026 it matches the rates the
National Bureau of Statistics of China published: 1.0%, 0.5% and 0.8%.

#### Reading it

There is no badge or reference line: no official inflation target for China has been
verified for this guide. From January 1994 the rate ranged from −2.2% (May 1999) to 27.7%
(October 1994). Since 2000 it was negative in 41 months, most recently in September 2025,
and since 2023 it has been below 1% in 86% of months. In August 2026 it was 0.8%.

#### Use in practice

It is the inflation input of the [China regime tile](#regime_china), which reads its
direction, not its level.

#### Caveats

- **A copy of the national figure**: the NBS released August 2026 on 10 September; the
  IMF's copy had it by 9 October.

{{tile cpi_india lag="monthly; July 2026 was the latest on 9 October 2026"}}

#### What it is

Indian consumer price inflation, % change over twelve months, from the IMF's CPI dataset.
The Reserve Bank of India's framework: under the RBI Act, the central government, in
consultation with the RBI, sets the inflation target in terms of CPI every five years. It
was set at 4% with a tolerance band of 2% to 6% in August 2016 and retained in the reviews
of March 2021 and of 25 March 2026, the latter for April 2026 to March 2031.

#### Computation

From the IMF data API (dataset IMF.STA CPI, India, all items, % change over 12 months); the
dashboard shows it unchanged.

#### Reading it

{{badge cpi_india var="\pi_n"}}

The reference line is at the 4% target; the badge reads the RBI's band. Since August 2016
the rate was within the band in 71% of months, above 6% in 23% and below 2% in 6%. In July
2026 it was 4.44%.

#### Use in practice

The RBI's framework names failure as average inflation outside the band for three
consecutive quarters; the badge reads single months.

#### Caveats

- **A copy, not the national release**: the figures have not been checked against India's
  statistics ministry for this guide.

{{tile pmi_china}}

#### What it is

S&P Global's purchasing managers' index for China. The data are licensed, so the tile
shows no figures and links to S&P Global's PMI releases.

#### Reading it

The tile has no data, badge or reference line.

{{tile pmi_india}}

#### What it is

S&P Global's purchasing managers' index for India; licensed, so the tile links to S&P
Global's PMI site.

#### Reading it

The tile has no data, badge or reference line.
