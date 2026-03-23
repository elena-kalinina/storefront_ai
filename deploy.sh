#!/bin/bash
set -euo pipefail

PROJECT_ID="YOUR_PROJECT"
REGION="us-central1"
SERVICE_NAME="storefront-ai"
MAPS_API_KEY="YOUR_MAPS_API_KEY"

echo "=== Deploying StoreFront AI to Cloud Run ==="

gcloud run deploy "$SERVICE_NAME" \
  --source . \
  --region "$REGION" \
  --project "$PROJECT_ID" \
  --allow-unauthenticated \
  --set-env-vars="GOOGLE_CLOUD_PROJECT=$PROJECT_ID,GOOGLE_CLOUD_LOCATION=global,GOOGLE_GENAI_USE_VERTEXAI=true,PROJECT_ID=$PROJECT_ID,MAPS_API_KEY=$MAPS_API_KEY,SERVE_WEB_INTERFACE=true"

echo ""
echo "=== Deployment complete ==="
