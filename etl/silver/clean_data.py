# ============================================================
# Telecom Customer Analytics & Churn Intelligence Platform
# Silver Layer: Data Cleaning and Validation
# Purpose: Clean, validate and standardize bronze data
#          Apply transformation rules from documentation
# ============================================================

import pandas as pd
import numpy as np
import sys
import os
from datetime import datetime

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import get_engine, BRONZE_SCHEMA, SILVER_SCHEMA

# ── Logging ──────────────────────────────────────────────────
def log(msg):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}")

# ── Save to Silver ───────────────────────────────────────────
def save_to_silver(df, table_name, engine):
    log(f"Saving {table_name} to silver — {len(df)} rows...")
    df.to_sql(
        name      = table_name,
        con       = engine,
        schema    = SILVER_SCHEMA,
        if_exists = 'replace',
        index     = False
    )
    log(f"Done — {table_name} saved to silver.")

# ── Rejected Records Log ─────────────────────────────────────
rejected_records = []

def reject(dataset, row_index, error):
    rejected_records.append({
        'dataset'   : dataset,
        'row_index' : row_index,
        'error'     : error,
        'timestamp' : datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    })

# ── Clean Dataset 1: Telco Customer CSV ──────────────────────
def clean_telco_customer(engine):
    log("Cleaning raw_telco_customer...")

    df = pd.read_sql(f'SELECT * FROM {BRONZE_SCHEMA}.raw_telco_customer', engine)
    initial_count = len(df)

    # Trim all string columns
    str_cols = df.select_dtypes(include='object').columns
    df[str_cols] = df[str_cols].apply(lambda x: x.str.strip())

    # customerID — uppercase, validate uniqueness
    df['customerID'] = df['customerID'].str.upper()
    dupes = df[df['customerID'].duplicated()]
    for idx in dupes.index:
        reject('raw_telco_customer', idx, 'Duplicate customerID')
    df = df.drop_duplicates(subset='customerID')

    # SeniorCitizen — 0/1 to boolean
    df['SeniorCitizen'] = df['SeniorCitizen'].map({0: False, 1: True})

    # Partner — Yes/No to boolean
    df['Partner'] = df['Partner'].map({'Yes': True, 'No': False})

    # Dependents — Yes/No to boolean
    df['Dependents'] = df['Dependents'].map({'Yes': True, 'No': False})

    # TotalCharges — blank to NaN, convert to numeric
    df['TotalCharges'] = df['TotalCharges'].replace('', np.nan)
    df['TotalCharges'] = pd.to_numeric(df['TotalCharges'], errors='coerce')

    # MonthlyCharges — validate >= 0
    invalid_charges = df[df['MonthlyCharges'] < 0]
    for idx in invalid_charges.index:
        reject('raw_telco_customer', idx, 'MonthlyCharges < 0')
    df = df[df['MonthlyCharges'] >= 0]

    # tenure — validate >= 0
    invalid_tenure = df[df['tenure'] < 0]
    for idx in invalid_tenure.index:
        reject('raw_telco_customer', idx, 'tenure < 0')
    df = df[df['tenure'] >= 0]

    # PaperlessBilling — Yes/No to boolean
    df['PaperlessBilling'] = df['PaperlessBilling'].map({'Yes': True, 'No': False})

    log(f"raw_telco_customer: {initial_count} → {len(df)} rows after cleaning")
    save_to_silver(df, 'silver_telco_customer', engine)

# ── Clean Dataset 2: Telco Extended Excel ────────────────────
def clean_telco_extended(engine):
    log("Cleaning raw_telco_extended...")

    df = pd.read_sql(f'SELECT * FROM {BRONZE_SCHEMA}.raw_telco_extended', engine)
    initial_count = len(df)

    # Trim string columns
    str_cols = df.select_dtypes(include='object').columns
    df[str_cols] = df[str_cols].apply(lambda x: x.str.strip())

    # CustomerID — uppercase
    df['CustomerID'] = df['CustomerID'].str.upper()

    # Churn Value — 0/1 to boolean
    df['Churn Value'] = df['Churn Value'].map({0: False, 1: True})

    # Churn Score — validate 0-100
    invalid_score = df[(df['Churn Score'] < 0) | (df['Churn Score'] > 100)]
    for idx in invalid_score.index:
        reject('raw_telco_extended', idx, 'Churn Score out of range 0-100')
    df.loc[(df['Churn Score'] < 0) | (df['Churn Score'] > 100), 'Churn Score'] = np.nan

    # CLTV — validate positive
    invalid_cltv = df[df['CLTV'] < 0]
    for idx in invalid_cltv.index:
        reject('raw_telco_extended', idx, 'CLTV negative')
    df = df[df['CLTV'] >= 0]

    # Total Charges — coerce to numeric
    df['Total Charges'] = pd.to_numeric(df['Total Charges'], errors='coerce')

    # Latitude validation
    invalid_lat = df[(df['Latitude'] < -90) | (df['Latitude'] > 90)]
    for idx in invalid_lat.index:
        reject('raw_telco_extended', idx, 'Latitude out of range')
    df.loc[(df['Latitude'] < -90) | (df['Latitude'] > 90), 'Latitude'] = np.nan

    # Longitude validation
    invalid_lon = df[(df['Longitude'] < -180) | (df['Longitude'] > 180)]
    for idx in invalid_lon.index:
        reject('raw_telco_extended', idx, 'Longitude out of range')
    df.loc[(df['Longitude'] < -180) | (df['Longitude'] > 180), 'Longitude'] = np.nan

    log(f"raw_telco_extended: {initial_count} → {len(df)} rows after cleaning")
    save_to_silver(df, 'silver_telco_extended', engine)

# ── Clean Dataset 3: Pakistan Cities ─────────────────────────
def clean_pk_cities(engine):
    log("Cleaning raw_pk_cities...")

    df = pd.read_sql(f'SELECT * FROM {BRONZE_SCHEMA}.raw_pk_cities', engine)
    initial_count = len(df)

    # Trim all strings
    str_cols = df.select_dtypes(include='object').columns
    df[str_cols] = df[str_cols].apply(lambda x: x.str.strip())

    # City — proper case, remove double spaces
    df['city'] = df['city'].str.title().str.replace(r'\s+', ' ', regex=True)

    # Admin name as province — proper case
    df['admin_name'] = df['admin_name'].str.title()

    # Population — validate > 0
    invalid_pop = df[df['population'] <= 0]
    for idx in invalid_pop.index:
        reject('raw_pk_cities', idx, 'Population <= 0')
    df = df[df['population'] > 0]

    # Latitude validation
    invalid_lat = df[(df['lat'] < -90) | (df['lat'] > 90)]
    for idx in invalid_lat.index:
        reject('raw_pk_cities', idx, 'Latitude out of range')

    # Longitude validation
    invalid_lon = df[(df['lng'] < -180) | (df['lng'] > 180)]
    for idx in invalid_lon.index:
        reject('raw_pk_cities', idx, 'Longitude out of range')

    log(f"raw_pk_cities: {initial_count} → {len(df)} rows after cleaning")
    save_to_silver(df, 'silver_pk_cities', engine)

# ── Clean Dataset 4: Cell Towers ─────────────────────────────
def clean_cell_towers(engine):
    log("Cleaning raw_cell_towers...")

    df = pd.read_sql(f'SELECT * FROM {BRONZE_SCHEMA}.raw_cell_towers', engine)
    initial_count = len(df)

    # Radio — validate allowed values
    allowed_radio = ['LTE', 'GSM', 'UMTS', 'NR', 'CDMA']
    df['radio'] = df['radio'].str.upper().str.strip()
    df.loc[~df['radio'].isin(allowed_radio), 'radio'] = 'Unknown'

    # Latitude validation
    invalid_lat = df[(df['lat'] < -90) | (df['lat'] > 90)]
    for idx in invalid_lat.index:
        reject('raw_cell_towers', idx, 'Latitude out of range')
    df = df[(df['lat'] >= -90) & (df['lat'] <= 90)]

    # Longitude validation
    invalid_lon = df[(df['lon'] < -180) | (df['lon'] > 180)]
    for idx in invalid_lon.index:
        reject('raw_cell_towers', idx, 'Longitude out of range')
    df = df[(df['lon'] >= -180) & (df['lon'] <= 180)]

    # Remove duplicate composite keys
    dupes = df[df.duplicated(subset=['mcc', 'net', 'area', 'cell'])]
    for idx in dupes.index:
        reject('raw_cell_towers', idx, 'Duplicate composite key mcc+net+area+cell')
    df = df.drop_duplicates(subset=['mcc', 'net', 'area', 'cell'])

    log(f"raw_cell_towers: {initial_count} → {len(df)} rows after cleaning")
    save_to_silver(df, 'silver_cell_towers', engine)

# ── Save Rejected Records ─────────────────────────────────────
def save_rejected_records():
    if rejected_records:
        logs_dir = r'D:\telecom-customer-analytics-platform\logs'
        os.makedirs(logs_dir, exist_ok=True)
        rejected_df = pd.DataFrame(rejected_records)
        path = os.path.join(logs_dir, 'rejected_records.csv')
        rejected_df.to_csv(path, index=False)
        log(f"Rejected records saved to {path} — {len(rejected_records)} records")
    else:
        log("No rejected records.")

# ── Main ──────────────────────────────────────────────────────
def main():
    log("Silver Layer Cleaning Started")
    log("=" * 50)

    engine = get_engine()

    clean_telco_customer(engine)
    clean_telco_extended(engine)
    clean_pk_cities(engine)
    clean_cell_towers(engine)
    save_rejected_records()

    log("=" * 50)
    log("Silver Layer Cleaning Complete")

if __name__ == '__main__':
    main()