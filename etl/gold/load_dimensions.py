# ============================================================
# Telecom Customer Analytics & Churn Intelligence Platform
# Gold Layer: Dimension Table Loading
# Purpose: Load cleaned silver data into gold dimension tables
# Order: dim_date → dim_city → dim_customer → dim_plan → dim_tower
# ============================================================

import pandas as pd
import numpy as np
import sys
import os
from datetime import datetime, date

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import get_engine, SILVER_SCHEMA, GOLD_SCHEMA

# ── Logging ──────────────────────────────────────────────────
def log(msg):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}")

# ── Load dim_date ─────────────────────────────────────────────
def load_dim_date(engine):
    log("Loading dim_date...")

    # Generate date range 2020-01-01 to 2027-12-31
    dates = pd.date_range(start='2015-01-01', end='2027-12-31', freq='D')

    df = pd.DataFrame({
        'date_key'   : dates.strftime('%Y%m%d').astype(int),
        'full_date'  : dates.date,
        'day'        : dates.day,
        'day_name'   : dates.strftime('%A'),
        'week'       : dates.isocalendar().week.astype(int),
        'month'      : dates.month,
        'month_name' : dates.strftime('%B'),
        'quarter'    : dates.quarter,
        'year'       : dates.year,
        'is_weekend' : dates.dayofweek >= 5,
        'is_holiday' : False
    })

    # Mark Pakistan public holidays (fixed dates)
    pk_holidays = [
        '02-05',  # Kashmir Day
        '03-23',  # Pakistan Day
        '05-01',  # Labour Day
        '08-14',  # Independence Day
        '11-09',  # Iqbal Day
        '12-25',  # Quaid-e-Azam Day
    ]

    for holiday in pk_holidays:
        df.loc[df['full_date'].astype(str).str[5:] == holiday, 'is_holiday'] = True

    # Insert into gold — skip unknown record (-1)
    df.to_sql(
        name      = 'dim_date',
        con       = engine,
        schema    = GOLD_SCHEMA,
        if_exists = 'append',
        index     = False
    )

    log(f"dim_date loaded — {len(df)} rows")

# ── Load dim_city ─────────────────────────────────────────────
def load_dim_city(engine):
    log("Loading dim_city...")

    df = pd.read_sql(f'SELECT * FROM {SILVER_SCHEMA}.silver_pk_cities', engine)

    city_df = pd.DataFrame({
        'city'       : df['city'],
        'province'   : df['admin_name'],
        'latitude'   : df['lat'],
        'longitude'  : df['lng'],
        'population' : df['population']
    })

    # Remove duplicates
    city_df = city_df.drop_duplicates(subset=['city', 'province'])

    city_df.to_sql(
        name      = 'dim_city',
        con       = engine,
        schema    = GOLD_SCHEMA,
        if_exists = 'append',
        index     = False
    )

    log(f"dim_city loaded — {len(city_df)} rows")

# ── Load dim_customer ─────────────────────────────────────────
def load_dim_customer(engine):
    log("Loading dim_customer...")

    df = pd.read_sql(f'SELECT * FROM {SILVER_SCHEMA}.silver_telco_customer', engine)

    customer_df = pd.DataFrame({
        'customer_id'    : df['customerID'],
        'gender'         : df['gender'],
        'senior_citizen' : df['SeniorCitizen'],
        'partner'        : df['Partner'],
        'dependents'     : df['Dependents']
    })

    customer_df.to_sql(
        name      = 'dim_customer',
        con       = engine,
        schema    = GOLD_SCHEMA,
        if_exists = 'append',
        index     = False
    )

    log(f"dim_customer loaded — {len(customer_df)} rows")

# ── Load dim_plan ─────────────────────────────────────────────
def load_dim_plan(engine):
    log("Loading dim_plan...")

    df = pd.read_sql(f'SELECT * FROM {SILVER_SCHEMA}.silver_telco_customer', engine)

    plan_df = pd.DataFrame({
        'phone_service'     : df['PhoneService'],
        'multiple_lines'    : df['MultipleLines'],
        'internet_service'  : df['InternetService'],
        'online_security'   : df['OnlineSecurity'],
        'online_backup'     : df['OnlineBackup'],
        'device_protection' : df['DeviceProtection'],
        'tech_support'      : df['TechSupport'],
        'streaming_tv'      : df['StreamingTV'],
        'streaming_movies'  : df['StreamingMovies'],
        'contract'          : df['Contract'],
        'paperless_billing' : df['PaperlessBilling']
    })

    # Keep unique plan combinations only
    plan_df = plan_df.drop_duplicates()
    plan_df = plan_df.reset_index(drop=True)

    plan_df.to_sql(
        name      = 'dim_plan',
        con       = engine,
        schema    = GOLD_SCHEMA,
        if_exists = 'append',
        index     = False
    )

    log(f"dim_plan loaded — {len(plan_df)} rows")

# ── Load dim_tower ────────────────────────────────────────────
def load_dim_tower(engine):
    log("Loading dim_tower...")

    df = pd.read_sql(f'SELECT * FROM {SILVER_SCHEMA}.silver_cell_towers', engine)

    tower_df = pd.DataFrame({
        'mcc'            : df['mcc'],
        'network_code'   : df['net'],
        'area_code'      : df['area'],
        'cell_id'        : df['cell'],
        'radio'          : df['radio'],
        'latitude'       : df['lat'],
        'longitude'      : df['lon'],
        'coverage_range' : df['range'],
        'sample_count'   : df['samples']
    })

    tower_df.to_sql(
        name      = 'dim_tower',
        con       = engine,
        schema    = GOLD_SCHEMA,
        if_exists = 'append',
        index     = False
    )

    log(f"dim_tower loaded — {len(tower_df)} rows")

# ── Main ──────────────────────────────────────────────────────
def main():
    log("Gold Layer — Dimension Loading Started")
    log("=" * 50)

    engine = get_engine()

    load_dim_date(engine)
    load_dim_city(engine)
    load_dim_customer(engine)
    load_dim_plan(engine)
    load_dim_tower(engine)

    log("=" * 50)
    log("Gold Layer — Dimension Loading Complete")

if __name__ == '__main__':
    main()