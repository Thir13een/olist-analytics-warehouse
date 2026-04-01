# 🛒 Olist Analytics Warehouse

![BigQuery](https://img.shields.io/badge/Warehouse-BigQuery-4285F4?style=for-the-badge&logo=googlebigquery&logoColor=white)
![dbt](https://img.shields.io/badge/Transform-dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Looker Studio](https://img.shields.io/badge/Dashboard-Looker%20Studio-4285F4?style=for-the-badge&logo=googleanalytics&logoColor=white)
![Python](https://img.shields.io/badge/Ingestion-Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-0F9D58?style=for-the-badge)

> A production-style end-to-end ecommerce analytics warehouse built on the Brazilian **Olist** public dataset — from raw CSV ingestion through BigQuery, dbt transformations, and a 5-page Looker Studio dashboard.

## 📊 Live Dashboard

**[View the Looker Studio Dashboard →](https://lookerstudio.google.com/reporting/6c0e6662-c340-4099-8f16-236ab5cee1fb)**

### Sales Overview
![Sales Overview](DASHBOARD/sales-overview.png)

### Geographic Performance
![Geographic Performance](DASHBOARD/geographic-performance.png)

---

## 📌 Project Overview

This project implements a full analytics engineering pipeline:

- **Ingest** raw Olist CSV data into BigQuery using a Python notebook
- **Transform** raw tables through a layered dbt warehouse (staging → intermediate → core → marts)
- **Test** data quality with 109 dbt tests including custom business-rule checks
- **Visualize** business insights across 5 Looker Studio dashboard pages

---

## 🏗️ Architecture

```
Raw CSV Files
      ↓
BigQuery Raw Tables (raw_*)
      ↓
Staging Layer (stg_*)        ← clean, cast, normalize
      ↓
Intermediate Layer (int_*)   ← reusable business logic
      ↓
Core Layer (fct_*, dim_*)    ← star schema facts & dimensions
      ↓
Business Marts (mart_*)      ← reporting-ready aggregates
      ↓
Looker Studio Dashboard      ← 5-page interactive dashboard
```

---

## 📊 Dashboard Pages

| Page | Source Mart | Key Content |
|---|---|---|
| 🏠 Sales Overview | `mart_sales_overview` | Revenue trend, order volume, review scores, delivery KPIs |
| 📦 Product Performance | `mart_product_performance` | Top categories, freight %, review scores, late delivery by category |
| 🗺️ Geographic Performance | `mart_geographic_performance` | Revenue map, late delivery by state, top cities |
| 👥 Customer Analytics | `mart_customer_overview` | LTV distribution, repeat rate, customers by state |
| 🏪 Seller Performance | `mart_seller_performance` + `mart_delivery_performance` | Top sellers, late delivery rate, delivery pipeline days |

---

## 🗂️ Project Layers

### 1. 📥 Raw Layer
Raw Olist tables loaded into BigQuery as `raw_*` tables via ingestion notebook:
- `INGEST/data-loading.ipynb`

### 2. 🧹 Staging Layer (`dev_staging`)
Standardizes raw source tables — cleans text, casts types, normalizes casing, converts blanks to NULL.

| Model | Description |
|---|---|
| `stg_customers` | Customer records |
| `stg_sellers` | Seller records |
| `stg_orders` | Order headers |
| `stg_order_items` | Order line items |
| `stg_products` | Product catalog |
| `stg_payments` | Payment records |
| `stg_reviews` | Customer reviews |
| `stg_geolocation` | Zip code coordinates |
| `stg_product_category_translation` | PT → EN category names |

### 3. ⚙️ Intermediate Layer (`dev_intermediate`)
Reusable business logic combining multiple staging models.

| Model | Description |
|---|---|
| `int_orders` | One row per order — aggregates items, payments, reviews |

### 4. ⭐ Core Layer (`dev_marts`)
Star-schema facts and dimensions for flexible analytics.

| Model | Grain | Purpose |
|---|---|---|
| `fct_orders` | 1 row per order | Main order fact table |
| `fct_order_items` | 1 row per order item | Item-level sales fact |
| `dim_customers` | 1 row per customer | Customer attributes + order history |
| `dim_products` | 1 row per product | Product attributes + translated category |
| `dim_sellers` | 1 row per seller | Seller geography |
| `dim_dates` | 1 row per date | Calendar dimension |
| `dim_geolocation` | 1 row per zip prefix | Lat/lng + city/state lookup |

### 5. 📈 Business Marts (`dev_marts`)
Reporting-ready aggregates for each dashboard page.

| Model | Grain | Purpose |
|---|---|---|
| `mart_sales_overview` | Daily | Revenue, orders, delivery, reviews |
| `mart_product_performance` | Per product | Sales, freight, reviews, late delivery |
| `mart_geographic_performance` | Per zip prefix | Revenue, customers, delivery by location |
| `mart_customer_overview` | Per customer | LTV, repeat status, order history |
| `mart_seller_performance` | Per seller | Revenue, delivery, review performance |
| `mart_delivery_performance` | Daily × status | Lead time breakdown by stage |

---

## ✅ Data Quality

**109 dbt tests** covering all layers:

| Test Type | Coverage |
|---|---|
| `not_null` | All primary and foreign keys |
| `unique` | All grain columns |
| `accepted_values` | Order status, payment types |
| `relationships` | FK integrity across all fact/dim joins |
| `dbt_utils.unique_combination_of_columns` | Composite keys |

**Custom singular tests:**
- `delivered_orders_have_delivered_at.sql`
- `delivered_orders_have_shipped_at.sql`
- `stg_payments_payment_value_non_negative.sql`
- `stg_order_items_price_non_negative.sql`
- `stg_order_items_freight_value_non_negative.sql`

> ⚠️ 2 intentional failing tests — delivered orders missing timestamps are known source-data anomalies kept visible on purpose.

---

## 🔑 Key Insights from the Data

- 📦 **99,441** unique customers across Brazil
- 🔁 Only **6.4%** repeat customer rate — massive retention opportunity
- 💰 Average customer lifetime value of **R$161**
- 🚚 Average delivery time of **12.6 days** — approval (0.4d) → shipping (3.4d) → delivery (12.6d)
- 🗺️ São Paulo dominates revenue — top state by a significant margin
- ⭐ Average review score of ~**4.1 / 5**

---

## 🚀 Useful Commands

### Build everything
```powershell
dbt build --project-dir DBT-WAREHOUSE --profiles-dir DBT-WAREHOUSE
```

### Build a single model
```powershell
dbt build --project-dir DBT-WAREHOUSE --profiles-dir DBT-WAREHOUSE --select mart_sales_overview
```

### Run tests only
```powershell
dbt test --project-dir DBT-WAREHOUSE --profiles-dir DBT-WAREHOUSE
```

---

## ⚙️ Environment Setup

1. Copy `.env.example` to `.env` and fill in your values:

```env
GOOGLE_APPLICATION_CREDENTIALS=C:\path\to\your\gcp-service-account.json
DBT_BIGQUERY_PROJECT=your-gcp-project-id
DBT_BIGQUERY_DATASET=dev
DBT_BIGQUERY_LOCATION=US
DBT_BIGQUERY_THREADS=4
```

2. Keep the GCP service account JSON **outside the repository**
3. `.env` is gitignored and should never be committed

---

## 📁 Repository Layout

```
olist-analytics-warehouse/
├── DBT-WAREHOUSE/
│   ├── models/
│   │   ├── staging/
│   │   ├── intermediate/
│   │   └── marts/
│   │       ├── core/
│   │       ├── sales/
│   │       ├── customers/
│   │       └── operations/
│   ├── macros/
│   ├── tests/
│   ├── dbt_project.yml
│   └── profiles.yml
├── INGEST/
│   └── data-loading.ipynb
├── EXPORTS/
│   ├── raw/
│   ├── dev_staging/
│   ├── dev_intermediate/
│   └── dev_marts/
├── .env.example
├── .gitignore
└── README.md
```

---

## 🔒 Security

- GCP service account JSON is stored **outside the repository**
- `.env` is gitignored
- `.gitignore` covers `.env`, `*.json`, and common credential patterns
- Only `.env.example` is committed as a safe template

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| Python + Jupyter | Raw data ingestion |
| Google BigQuery | Cloud data warehouse |
| dbt | Data transformation + testing |
| dbt-utils | Extended test coverage |
| Looker Studio | Dashboard + visualization |
