#!/bin/bash
set -euo pipefail

echo "=== StoreFront AI - Cleanup ==="

PROJECT_ID=$(gcloud config get project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo "ERROR: No GCP project set."
    exit 1
fi

echo "Cleaning up resources for project: $PROJECT_ID"

echo ""
echo "Deleting BigQuery dataset..."
bq --project_id="$PROJECT_ID" rm -r -f "$PROJECT_ID:storefront_data" 2>/dev/null || echo "Dataset not found, skipping."

echo ""
echo "Deleting Cloud Run service (if deployed)..."
gcloud run services delete storefront-ai \
    --region=us-central1 \
    --project="$PROJECT_ID" \
    --quiet 2>/dev/null || echo "Service not found, skipping."

echo ""
echo "=== Cleanup complete ==="
