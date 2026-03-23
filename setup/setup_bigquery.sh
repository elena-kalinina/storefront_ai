#!/bin/bash
set -euo pipefail

echo "=== StoreFront AI - BigQuery Setup ==="

PROJECT_ID=$(gcloud config get project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo "ERROR: No GCP project set. Run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi
echo "Using project: $PROJECT_ID"

DATASET="storefront_data"
TABLE="neighborhoods"
CSV_PATH="../data/neighborhoods.csv"

if [ ! -f "$CSV_PATH" ]; then
    echo "ERROR: CSV file not found at $CSV_PATH"
    echo "Make sure you're running this from the setup/ directory."
    exit 1
fi

echo ""
echo "Creating BigQuery dataset: $DATASET"
bq --project_id="$PROJECT_ID" mk --dataset --location=US \
    --description="StoreFront AI neighborhood data" \
    "$PROJECT_ID:$DATASET" 2>/dev/null || echo "Dataset already exists, continuing..."

echo ""
echo "Loading neighborhoods data into BigQuery..."
bq --project_id="$PROJECT_ID" load \
    --source_format=CSV \
    --autodetect \
    --replace \
    "$PROJECT_ID:$DATASET.$TABLE" \
    "$CSV_PATH"

echo ""
echo "Verifying data load..."
ROW_COUNT=$(bq --project_id="$PROJECT_ID" query --nouse_legacy_sql --format=json \
    "SELECT COUNT(*) as cnt FROM \`$PROJECT_ID.$DATASET.$TABLE\`" | grep -o '"cnt":"[0-9]*"' | cut -d'"' -f4)
echo "Loaded $ROW_COUNT rows into $DATASET.$TABLE"

echo ""
echo "Sample data:"
bq --project_id="$PROJECT_ID" query --nouse_legacy_sql \
    "SELECT city, neighborhood, zip_code, median_household_income, foot_traffic_index
     FROM \`$PROJECT_ID.$DATASET.$TABLE\`
     ORDER BY foot_traffic_index DESC
     LIMIT 5"

echo ""
echo "=== BigQuery setup complete ==="
echo ""
echo "Next steps:"
echo "  1. pip install -r requirements.txt"
echo "  2. cd to parent of storefront_agent/"
echo "  3. adk web"
