-- Phase 1 Week 2: Month-over-Month Price Velocity & Market Friction Feature Engineering
WITH raw_metrics AS (
    SELECT 
        CAST(zip_code AS VARCHAR) AS zip_code,
        CAST(period_begin AS DATE) AS period_begin,
        CAST(median_sale_price AS FLOAT) AS current_sale_price,
        CAST(median_list_price AS FLOAT) AS current_list_price,
        CAST(median_dom AS FLOAT) AS median_dom
    FROM read_csv_auto('houston_real_estate_clean.csv')
    WHERE zip_code IS NOT NULL
),
windowed_prices AS (
    SELECT 
        zip_code,
        period_begin,
        current_sale_price,
        
        -- Pull prior month's median sale price per zip code
        LAG(current_sale_price, 1) OVER (
            PARTITION BY zip_code 
            ORDER BY period_begin ASC
        ) AS prior_month_sale_price,

        -- Pull prior month's median list price per zip code
        LAG(current_list_price, 1) OVER (
            PARTITION BY zip_code 
            ORDER BY period_begin ASC
        ) AS prior_month_list_price,

        median_dom
    FROM raw_metrics
)
SELECT 
    zip_code,
    period_begin,
    current_sale_price,
    prior_month_sale_price,
    
    -- Absolute Dollar Delta
    ROUND(current_sale_price - prior_month_sale_price, 2) AS mom_price_change_dollars,
    
    -- Percentage Growth Rate Formula: ((Current - Prior) / Prior) * 100
    ROUND(
        ((current_sale_price - prior_month_sale_price) / NULLIF(prior_month_sale_price, 0)) * 100, 
        2
    ) AS mom_price_change_pct,
    
    median_dom
FROM windowed_prices
WHERE period_begin >= '2024-01-01'
  AND prior_month_sale_price IS NOT NULL
ORDER BY zip_code ASC, period_begin DESC;
