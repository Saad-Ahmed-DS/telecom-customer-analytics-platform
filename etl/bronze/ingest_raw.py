# ============================================================
# Telecom Customer Analytics & Churn Intelligence Platform
# Bronze Layer: Raw Data Ingestion
# Purpose: Load all source files as-is into bronze schema
#          No transformations — raw data preserved exactly
# ============================================================

import pandas as pd
import sys
import os
from datetime import datetime

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import get_engine, TELCO_CSV, TELCO_EXCEL, PK_CITIES_CSV, CELL_TOWERS_CSV, BRONZE_SCHEMA

# ── Logging ──────────────────────────────────────────────────
def log(msg):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}")

# ── Ingest Function ──────────────────────────────────────────
def ingest_table(df, table_name, engine):
    log(f"Loading {table_name} — {len(df)} rows...")
    df.to_sql(
        name      = table_name,
        con       = engine,
        schema    = BRONZE_SCHEMA,
        if_exists = 'replace',
        index     = False
    )
    log(f"Done — {table_name} loaded successfully.")

# ── Dataset 1: IBM Telco Customer Churn CSV ──────────────────
def ingest_telco_csv(engine):
    log("Reading WA_Fn-UseC_-Telco-Customer-Churn.csv...")
    df = pd.read_csv(TELCO_CSV)
    log(f"Shape: {df.shape}")
    ingest_table(df, 'raw_telco_customer', engine)

# ── Dataset 2: IBM Telco Extended Excel ──────────────────────
def ingest_telco_excel(engine):
    log("Reading Telco_customer_churn.xlsx...")
    df = pd.read_excel(TELCO_EXCEL, sheet_name='Telco_Churn')
    log(f"Shape: {df.shape}")
    ingest_table(df, 'raw_telco_extended', engine)

# ── Dataset 3: Pakistan Cities ────────────────────────────────
def ingest_pk_cities(engine):
    log("Reading pk.csv...")
    df = pd.read_csv(PK_CITIES_CSV)
    log(f"Shape: {df.shape}")
    ingest_table(df, 'raw_pk_cities', engine)

# ── Dataset 4: Cell Towers ────────────────────────────────────
def ingest_cell_towers(engine):
    log("Reading 410.csv...")
    CELL_TOWER_COLS = [
        'radio', 'mcc', 'net', 'area', 'cell', 'unit',
        'lon', 'lat', 'range', 'samples', 'changeable',
        'created', 'updated', 'averageSignal'
    ]
    df = pd.read_csv(CELL_TOWERS_CSV, header=None, names=CELL_TOWER_COLS)
    log(f"Shape: {df.shape}")
    ingest_table(df, 'raw_cell_towers', engine)

# ── Main ──────────────────────────────────────────────────────
def main():
    log("Bronze Layer Ingestion Started")
    log("=" * 50)

    engine = get_engine()

    ingest_telco_csv(engine)
    ingest_telco_excel(engine)
    ingest_pk_cities(engine)
    ingest_cell_towers(engine)

    log("=" * 50)
    log("Bronze Layer Ingestion Complete")

if __name__ == '__main__':
    main()