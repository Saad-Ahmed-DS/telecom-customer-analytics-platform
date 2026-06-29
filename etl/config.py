# ============================================================
# Telecom Customer Analytics & Churn Intelligence Platform
# ETL Configuration
# ============================================================

from sqlalchemy import create_engine
from dotenv import load_dotenv
import os

load_dotenv()

# ── Database Connection ──────────────────────────────────────
DB_HOST     = os.getenv('DB_HOST',     'localhost')
DB_PORT     = os.getenv('DB_PORT',     '5432')
DB_NAME     = os.getenv('DB_NAME',     'telecom_dw')
DB_USER     = os.getenv('DB_USER',     'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'your_password_here')

# ── Connection String ────────────────────────────────────────
DATABASE_URL = (
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# ── SQLAlchemy Engine ────────────────────────────────────────
def get_engine():
    engine = create_engine(DATABASE_URL)
    return engine

# ── Raw Data Paths ───────────────────────────────────────────
RAW_DATA_DIR = r'D:\telecom-customer-analytics-platform\data\raw'

TELCO_CSV       = RAW_DATA_DIR + r'\WA_Fn-UseC_-Telco-Customer-Churn.csv'
TELCO_EXCEL     = RAW_DATA_DIR + r'\Telco_customer_churn.xlsx'
PK_CITIES_CSV   = RAW_DATA_DIR + r'\pk.csv'
CELL_TOWERS_CSV = RAW_DATA_DIR + r'\410.csv'

# ── Schema Names ─────────────────────────────────────────────
BRONZE_SCHEMA = 'bronze'
SILVER_SCHEMA = 'silver'
GOLD_SCHEMA   = 'gold'