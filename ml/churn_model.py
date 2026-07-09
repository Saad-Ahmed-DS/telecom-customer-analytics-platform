# ============================================================
# Telecom Customer Analytics & Churn Intelligence Platform
# Machine Learning: Churn Prediction Model
# Version: 2.0 — Leakage Fixed
# Changes:
#   - churn_score REMOVED from features (data leakage)
#     Reason: IBM pre-computed propensity score derived from
#     actual churn outcome. Correlation with churn_flag = 0.665
#     Including it inflated ROC AUC from ~0.82 to 0.98
#   - Model selection criterion: ROC AUC (documented below)
#     Business rationale: ROC AUC measures overall discrimination
#     ability across all thresholds. For churn use cases where
#     retention budget is limited, Recall is also tracked.
# ============================================================

import pandas as pd
import numpy as np
import sys
import os
import pickle
from datetime import datetime

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score,
    f1_score, roc_auc_score, confusion_matrix,
    classification_report
)
from xgboost import XGBClassifier

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'etl'))
from config import get_engine

# ── Logging ──────────────────────────────────────────────────
def log(msg):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}")

# ── Output Directory ─────────────────────────────────────────
MODEL_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'outputs')
os.makedirs(MODEL_DIR, exist_ok=True)

# ── Step 1: Load Features ─────────────────────────────────────
def load_features(engine):
    log("Loading features from gold.vw_ml_features...")
    df = pd.read_sql('SELECT * FROM gold.vw_ml_features', engine)
    log(f"Loaded {len(df)} rows and {df.shape[1]} columns")
    log(f"Columns: {list(df.columns)}")
    return df

# ── Step 2: Preprocess ────────────────────────────────────────
def preprocess(df):
    log("Preprocessing features...")

    # Verify churn_score is NOT in features
    if 'churn_score' in df.columns:
        log("WARNING: churn_score detected — removing to prevent data leakage")
        df = df.drop(columns=['churn_score'])

    # Drop identifier
    df = df.drop(columns=['customer_id'])

    # Categorical columns to encode
    cat_cols = [
        'gender', 'contract', 'internet_service', 'phone_service',
        'multiple_lines', 'online_security', 'online_backup',
        'device_protection', 'tech_support', 'streaming_tv',
        'streaming_movies', 'revenue_category', 'usage_segment',
        'customer_segment'
    ]

    le = LabelEncoder()
    for col in cat_cols:
        if col in df.columns:
            df[col] = le.fit_transform(df[col].astype(str))

    # Target
    X = df.drop(columns=['churn_flag'])
    y = df['churn_flag']

    # Handle NaN values
    num_cols = X.select_dtypes(include=np.number).columns
    X[num_cols] = X[num_cols].fillna(X[num_cols].median())
    for col in X.select_dtypes(include='object').columns:
        if not X[col].mode().empty:
            X[col] = X[col].fillna(X[col].mode()[0])

    log(f"Features: {X.shape[1]} columns")
    log(f"Target distribution: {y.value_counts().to_dict()}")
    log(f"Feature list: {list(X.columns)}")

    return X, y

# ── Step 3: Train/Test Split ──────────────────────────────────
def split_data(X, y):
    log("Splitting data 80/20...")
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    log(f"Train: {len(X_train)} rows | Test: {len(X_test)} rows")
    return X_train, X_test, y_train, y_test

# ── Step 4: Evaluate Model ────────────────────────────────────
def evaluate_model(name, model, X_test, y_test):
    y_pred  = model.predict(X_test)
    y_proba = model.predict_proba(X_test)[:, 1]

    results = {
        'Model'    : name,
        'Accuracy' : round(accuracy_score(y_test, y_pred), 4),
        'Precision': round(precision_score(y_test, y_pred), 4),
        'Recall'   : round(recall_score(y_test, y_pred), 4),
        'F1 Score' : round(f1_score(y_test, y_pred), 4),
        'ROC AUC'  : round(roc_auc_score(y_test, y_proba), 4)
    }

    log(f"\n  {name} Results:")
    for k, v in results.items():
        if k != 'Model':
            log(f"    {k:<12}: {v}")

    log(f"\n  Confusion Matrix:\n{confusion_matrix(y_test, y_pred)}")
    log(f"\n  Classification Report:\n{classification_report(y_test, y_pred)}")

    return results

# ── Step 5: Train Random Forest ───────────────────────────────
def train_random_forest(X_train, X_test, y_train, y_test):
    log("\nTraining Random Forest...")

    rf = RandomForestClassifier(
        n_estimators = 200,
        max_depth    = 10,
        random_state = 42,
        n_jobs       = -1
    )
    rf.fit(X_train, y_train)

    results = evaluate_model('Random Forest', rf, X_test, y_test)

    importance_df = pd.DataFrame({
        'Feature'   : X_train.columns,
        'Importance': rf.feature_importances_
    }).sort_values('Importance', ascending=False)

    log("\n  Top 10 Important Features:")
    print(importance_df.head(10).to_string(index=False))

    return rf, results, importance_df

# ── Step 6: Train XGBoost ─────────────────────────────────────
def train_xgboost(X_train, X_test, y_train, y_test):
    log("\nTraining XGBoost...")

    xgb = XGBClassifier(
        n_estimators  = 200,
        max_depth      = 6,
        learning_rate  = 0.05,
        subsample      = 0.8,
        random_state   = 42,
        eval_metric    = 'logloss',
        verbosity      = 0
    )
    xgb.fit(X_train, y_train)

    results = evaluate_model('XGBoost', xgb, X_test, y_test)

    return xgb, results

# ── Step 7: Save Best Model ───────────────────────────────────
def save_best_model(rf_results, xgb_results, rf_model, xgb_model, importance_df):
    log("\nComparing models...")

    # Model selection criterion: ROC AUC
    # Rationale: measures overall discrimination across all thresholds
    # Alternative: use Recall if maximizing churn catch rate is priority
    if xgb_results['ROC AUC'] >= rf_results['ROC AUC']:
        best_model   = xgb_model
        best_name    = 'XGBoost'
        best_results = xgb_results
    else:
        best_model   = rf_model
        best_name    = 'Random Forest'
        best_results = rf_results

    log(f"Best Model: {best_name} (ROC AUC: {best_results['ROC AUC']})")

    # Save model
    model_path = os.path.join(MODEL_DIR, 'churn_model.pkl')
    with open(model_path, 'wb') as f:
        pickle.dump(best_model, f)
    log(f"Model saved to {model_path}")

    # Save results comparison
    results_df = pd.DataFrame([rf_results, xgb_results])
    results_path = os.path.join(MODEL_DIR, 'model_results.csv')
    results_df.to_csv(results_path, index=False)
    log(f"Results saved to {results_path}")

    # Save feature importance
    importance_path = os.path.join(MODEL_DIR, 'feature_importance.csv')
    importance_df.to_csv(importance_path, index=False)
    log(f"Feature importance saved to {importance_path}")

    return best_name, best_results

# ── Main ──────────────────────────────────────────────────────
def main():
    log("Machine Learning — Churn Prediction v2.0 (Leakage Fixed)")
    log("=" * 60)
    log("NOTE: churn_score excluded — data leakage prevention")
    log("NOTE: Geographic/network metrics are synthetic — illustrative only")
    log("=" * 60)

    engine = get_engine()

    df                               = load_features(engine)
    X, y                             = preprocess(df)
    X_train, X_test, y_train, y_test = split_data(X, y)

    rf_model,  rf_results,  importance_df = train_random_forest(X_train, X_test, y_train, y_test)
    xgb_model, xgb_results               = train_xgboost(X_train, X_test, y_train, y_test)

    best_name, best_results = save_best_model(
        rf_results, xgb_results,
        rf_model, xgb_model,
        importance_df
    )

    log("=" * 60)
    log(f"ML Phase Complete — Best Model : {best_name}")
    log(f"ROC AUC   : {best_results['ROC AUC']}")
    log(f"F1 Score  : {best_results['F1 Score']}")
    log(f"Accuracy  : {best_results['Accuracy']}")
    log(f"Recall    : {best_results['Recall']}")
    log(f"Precision : {best_results['Precision']}")

if __name__ == '__main__':
    main()