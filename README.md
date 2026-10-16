# Greater Houston Real Estate: Market Velocity & Friction Analysis

## Executive Summary
This project analyzes **57,251 market records** across **97 Houston zip codes** (spanning 2012 to 2026) to evaluate time-series price velocity and inventory friction. By engineering month-over-month price change metrics and tracking Days on Market (DOM) acceleration, this pipeline isolates real estate liquidity shifts across core Houston sub-markets.

- **Live Dashboard:** [Interactive Tableau Public Dashboard](https://public.tableau.com/app/profile/abel.rodriguez7535/viz/GreaterHoustonRealEstateMarketVelocityFrictionAnalysis/Dashboard1)
- ![Houston Real Estate Dashboard Preview](dashboard_preview.png)
- **Tech Stack:** Python, Pandas, DuckDB (ANSI SQL), Tableau Public, Google Colab

---

## Technical Architecture & Pipeline

1. **Ingestion & Standardisation (`Python/Pandas`):**
   - Extracted historical zip-code level data from Redfin market trackers.
   - Standardised geographic attributes, handled missing inventory edge cases, and cleaned date formats across 97 Houston zip codes.

2. **Feature Engineering & Analytics (`DuckDB SQL`):**
   - Executed vectorized SQL window functions (`LAG()`) over partitioned zip-code boundaries to compute Month-over-Month (MoM) price velocity.
   - Applied rolling 3-month window frames (`ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`) to smooth out seasonal inventory anomalies.

```sql
-- Excerpt: DuckDB SQL Window Function for MoM Price Velocity
SELECT 
    zip_code,
    period_begin,
    median_sale_price,
    LAG(median_sale_price, 1) OVER (
        PARTITION BY zip_code ORDER BY period_begin ASC
    ) AS prior_month_price,
    ROUND(
        ((median_sale_price - LAG(median_sale_price, 1) OVER (PARTITION BY zip_code ORDER BY period_begin ASC)) 
        / NULLIF(LAG(median_sale_price, 1) OVER (PARTITION BY zip_code ORDER BY period_begin ASC), 0)) * 100, 2
    ) AS mom_price_change_pct
FROM base_market;
