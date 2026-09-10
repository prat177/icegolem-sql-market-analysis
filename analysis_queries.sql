-- ============================================================================
-- IceGolem Recovery Salt — Market Survey Analysis
-- Database: icegolem_survey.db  (SQLite)
-- 25 respondents, Google Forms survey, July 2025
-- ============================================================================


-- ----------------------------------------------------------------------------
-- Q1. Overall purchase intent — how many people are actually interested?
-- ----------------------------------------------------------------------------
SELECT
    purchase_intent,
    COUNT(*) AS respondents,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM respondents), 1) AS pct_of_total
FROM respondents
GROUP BY purchase_intent
ORDER BY respondents DESC;


-- ----------------------------------------------------------------------------
-- Q2. Does price sensitivity relate to purchase intent?
--     (Are the "below ₹200" respondents the same people who are NOT interested,
--      or is price not actually the blocker?)
-- ----------------------------------------------------------------------------
SELECT
    price_comfort,
    purchase_intent,
    COUNT(*) AS respondents
FROM respondents
GROUP BY price_comfort, purchase_intent
ORDER BY price_comfort, purchase_intent;


-- ----------------------------------------------------------------------------
-- Q3. Does prior category experience (used/heard of/never) predict interest?
--     Tests whether category education is a bigger lever than price.
-- ----------------------------------------------------------------------------
SELECT
    prior_product_usage,
    COUNT(*) AS total_respondents,
    SUM(CASE WHEN purchase_intent = 'yes' THEN 1 ELSE 0 END) AS said_yes,
    ROUND(100.0 * SUM(CASE WHEN purchase_intent = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_yes
FROM respondents
GROUP BY prior_product_usage
ORDER BY pct_yes DESC;


-- ----------------------------------------------------------------------------
-- Q4. Top motivations for trying the product (multi-select, normalized)
--     Ranks the reasons — directly informs marketing/positioning copy.
-- ----------------------------------------------------------------------------
SELECT
    motivation,
    COUNT(*) AS mentions,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(DISTINCT respondent_id) FROM motivations), 1) AS pct_of_respondents
FROM motivations
GROUP BY motivation
ORDER BY mentions DESC;


-- ----------------------------------------------------------------------------
-- Q5. Packaging preference — does it vary by purchase intent?
--     Informs which SKU/format to lead with for launch.
-- ----------------------------------------------------------------------------
SELECT
    packaging_preference,
    COUNT(*) AS respondents,
    SUM(CASE WHEN purchase_intent = 'yes' THEN 1 ELSE 0 END) AS interested_respondents
FROM respondents
GROUP BY packaging_preference
ORDER BY respondents DESC;


-- ----------------------------------------------------------------------------
-- Q6. Workout frequency vs. purchase intent
--     Tests the assumption that heavier/frequent exercisers are the core buyers.
-- ----------------------------------------------------------------------------
SELECT
    workout_frequency,
    COUNT(*) AS total,
    SUM(CASE WHEN purchase_intent = 'yes' THEN 1 ELSE 0 END) AS said_yes,
    ROUND(100.0 * SUM(CASE WHEN purchase_intent = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_yes
FROM respondents
GROUP BY workout_frequency
ORDER BY pct_yes DESC;


-- ----------------------------------------------------------------------------
-- Q7. Early-tester funnel — of those interested, how many opted in
--     and how many gave real contact info (highest-intent signal)?
-- ----------------------------------------------------------------------------
SELECT
    purchase_intent,
    COUNT(*) AS respondents,
    SUM(CASE WHEN early_tester_optin = 'Yes' THEN 1 ELSE 0 END) AS opted_into_testing,
    SUM(gave_contact_info) AS gave_real_contact_info
FROM respondents
GROUP BY purchase_intent
ORDER BY respondents DESC;


-- ----------------------------------------------------------------------------
-- Q8. Most common recovery-method combinations among "no recovery routine" people
--     (identifies the true white-space segment — no competing habit to displace)
-- ----------------------------------------------------------------------------
SELECT
    r.purchase_intent,
    COUNT(DISTINCT r.respondent_id) AS respondents
FROM respondents r
JOIN recovery_methods rm ON rm.respondent_id = r.respondent_id
WHERE rm.recovery_method = 'I dont have a recovery routine'
GROUP BY r.purchase_intent;
