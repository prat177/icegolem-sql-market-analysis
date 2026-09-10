# IceGolem Recovery Salt — Market Validation SQL Analysis

**Author:** Prateek Tripathi
**Context:** IceGolem is a self-founded, MSME-registered wellness startup. Before investing capital, I ran a 25-respondent market survey (Google Forms, July 2025) covering purchase intent, price sensitivity, motivations, and packaging preference. This project turns that raw survey export into a structured SQL database and answers 8 real business questions that shaped the venture's pricing and go-to-market decisions.

## Stack
- **Python (pandas)** — cleans the raw Google Forms CSV export, normalizes multi-select fields ("select all that apply" questions) into proper relational tables
- **SQLite** — single-file relational database, chosen for portability
- **SQL** — all analysis is done via SQL queries, not pandas, to demonstrate query-writing directly

## Files
| File | Purpose |
|---|---|
| `raw_survey_responses.csv` | Original Google Forms export (25 responses) |
| `build_database.py` | ETL script: cleans data, normalizes multi-select fields, loads into SQLite |
| `icegolem_survey.db` | Resulting SQLite database (3 tables) |
| `analysis_queries.sql` | 8 business-question SQL queries |
| `README.md` | This file — questions, queries, and insights |

## Schema
```
respondents (respondent_id, timestamp, age_group, workout_frequency,
             prior_product_usage, purchase_intent, price_comfort,
             packaging_preference, early_tester_optin, gave_contact_info)

recovery_methods (respondent_id, recovery_method)   -- normalized multi-select
motivations (respondent_id, motivation)              -- normalized multi-select
```
Multi-select form fields ("select all that apply") were exploded into junction tables rather than left as comma-separated strings, so they can be aggregated with normal `GROUP BY` / `JOIN` queries instead of string-matching.

## Business Questions & Findings

**Q1 — Overall purchase intent**
44% said yes, 40% said maybe, 16% said no. Real interest exists, but the "maybe" segment is nearly as large as "yes" — meaning conversion depends heavily on how the product is positioned at point of purchase, not just awareness.

**Q2 — Does price sensitivity predict purchase intent?**
Of respondents comfortable paying "Below ₹200," 7 of 13 said yes (54%). Of those comfortable at "₹200–₹299," only 4 of 12 said yes (33%). **Price was not the main blocker for the higher-budget group — interest dropped despite higher price tolerance**, suggesting the value proposition, not the price point, needed sharper positioning. This directly informed keeping the entry price low to reduce trial friction rather than assuming price was the objection.

**Q3 — Does prior category experience predict interest?**
People who had "heard of but never used" recovery salts converted to "yes" at the highest rate (55.6%), ahead of people with no exposure at all (42.9%). People who had already used recovery salts before said yes 0% of the time (small sample, n=2) — possibly prior brand loyalty or a bad past experience. **Implication: the biggest opportunity is category-aware-but-not-yet-tried customers, not total newcomers.**

**Q4 — Top motivations to try the product**
"Stress relief" and "Faster recovery" tied as the top motivators (56% each), ahead of "Better performance" (48%) and "Reduces soreness" (40%). This directly shaped which benefit claims to lead with in marketing copy — stress relief was not the originally assumed primary driver.

**Q5 — Packaging preference vs. interest**
"Single-use sachets" had both the most respondents (8) and the highest count of interested respondents (6/8) — the strongest packaging format for trial conversion. "No preference" respondents were split, and "Jar"/"Refill pouch" preference did not translate to higher interest. This supported prioritizing a sachet-based trial SKU over committing to jars first.

**Q6 — Workout frequency vs. purchase intent**
Daily exercisers said yes at 71.4% — by far the highest of any segment, more than double the next group. Occasional and 3–5x/week exercisers converted similarly (~33%). **This is the clearest, strongest finding in the dataset: daily exercisers are the core target segment**, not the broader "anyone active" audience originally assumed.

**Q7 — Early-tester funnel**
Of the 11 "yes" respondents, 9 opted into early testing and all 9 gave real contact info — a clean, high-intent funnel with no drop-off. Of the 10 "maybe" respondents, 6 opted in but only 3 gave real contact info — roughly half of stated interest converts to an actionable lead. This is a useful benchmark for future sample-distribution planning.

**Q8 — "No recovery routine" segment**
Only 7 respondents reported having no recovery routine at all, split across yes/maybe/no. This segment was smaller than expected and not meaningfully more likely to convert — so "people with no existing habit to displace" was not, on this data, an especially high-converting wedge on its own.

## Honest limitations
- n=25 — directional signal for a founder decision, not statistically powered for hard claims. All percentages should be read as "signal" not "certainty."
- No linked conversion (who became a paying customer) is joined here — this survey and the trial/conversion tracking were separate processes at the time, so intent and actual purchase can't be directly correlated in this dataset yet.
- Self-reported price sensitivity, not observed purchase behavior.
