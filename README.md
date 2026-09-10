# IceGolem Recovery Salt — Market Validation & SQL Analysis

**Author:** Prateek Tripathi  
**Project:** IceGolem Recovery Salt  
**Research:** 25-respondent market survey, July 2025

## Overview

This project uses a real founder decision from **IceGolem**, a recovery and performance startup, as a practical SQL analytics case study.

Before committing more capital to the product, I ran a 25-respondent market survey covering purchase intent, workout frequency, prior category experience, price comfort, recovery behavior, motivations, packaging preference, and willingness to become an early tester.

The goal was not simply to practice SQL. The goal was to turn raw customer research into **actionable decisions about positioning, target customers, pricing, packaging, and early-market validation**.

> **Important:** This is a directional founder-research project (n=25), not a statistically representative market study.

## Business questions answered

1. What proportion of respondents are interested in trying IceGolem Recovery Salt?
2. Does price comfort appear to relate to purchase intent?
3. Does prior category experience predict interest?
4. What benefits motivate people to try the product?
5. Which packaging format has the strongest relationship with interest?
6. Which workout-frequency segment shows the strongest purchase intent?
7. How much stated interest turns into an actionable early-tester lead?
8. Is the "no recovery routine" segment an attractive whitespace opportunity?

## Key findings

| Finding | Signal | Business implication |
|---|---:|---|
| Purchase intent | 44% yes / 40% maybe / 16% no | There is meaningful interest, but conversion requires stronger value communication. |
| Top motivations | Faster recovery + Stress relief: 56% each | Marketing should lead with recovery and stress-relief benefits rather than performance alone. |
| Strongest workout segment | Daily exercisers: 71.4% yes | Frequent exercisers are the clearest initial target segment in this sample. |
| Packaging | Single-use sachets: 6 of 8 interested | A sachet-based trial SKU is a strong launch hypothesis. |
| Category awareness | Heard of but never used: 55.6% yes | Category-aware non-users may be a more attractive acquisition segment than total newcomers. |
| Early-test funnel | 9/11 yes respondents opted in | Stated interest translated into strong early-testing intent among the highest-intent group. |

These findings are signals from a small sample and should be validated with observed purchasing behavior.

## Analytical approach

```text
Google Forms survey
        ↓
Raw survey export
        ↓
Python / pandas cleaning
        ↓
Normalize multi-select responses
        ↓
SQLite relational database
        ↓
SQL business questions
        ↓
Founder decisions
```

### Stack

- **Python / pandas** — data cleaning and ETL
- **SQLite** — portable relational database
- **SQL** — analysis and aggregation
- **GitHub** — reproducible project documentation

## Database design

The database contains three analytical tables:

```text
respondents
├── respondent_id
├── timestamp
├── age_group
├── workout_frequency
├── prior_product_usage
├── purchase_intent
├── price_comfort
├── packaging_preference
├── early_tester_optin
└── gave_contact_info

recovery_methods
├── respondent_id
└── recovery_method

motivations
├── respondent_id
└── motivation
```

The multi-select survey questions are stored in separate relational tables rather than as comma-separated strings. This makes them suitable for normal `JOIN`, `GROUP BY`, `COUNT`, and conditional aggregation queries.

## Files

| File | Purpose |
|---|---|
| `build_database.py` | Cleans survey data, normalizes multi-select fields, and builds the SQLite database. |
| `icegolem_survey.db` | SQLite database used for the analysis. |
| `analysis_queries.sql` | Eight business-focused SQL analyses. |
| `README.md` | Project methodology, findings, and limitations. |

### Data privacy

The original survey export contained optional respondent contact information. Because this repository is public, the raw response export is intentionally **not distributed here**. The analytical database retains only an anonymized `gave_contact_info` indicator rather than email addresses or social handles.

## Example SQL techniques

The analysis demonstrates:

- `GROUP BY` and aggregation
- conditional aggregation with `CASE WHEN`
- percentage calculations
- subqueries
- relational joins
- normalized multi-select analysis
- funnel analysis
- segmentation by behavioral variables

Example:

```sql
SELECT
    workout_frequency,
    COUNT(*) AS total,
    SUM(CASE WHEN purchase_intent = 'yes' THEN 1 ELSE 0 END) AS said_yes,
    ROUND(
        100.0 * SUM(CASE WHEN purchase_intent = 'yes' THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS pct_yes
FROM respondents
GROUP BY workout_frequency
ORDER BY pct_yes DESC;
```

## Limitations

- **Sample size:** n=25, so findings are directional rather than statistically powered.
- **Sampling:** respondents were not selected through a representative probability sample.
- **Intent vs. behavior:** purchase intent was self-reported and is not equivalent to an actual transaction.
- **Price:** price sensitivity reflects stated comfort, not observed willingness to pay.
- **Conversion linkage:** survey responses were not originally joined to later customer transactions, so the project cannot claim that stated intent caused actual purchases.

## Why this project matters

This project demonstrates a practical analytics workflow: **start with a real business decision, structure messy customer data, ask commercially relevant questions, and translate SQL output into decisions.**

For IceGolem, the immediate hypotheses generated by the analysis were to:

1. prioritize frequent exercisers as an initial customer segment;
2. test sachets as a low-friction trial format;
3. lead messaging with recovery and stress relief;
4. target people who know about recovery products but have not tried them; and
5. validate these hypotheses against real sales and repeat-purchase data.

The next analytical step is to connect this research dataset with actual trial, purchase, and repeat-purchase outcomes.
