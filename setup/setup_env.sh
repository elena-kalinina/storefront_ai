#!/bin/bash
set -euo pipefail

echo "=== StoreFront AI - Environment Setup ==="

PROJECT_ID=$(gcloud config get project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo "ERROR: No GCP project set. Run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi
echo "Using project: $PROJECT_ID"

echo ""
echo "Enabling required APIs..."
gcloud services enable \
    bigquery.googleapis.com \
    run.googleapis.com \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com \
    routes.googleapis.com \
    places-backend.googleapis.com \
    --project="$PROJECT_ID"
echo "APIs enabled."

echo ""
echo "Creating Maps API key..."
MAPS_KEY_OUTPUT=$(gcloud services api-keys create \
    --display-name="StoreFront AI Maps Key" \
    --project="$PROJECT_ID" \
    --format="json" 2>&1) || true

MAPS_API_KEY=$(echo "$MAPS_KEY_OUTPUT" | grep -o '"keyString": "[^"]*"' | cut -d'"' -f4)

if [ -z "$MAPS_API_KEY" ]; then
    echo "WARNING: Could not auto-create API key."
    echo "Please create one manually at: https://console.cloud.google.com/apis/credentials"
    echo "Then set it in the .env file."
    MAPS_API_KEY="REPLACE_WITH_YOUR_KEY"
fi

REGION="us-central1"

echo ""
echo "Writing .env file..."
cat > ../storefront_agent/.env << EOF
PROJECT_ID=$PROJECT_ID
MAPS_API_KEY=$MAPS_API_KEY
REGION=$REGION
EOF
echo ".env file created at storefront_agent/.env"

echo ""
echo "=== Environment setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Verify MAPS_API_KEY in storefront_agent/.env"
echo "  2. Run: ./setup/setup_bigquery.sh"
echo "  3. Run: pip install -r requirements.txt"
echo "  4. Run: cd .. && adk web"
