import pandas as pd
import numpy as np

# 1. Download and Ingest Raw Redfin Houston Zip Code Dataset
url = 'https://redfin-public-data.s3.us-west-2.amazonaws.com/redfin_market_tracker/zip_code_market_tracker.tsv.gz'

print("Ingesting raw market tracker data...")
df = pd.read_csv(url, sep='\t', compression='gzip', low_memory=False)

# 2. Filter specifically for Houston, TX zip codes
houston_df = df[
    (df['state_code'] == 'TX') & 
    (df['city'] == 'Houston') & 
    (df['property_type'] == 'Single Family Residential')
].copy()

# 3. Clean and Standardize Data Types
houston_df['period_begin'] = pd.to_datetime(houston_df['period_begin'])
houston_df['zip_code'] = houston_df['region'].str.extract(r'(\d{5})')

# 4. Select Core Analytical Columns
selected_cols = [
    'period_begin', 'zip_code', 'median_sale_price', 
    'median_list_price', 'inventory', 'homes_sold', 'median_dom'
]
houston_df = houston_df[selected_cols].dropna(subset=['zip_code', 'period_begin']).sort_values(['zip_code', 'period_begin'])

print(f"--- INGESTION COMPLETE & STANDARDIZED ---")
print(f"Total Houston Rows Ingested: {len(houston_df):,}")
print(f"Unique Houston Zip Codes: {houston_df['zip_code'].nunique()}")

# Export clean base dataset locally or to Drive
houston_df.to_csv('houston_real_estate_clean.csv', index=False)
