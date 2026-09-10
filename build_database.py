"""
IceGolem Recovery Salt — Market Survey ETL
Cleans the raw Google Forms export and loads it into a normalized SQLite database
(sqlite chosen so the whole project is a single portable .db file — no server setup needed).

Run: python3 build_database.py
Produces: icegolem_survey.db
"""

import pandas as pd
import sqlite3
import re

RAW_CSV = "raw_survey_responses.csv"
DB_PATH = "icegolem_survey.db"

# ---------------------------------------------------------------------------
# 1. Load and rename columns to clean, query-friendly names
# ---------------------------------------------------------------------------
df = pd.read_csv(RAW_CSV)

df.columns = [
    "timestamp",
    "age_group",
    "workout_frequency",
    "recovery_methods_raw",
    "prior_product_usage",
    "purchase_intent",
    "motivations_raw",
    "price_comfort",
    "packaging_preference",
    "product_expectations",
    "early_tester_optin",
    "contact_info",
]

df.insert(0, "respondent_id", range(1, len(df) + 1))

# ---------------------------------------------------------------------------
# 2. Clean values — trim whitespace, standardize casing, fix known typos
# ---------------------------------------------------------------------------
text_cols = [
    "age_group", "workout_frequency", "prior_product_usage",
    "purchase_intent", "price_comfort", "packaging_preference",
    "early_tester_optin",
]
for col in text_cols:
    df[col] = df[col].astype(str).str.strip()

df["purchase_intent"] = df["purchase_intent"].str.lower()
df["prior_product_usage"] = df["prior_product_usage"].str.lower()
df["early_tester_optin"] = df["early_tester_optin"].str.title()

# packaging: normalize the smart-apostrophe "Doesn't matter" variant
df["packaging_preference"] = df["packaging_preference"].replace(
    {"Doesn\u2019t matter": "No preference", "nan": "No preference"}
)

# drop free-text PII column from the analytical dataset (not needed for the
# business questions and keeps respondent data anonymous in the DB)
has_contact = df["contact_info"].notna() & (df["contact_info"].astype(str).str.strip() != "") \
              & (df["contact_info"].astype(str) != "nan")

# ---------------------------------------------------------------------------
# 3. Core respondents table (one row per person, anonymized)
# ---------------------------------------------------------------------------
respondents = df[[
    "respondent_id", "timestamp", "age_group", "workout_frequency",
    "prior_product_usage", "purchase_intent", "price_comfort",
    "packaging_preference", "early_tester_optin",
]].copy()
respondents["gave_contact_info"] = has_contact.astype(int)  # anonymized signal, not the raw contact

# ---------------------------------------------------------------------------
# 4. Normalize multi-select fields into junction tables
#    (recovery methods + motivations were "select all that apply" in the form)
# ---------------------------------------------------------------------------
def explode_multiselect(frame, raw_col, out_name):
    rows = []
    for rid, raw in zip(frame["respondent_id"], frame[raw_col]):
        if pd.isna(raw):
            continue
        items = [x.strip() for x in str(raw).split(",") if x.strip()]
        for item in items:
            item = re.sub(r"^Other:?$", "Other", item)
            item = item.replace("Streching", "Stretching")  # fix form typo
            if item and item.lower() != "nan":
                rows.append({"respondent_id": rid, out_name: item})
    return pd.DataFrame(rows)

recovery_methods = explode_multiselect(df, "recovery_methods_raw", "recovery_method")
motivations = explode_multiselect(df, "motivations_raw", "motivation")

# ---------------------------------------------------------------------------
# 5. Write everything to SQLite
# ---------------------------------------------------------------------------
conn = sqlite3.connect(DB_PATH)
respondents.to_sql("respondents", conn, if_exists="replace", index=False)
recovery_methods.to_sql("recovery_methods", conn, if_exists="replace", index=False)
motivations.to_sql("motivations", conn, if_exists="replace", index=False)
conn.commit()
conn.close()

print(f"Loaded {len(respondents)} respondents into {DB_PATH}")
print(f"  recovery_methods rows: {len(recovery_methods)}")
print(f"  motivations rows: {len(motivations)}")
