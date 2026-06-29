# ============================================================
# Telecom Customer Analytics & Churn Intelligence Platform
# Gold Layer: Fact Table Loading
# Purpose: Load fact_customer_snapshot, fact_payment, fact_support
# ============================================================

import pandas as pd
import numpy as np
import sys
import os
from datetime import datetime

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import get_engine, SILVER_SCHEMA, GOLD_SCHEMA

# ── Logging ──────────────────────────────────────────────────
def log(msg):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}")

# ── Lookup Helpers ────────────────────────────────────────────
def get_customer_lookup(engine):
    df = pd.read_sql(f'SELECT customer_key, customer_id FROM {GOLD_SCHEMA}.dim_customer', engine)
    return dict(zip(df['customer_id'], df['customer_key']))

def get_city_lookup(engine):
    df = pd.read_sql(f'SELECT city_key, city FROM {GOLD_SCHEMA}.dim_city', engine)
    return dict(zip(df['city'], df['city_key']))

def get_plan_lookup(engine):
    df = pd.read_sql(f'SELECT * FROM {GOLD_SCHEMA}.dim_plan', engine)
    return df

def get_tower_lookup(engine):
    df = pd.read_sql(f'SELECT tower_key, mcc, network_code, area_code, cell_id FROM {GOLD_SCHEMA}.dim_tower', engine)
    df['composite'] = (df['mcc'].astype(str) + '_' +
                       df['network_code'].astype(str) + '_' +
                       df['area_code'].astype(str) + '_' +
                       df['cell_id'].astype(str))
    return dict(zip(df['composite'], df['tower_key']))

# ── Generate Usage Metrics ────────────────────────────────────
def generate_usage_metrics(df, seed=42):
    np.random.seed(seed)
    n = len(df)

    # Usage correlates with internet service type
    has_internet = df['InternetService'] != 'No'

    data_usage = np.where(
        has_internet,
        np.random.uniform(0.5, 50.0, n),
        np.random.uniform(0.0, 0.5, n)
    ).round(2)

    voice_minutes = np.random.randint(10, 1000, n)
    sms_count     = np.random.randint(0, 500, n)

    has_phone = df['PhoneService'] == 'Yes'
    roaming   = np.where(has_phone, np.random.randint(0, 120, n), 0)
    intl      = np.where(has_phone, np.random.randint(0, 60, n), 0)

    return data_usage, voice_minutes, sms_count, roaming, intl

# ── Generate Network Metrics ──────────────────────────────────
def generate_network_metrics(n, seed=42):
    np.random.seed(seed + 1)

    signal_strength     = np.random.uniform(-110, -50, n).round(2)
    latency_ms          = np.random.uniform(5, 150, n).round(2)
    packet_loss_percent = np.random.uniform(0, 5, n).round(2)
    downtime_minutes    = np.random.randint(0, 120, n)

    # Network score 0-100 based on signal and latency
    network_score = (
        ((signal_strength - (-110)) / 60 * 50) +
        ((150 - latency_ms) / 145 * 30) +
        ((5 - packet_loss_percent) / 5 * 20)
    ).clip(0, 100).round(2)

    return signal_strength, latency_ms, packet_loss_percent, downtime_minutes, network_score

# ── Derive Segments ───────────────────────────────────────────
def derive_segments(monthly_charge, data_usage, tenure):
    # Revenue Category
    revenue_category = np.where(
        monthly_charge >= 70, 'High',
        np.where(monthly_charge >= 40, 'Medium', 'Low')
    )

    # Usage Segment
    usage_segment = np.where(
        data_usage >= 20, 'Heavy',
        np.where(data_usage >= 5, 'Moderate', 'Light')
    )

    # Customer Segment
    customer_segment = np.where(
        tenure >= 48, 'VIP',
        np.where(tenure >= 24, 'Loyal',
        np.where(tenure >= 6, 'Growing', 'New'))
    )

    return revenue_category, usage_segment, customer_segment

# ── Load fact_customer_snapshot ───────────────────────────────
def load_fact_customer_snapshot(engine):
    log("Loading fact_customer_snapshot...")

    # Load silver data
    telco    = pd.read_sql(f'SELECT * FROM {SILVER_SCHEMA}.silver_telco_customer', engine)
    extended = pd.read_sql(f'SELECT * FROM {SILVER_SCHEMA}.silver_telco_extended', engine)

    # Merge on customerID
    df = telco.merge(
        extended[['CustomerID', 'Churn Value', 'Churn Score', 'CLTV', 'Churn Reason', 'City']],
        left_on  = 'customerID',
        right_on = 'CustomerID',
        how      = 'left'
    )

    # Lookups
    customer_lookup = get_customer_lookup(engine)
    city_lookup     = get_city_lookup(engine)
    plan_df         = get_plan_lookup(engine)
    tower_lookup    = get_tower_lookup(engine)

    # customer_key
    df['customer_key'] = df['customerID'].map(customer_lookup).fillna(-1).astype(int)

    # date_key
    base_date = pd.Timestamp('2025-01-01')
    df['snapshot_date'] = df['tenure'].apply(
        lambda t: base_date - pd.DateOffset(months=max(0, int(t)-1))
    )
    df['date_key'] = df['snapshot_date'].dt.strftime('%Y%m%d').astype(int)

    # city_key — assign random Pakistani cities from dim_city
    city_key_list = list(city_lookup.values())
    np.random.seed(42)
    df['city_key'] = np.random.choice(city_key_list, size=len(df))

    # plan_key
    plan_cols = ['phone_service', 'multiple_lines', 'internet_service',
                 'online_security', 'online_backup', 'device_protection',
                 'tech_support', 'streaming_tv', 'streaming_movies',
                 'contract', 'paperless_billing']

    source_cols = ['PhoneService', 'MultipleLines', 'InternetService',
                   'OnlineSecurity', 'OnlineBackup', 'DeviceProtection',
                   'TechSupport', 'StreamingTV', 'StreamingMovies',
                   'Contract', 'PaperlessBilling']

    plan_lookup_df = plan_df[['plan_key'] + plan_cols].copy()
    df_plan = df[source_cols].copy()
    df_plan.columns = plan_cols
    df_plan['plan_key'] = -1

    for _, plan_row in plan_lookup_df.iterrows():
        mask = pd.Series([True] * len(df_plan))
        for col in plan_cols:
            mask &= (df_plan[col] == plan_row[col])
        df_plan.loc[mask, 'plan_key'] = plan_row['plan_key']

    df['plan_key'] = df_plan['plan_key'].values

    # tower_key
    tower_keys = list(tower_lookup.values())
    np.random.seed(42)
    df['tower_key'] = np.random.choice(tower_keys, size=len(df))

    # Generate metrics
    data_usage, voice_minutes, sms_count, roaming, intl = generate_usage_metrics(df)
    signal, latency, packet_loss, downtime, net_score   = generate_network_metrics(len(df))
    rev_cat, usage_seg, cust_seg = derive_segments(
        df['MonthlyCharges'].values,
        data_usage,
        df['tenure'].values
    )

    # Build fact dataframe
    fact_df = pd.DataFrame({
        'customer_key'          : df['customer_key'],
        'date_key'              : df['date_key'],
        'city_key'              : df['city_key'],
        'plan_key'              : df['plan_key'],
        'tower_key'             : df['tower_key'],
        'tenure_months'         : df['tenure'],
        'churn_flag'            : df['Churn Value'],
        'churn_score'           : df['Churn Score'],
        'cltv'                  : df['CLTV'],
        'churn_reason'          : df['Churn Reason'],
        'monthly_charge'        : df['MonthlyCharges'],
        'total_charge'          : df['TotalCharges'],
        'data_usage_gb'         : data_usage,
        'voice_minutes'         : voice_minutes,
        'sms_count'             : sms_count,
        'roaming_minutes'       : roaming,
        'international_minutes' : intl,
        'signal_strength'       : signal,
        'latency_ms'            : latency,
        'packet_loss_percent'   : packet_loss,
        'downtime_minutes'      : downtime,
        'network_score'         : net_score,
        'revenue_category'      : rev_cat,
        'usage_segment'         : usage_seg,
        'customer_segment'      : cust_seg
    })

    fact_df.to_sql(
        name      = 'fact_customer_snapshot',
        con       = engine,
        schema    = GOLD_SCHEMA,
        if_exists = 'append',
        index     = False
    )

    log(f"fact_customer_snapshot loaded — {len(fact_df)} rows")

# ── Load fact_payment ─────────────────────────────────────────
def load_fact_payment(engine):
    log("Loading fact_payment...")

    telco = pd.read_sql(f'SELECT * FROM {SILVER_SCHEMA}.silver_telco_customer', engine)
    customer_lookup = get_customer_lookup(engine)

    np.random.seed(10)
    n = len(telco)

    payment_methods  = ['Credit Card', 'Bank Transfer', 'Electronic Check', 'Mailed Check']
    payment_statuses = ['Paid', 'Pending', 'Failed']

    fact_df = pd.DataFrame({
        'customer_key'      : telco['customerID'].map(customer_lookup).fillna(-1).astype(int),
        'date_key'          : np.random.choice(
                                pd.date_range('2024-01-01', '2025-01-01', freq='MS')
                                .strftime('%Y%m%d').astype(int),
                                size=n
                              ),
        'payment_amount'    : telco['MonthlyCharges'].round(2),
        'payment_method'    : np.random.choice(payment_methods, size=n),
        'payment_status'    : np.random.choice(payment_statuses, size=n, p=[0.85, 0.10, 0.05]),
        'late_payment_days' : np.where(
                                np.random.random(n) < 0.15,
                                np.random.randint(1, 30, n),
                                0
                              )
    })

    fact_df.to_sql(
        name      = 'fact_payment',
        con       = engine,
        schema    = GOLD_SCHEMA,
        if_exists = 'append',
        index     = False
    )

    log(f"fact_payment loaded — {len(fact_df)} rows")

# ── Load fact_support ─────────────────────────────────────────
def load_fact_support(engine):
    log("Loading fact_support...")

    telco = pd.read_sql(f'SELECT * FROM {SILVER_SCHEMA}.silver_telco_customer', engine)
    customer_lookup = get_customer_lookup(engine)
    city_lookup     = get_city_lookup(engine)

    extended = pd.read_sql(
        f"SELECT \"CustomerID\", \"City\" FROM {SILVER_SCHEMA}.silver_telco_extended",
        engine
    )
    extended['CustomerID'] = extended['CustomerID'].str.upper()

    merged = telco.merge(extended, left_on='customerID', right_on='CustomerID', how='left')

    np.random.seed(20)

    # Only generate tickets for ~40% of customers
    n = len(merged)
    has_ticket = np.random.random(n) < 0.40
    ticket_df  = merged[has_ticket].copy().reset_index(drop=True)
    nt = len(ticket_df)

    issue_types = ['Billing', 'Network', 'Technical', 'Account', 'Service']
    priorities  = ['Low', 'Medium', 'High', 'Critical']
    statuses    = ['Open', 'Closed']

    city_key_list = [v for k, v in city_lookup.items()]
    city_keys = pd.Series(np.random.choice(city_key_list, size=nt))

    fact_df = pd.DataFrame({
        'customer_key'          : ticket_df['customerID'].map(customer_lookup).fillna(-1).astype(int),
        'date_key'              : np.random.choice(
                                    pd.date_range('2024-01-01', '2025-01-01', freq='MS')
                                    .strftime('%Y%m%d').astype(int),
                                    size=nt
                                  ),
        'city_key'              : city_keys.values,
        'issue_type'            : np.random.choice(issue_types, size=nt),
        'priority'              : np.random.choice(priorities, size=nt, p=[0.3, 0.4, 0.2, 0.1]),
        'resolution_time_hours' : np.random.uniform(0.5, 72, nt).round(2),
        'ticket_status'         : np.random.choice(statuses, size=nt, p=[0.3, 0.7])
    })

    fact_df.to_sql(
        name      = 'fact_support',
        con       = engine,
        schema    = GOLD_SCHEMA,
        if_exists = 'append',
        index     = False
    )

    log(f"fact_support loaded — {nt} rows")

# ── Main ──────────────────────────────────────────────────────
def main():
    log("Gold Layer — Fact Loading Started")
    log("=" * 50)

    engine = get_engine()

    load_fact_customer_snapshot(engine)
    load_fact_payment(engine)
    load_fact_support(engine)

    log("=" * 50)
    log("Gold Layer — Fact Loading Complete")

# ── Main ──────────────────────────────────────────────────────
if __name__ == '__main__':
    print("Script started...")
    main()
    print("Script finished...")