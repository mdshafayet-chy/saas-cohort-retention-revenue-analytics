# SaaS Cohort & Revenue Retention Analytics

> **End-to-end portfolio project** · MySQL · Power BI · Cohort Analysis · NRR · GRR · Logo Retention

***

## Project Overview

A complete SaaS analytics pipeline built from raw subscription data to executive-ready Power BI dashboards. The project tracks **1,500 accounts** across **24 monthly cohorts** (January 2023 – December 2024), computing industry-standard retention metrics — Logo Retention, Net Revenue Retention (NRR), and Gross Revenue Retention (GRR) — at the cohort, segment, and account level.

The goal was to answer a core business question: **Which customers stay, which churn, and where does revenue leak?**

***

## Key Findings

| Metric | Value | Benchmark | Status |
|---|---|---|---|
| Avg Logo Retention M12 | 59.7% | ~70% | ⚠️ Below benchmark |
| Avg NRR M12 | 92.6% | ≥100% | ⚠️ Below target |
| Avg GRR M12 | 95.9% | ≥95% | ✅ At benchmark |
| Quick Ratio | 1.10 | >1.0 | ✅ Marginally healthy |
| Avg Monthly Churn Rate | 9.6% | — | High early-stage churn |
| Expansion MRR Share | 23.1% | — | Upsell opportunity |
| Best Cohort | 2023-04-01 | — | 70.3% logo retention M12 |
| Worst Cohort | 2024-01-01 | — | 50.0% logo retention M12 |

**Top insights:**
- Accounts lose ~19.5pp of logos within the first 3 months — steep early-stage churn is the #1 risk
- Enterprise plan drives 74% of starting MRR; one lost Enterprise account equals 10+ Basic accounts
- NRR is nearly identical across all acquisition channels (~95–101%), meaning channel quality is similar — focus should shift to volume and cost efficiency
- Expansion MRR is weak (23.1%); a structured upsell program for Pro and Basic customers could significantly improve NRR
- Organic / Enterprise is the best segment (103.4% NRR M12); Basic / Partner is the worst (47.6% NRR M12)

***

## Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| Raw Data | CSV files | `accounts.csv`, `account_month_mrr.csv` |
| Data Modeling | MySQL Workbench | SQL views for cohort construction |
| Visualization | Microsoft Power BI | 3 interactive dashboards |
| Metrics | NRR, GRR, Logo Retention, Quick Ratio | Industry-standard SaaS KPIs |

***

## Repository Structure

```
saas-cohort-retention-analytics/
│
├── README.md                          ← This file
│
├── data/
│   ├── raw/
│   │   ├── accounts.csv               ← Account master: account_id, plan, channel, signup_date
│   │   └── account_month_mrr.csv      ← Monthly MRR per account (Jan 2023 – Dec 2024)
│   │
│   └── views/                         ← Exported MySQL view outputs (used as Power BI sources)
│       ├── account_cohort_view.csv
│       ├── account_month_with_age_view.csv
│       ├── cohort_logo_retention_view.csv
│       ├── cohort_logo_retention_segmented_view.csv
│       ├── cohort_mrr_retention_view.csv
│       └── cohort_mrr_retention_segmented_view.csv
│
├── sql/
│   ├── 01_account_cohort_view.sql
│   ├── 02_account_month_with_age_view.sql
│   ├── 03_cohort_logo_retention_view.sql
│   ├── 04_cohort_logo_retention_segmented_view.sql
│   ├── 05_cohort_mrr_retention_view.sql
│   └── 06_cohort_mrr_retention_segmented_view.sql
│
├── powerbi/
│   └── saas_cohort_analytics.pbix     ← Power BI report file
│
└── dashboards/
    ├── 01_cohort_benchmarks.png        ← Dashboard 1 screenshot
    ├── 02_segment_analysis.png         ← Dashboard 2 screenshot
    └── 03_saas_overview.png            ← Dashboard 3 screenshot
```

***

## Data Model

### Source Tables

**`accounts.csv`** — Account master table
| Column | Type | Description |
|---|---|---|
| `account_id` | VARCHAR | Unique account identifier (e.g., ACC-00001) |
| `signup_date` | DATE | First subscription date |
| `initial_plan` | VARCHAR | Plan at signup: Basic / Pro / Enterprise |
| `acquisition_channel` | VARCHAR | Organic / Outbound / Paid Search / Partner |

**`account_month_mrr.csv`** — Monthly recurring revenue per account
| Column | Type | Description |
|---|---|---|
| `account_id` | VARCHAR | Foreign key to accounts |
| `month` | DATE | Billing month (first of month) |
| `mrr` | DECIMAL | Monthly recurring revenue in EUR |

### SQL Views (MySQL Workbench)

Six views were built progressively, each feeding the next layer of analysis:

```
accounts + account_month_mrr
        │
        ▼
[1] account_cohort_view          → Assigns each account to its cohort month
        │
        ▼
[2] account_month_with_age_view  → Adds months_since_cohort to every MRR row
        │
        ├──▶ [3] cohort_logo_retention_view           → Logo retention % by cohort & month
        ├──▶ [4] cohort_logo_retention_segmented_view → Logo retention split by plan × channel
        ├──▶ [5] cohort_mrr_retention_view            → NRR & GRR by cohort & month
        └──▶ [6] cohort_mrr_retention_segmented_view  → NRR & GRR split by plan × channel
```

#### View Schemas

**`account_cohort_view`**
```sql
account_id | cohort_month | signup_date
```
Assigns each account's cohort month as the first day of their signup month.

**`account_month_with_age_view`**
```sql
account_id | cohort_month | month | months_since_cohort
```
Joins MRR history to cohort assignments and calculates age in months since cohort start.

**`cohort_logo_retention_view`**
```sql
cohort_month | months_since_cohort | accounts_in_cohort | active_accounts | logo_retention_rate_pct
```
Aggregates active account counts per cohort per month to calculate logo (account) retention.

**`cohort_logo_retention_segmented_view`**
```sql
cohort_month | months_since_cohort | initial_plan | acquisition_channel | accounts_in_cohort | active_accounts | logo_retention_rate_pct
```
Same as above, broken down by plan and acquisition channel for segment analysis.

**`cohort_mrr_retention_view`**
```sql
cohort_month | months_since_cohort | start_mrr | cohort_mrr | grr | nrr
```
Computes GRR (churn + contraction only) and NRR (including expansion) per cohort per month, expressed as a ratio against starting MRR.

**`cohort_mrr_retention_segmented_view`**
```sql
cohort_month | months_since_cohort | initial_plan | acquisition_channel | start_mrr | cohort_mrr | grr | nrr
```
NRR and GRR split by plan and acquisition channel.

***

## Metric Definitions

| Metric | Formula | Interpretation |
|---|---|---|
| **Logo Retention** | Active accounts at M_n ÷ Accounts at M0 | % of accounts still subscribed at month N |
| **GRR** | (Starting MRR − churned MRR − contracted MRR) ÷ Starting MRR | Revenue retained excluding expansion; max = 100% |
| **NRR** | (Starting MRR − churned − contracted + expanded MRR) ÷ Starting MRR | Revenue retained including upsells; can exceed 100% |
| **Quick Ratio** | (New MRR + Expansion MRR) ÷ (Churned MRR + Contraction MRR) | Growth efficiency; >1 means growing |
| **Expansion MRR Share** | Expansion MRR ÷ (New + Expansion MRR) | How much growth comes from existing customers |

***

## Power BI Dashboards

### Dashboard 1 — SaaS Cohort Overview & KPIs

The main executive summary dashboard. Shows all primary KPIs (Logo Retention M12, NRR M12, GRR M12, Quick Ratio, Blended MRR), a full cohort heatmap (cohort × months since signup), MRR waterfall, NRR trajectory for oldest cohorts, MRR decay curves, and a segment summary by channel and plan.



***

### Dashboard 2 — Cohort Benchmarks (All 24 Cohorts)

Side-by-side comparison of all 24 cohorts. Includes KPI cards for best/worst cohort and portfolio averages, bar charts for Logo Retention M12, NRR M12, and Start MRR by cohort, ranked Top 5 / Bottom 5 cohort tables, and the full benchmark data table with M3/M6/M12 metrics.



***

### Dashboard 3 — Segment Analysis (Channel × Plan)

Drill-down into the 12 plan × channel segments (3 plans × 4 channels). Includes NRR and GRR matrix tables, trajectory line charts M0 → M12, grouped bar charts at M6, logo retention curves, a churn-risk scatter plot (NRR vs logo retention), and active account counts at M12. Filterable by Initial Plan and Acquisition Channel slicers.



***

## How to Reproduce

### Step 1 — Load Raw Data into MySQL

```sql
-- Create database
CREATE DATABASE saas_analytics;
USE saas_analytics;

-- Import tables
-- accounts: account_id, signup_date, initial_plan, acquisition_channel
-- account_month_mrr: account_id, month, mrr
```

### Step 2 — Run SQL Views in Order

Execute the `.sql` files from the `sql/` folder **in numerical order** (01 → 06).
Each view depends on the previous ones.

```bash
# Run in MySQL Workbench or via CLI
mysql -u root -p saas_analytics < sql/01_account_cohort_view.sql
mysql -u root -p saas_analytics < sql/02_account_month_with_age_view.sql
# ... continue through 06
```

### Step 3 — Export Views to CSV

Export each view as a `.csv` file into the `data/views/` folder. These CSV files serve as the data source for Power BI.

### Step 4 — Open Power BI Report

1. Open `powerbi/saas_cohort_analytics.pbix` in Power BI Desktop
2. Update the data source path to point to your local `data/views/` folder
3. Click **Refresh** to reload all data
4. All visuals and DAX measures will recalculate automatically

***

## Skills Demonstrated

- **SQL** — Window functions, CTEs, `DATEDIFF`, `DATE_FORMAT`, aggregation, multi-step view chaining
- **Data Modeling** — Incremental view architecture; separating raw data from analytical layers
- **SaaS Metrics** — NRR, GRR, Logo Retention, Quick Ratio, Expansion MRR — computed from scratch
- **Power BI** — Multi-page dashboards, DAX measures, conditional formatting, slicers, heatmaps
- **Analytical Thinking** — Cohort segmentation, best/worst cohort identification, churn risk profiling
- **Data Storytelling** — Translating retention data into actionable business insights

***

## Author

**[Your Name]**
M.Sc. Data Science · Junior Data Analyst
📧 [your.email@example.com]
🔗 [LinkedIn Profile URL]
🐙 [GitHub Profile URL]

***

*Dataset is synthetic and generated for portfolio purposes.*
