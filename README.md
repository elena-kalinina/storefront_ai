# StoreFront AI

**AI Location Intelligence for Brick-and-Mortar Businesses**

> "Tell me your business. I'll find where it thrives."

StoreFront AI is an agentic AI application that helps entrepreneurs find the optimal physical location for their store, restaurant, studio, or any brick-and-mortar business. It combines Google Maps real-world location data with BigQuery demographic analytics through Google's MCP servers, orchestrated by the Google Agent Development Kit (ADK).

## Architecture

```
Google Cloud Run (deployed app)
  └── Google ADK Agent (Gemini 2.5 Flash)
        ├── Google Maps MCP Server (Grounding Lite)
        │     • Search places (competitors, complementary businesses)
        │     • Compute routes (commute times)
        │     • Weather lookup
        └── BigQuery MCP Server
              • Neighborhood demographics
              • Foot traffic indices
              • Commercial rent estimates
              • Spending category indices
```

## Quick Start

### Prerequisites

- Python 3.10+
- Google Cloud project with billing enabled
- `gcloud` CLI authenticated

### Setup

```bash
# 1. Set your GCP project
gcloud config set project YOUR_PROJECT_ID

# 2. Authenticate
gcloud auth application-default login

# 3. Run environment setup (enables APIs, creates .env)
cd setup
./setup_env.sh

# 4. Load BigQuery data
./setup_bigquery.sh

# 5. Install Python dependencies
cd ..
pip install -r requirements.txt

# 6. Launch the agent
adk web
```

Open `http://127.0.0.1:8000` and select `storefront_agent`.

### Deploy to Cloud Run

```bash
adk deploy cloud_run \
  --project=$(gcloud config get project) \
  --region=us-central1 \
  --service_name=storefront-ai \
  ./storefront_agent
```

## Example Conversations

**Scenario 1 - Cheese Shop:**
> "I want to open an artisanal cheese shop in San Francisco. My target customer is food-loving professionals aged 25-45. Rent budget: $5K/month."

**Scenario 2 - Yoga Studio:**
> "I'm looking to open a yoga studio in Austin, targeting wellness-conscious millennials. Where should I set up?"

**Scenario 3 - Quick Pivot:**
> "What about a vintage bookstore in Chicago instead?"

## Data

The `data/neighborhoods.csv` contains demographic and commercial data for ~90 neighborhoods across 6 US cities:
- San Francisco, New York, Austin, Chicago, Los Angeles, Seattle

## Cleanup

```bash
cd cleanup
./cleanup.sh
```

## Tech Stack

- **Agent Framework**: Google Agent Development Kit (ADK)
- **LLM**: Gemini 2.5 Flash
- **MCP Servers**: Google Maps (Grounding Lite) + BigQuery
- **Deployment**: Google Cloud Run
- **Data**: BigQuery
