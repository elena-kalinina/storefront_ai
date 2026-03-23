# StoreFront AI - Hackathon Battle Plan

**Event**: Amsterdam Hackathon - Vibe Coding AI Agent Apps with Google MCP + Cloud Run  
**Build Time**: 3 hours  
**Team**: Elena + AI Copilot  

---

## The Pitch (memorize this)

> "Opening a physical store is a $50K gamble. Pick the wrong block and you're dead in 6 months.  
> **StoreFront AI** is your AI location strategist.  
> Describe your business, your budget, your ideal customer — and in seconds, it analyzes demographics, competition gaps, foot traffic, and nearby complementary businesses to find your perfect spot.  
> Powered by Google Maps and BigQuery MCP servers, deployed on Cloud Run."

**One-liner**: *"Tell me your business. I'll find where it thrives."*

---

## What We're Building

An **agentic AI application** that helps entrepreneurs find the optimal physical location for any brick-and-mortar business. The agent performs multi-step reasoning:

1. Understands the business type and target customer
2. Queries BigQuery for matching neighborhood demographics
3. Searches Google Maps for competitors (saturation risk)
4. Searches Google Maps for complementary businesses (foot traffic synergy)
5. Validates logistics (commute, weather)
6. Presents a ranked Location Scorecard

**Google MCP Servers Used**:
- Google Maps MCP (Grounding Lite) — `mapstools.googleapis.com/mcp`
- BigQuery MCP — `bigquery.googleapis.com/mcp`

**Framework**: Google Agent Development Kit (ADK)  
**Model**: Gemini 2.5 Flash  
**Deployment**: Cloud Run via `adk deploy cloud_run`

---

## Hour-by-Hour Sprint Plan

### HOUR 1: Foundation (0:00 - 1:00)

#### 1.1 GCP Project Setup (10 min)

```bash
# Set project
gcloud config set project YOUR_PROJECT_ID
export PROJECT_ID=$(gcloud config get project)

# Authenticate for ADK
gcloud auth application-default login
```

#### 1.2 Run Environment Setup Script (10 min)

```bash
cd /Users/elekal/Amsterdam_Hackathon/setup
./setup_env.sh
```

This enables all required APIs and creates the `.env` file.

**If the API key auto-creation fails**, manually create one:
1. Go to https://console.cloud.google.com/apis/credentials
2. Create API Key
3. Copy it into `storefront_agent/.env`

#### 1.3 Load BigQuery Data (5 min)

```bash
./setup_bigquery.sh
```

Verify in BigQuery console: https://console.cloud.google.com/bigquery  
Look for dataset `storefront_data` → table `neighborhoods` → 90 rows.

#### 1.4 Install Dependencies (5 min)

```bash
cd /Users/elekal/Amsterdam_Hackathon
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

#### 1.5 First Local Test (15 min)

```bash
adk web
```

Open http://127.0.0.1:8000, select `storefront_agent`.

Test with: *"I want to open a coffee shop in San Francisco targeting young professionals. Budget $4K/month rent."*

**Expected behavior**: Agent queries BigQuery → shortlists neighborhoods → searches Maps for coffee shops (competition) → searches for complementary businesses → returns scored recommendations.

#### 1.6 Troubleshoot & Fix (15 min)

Common issues:
- **Auth errors on BigQuery MCP**: Re-run `gcloud auth application-default login`
- **Maps MCP timeout**: Check API key in `.env`, verify APIs are enabled
- **Agent not using tools**: Refine the system prompt — make instructions more explicit
- **Import errors**: Check `__init__.py` exists, verify package structure

---

### HOUR 2: Refine the Agent Brain (1:00 - 2:00)

This is where we win or lose. Focus on:

#### 2.1 Prompt Engineering (30 min)

The system prompt in `agent.py` is our secret weapon. Iterate on it:
- Test different business types (cheese shop, yoga studio, bookstore, barbershop)
- Make sure the agent uses BOTH MCP servers (not just one)
- Ensure the output format is clean and readable
- Add specific examples if the agent struggles with certain business types

**Key things to tune**:
- Does the agent pick the right spending index column for each business type?
- Does it search for the right complementary businesses?
- Is the Location Scorecard output clear and well-formatted?

#### 2.2 Test Edge Cases (15 min)

Try these:
- Business type with no obvious spending index: "I want to open a pet grooming salon"
- Multi-turn conversation: ask a follow-up about a specific recommendation
- No budget provided: agent should ASK, not guess
- Different cities: make sure BigQuery queries work across all 6 cities

#### 2.3 Add Error Handling / Polish (15 min)

- If BigQuery returns no results, agent should suggest broadening criteria
- If Maps finds zero competitors, agent should flag it as either "blue ocean" or "no demand"
- Make sure Google Maps links are included in responses

---

### HOUR 3: Deploy & Prepare Demo (2:00 - 3:00)

#### 3.1 Deploy to Cloud Run (15 min)

```bash
adk deploy cloud_run \
  --project=$PROJECT_ID \
  --region=us-central1 \
  --service_name=storefront-ai \
  ./storefront_agent
```

**If `adk deploy` fails**, manual alternative:

```bash
# Build and deploy manually
gcloud run deploy storefront-ai \
  --source=. \
  --region=us-central1 \
  --allow-unauthenticated \
  --set-env-vars="PROJECT_ID=$PROJECT_ID,MAPS_API_KEY=$(grep MAPS_API_KEY storefront_agent/.env | cut -d= -f2)"
```

#### 3.2 Test Deployed URL (10 min)

Get the Cloud Run URL from the deploy output and test it end-to-end.

#### 3.3 Rehearse Demo (20 min)

Run through the exact demo script below 2-3 times. Time yourself.

#### 3.4 Prepare Presentation (15 min)

One slide with architecture diagram (or just draw it on a whiteboard).

---

## Demo Script (2.5 minutes total)

### Opening (15 sec)

*"Opening a physical store is a 50K dollar gamble. 60% of retail businesses fail because they picked the wrong location. Meet StoreFront AI — your AI location strategist."*

### Scenario 1: The Cheese Shop (60 sec)

Type into the app:

> "I want to open an artisanal cheese shop in San Francisco. My target customer is food-loving professionals aged 25-45. My rent budget is $5,000 per month."

**Narrate while agent works**: *"The agent is now querying our BigQuery database for SF neighborhoods matching the demographic profile... now it's searching Google Maps for existing cheese shops to analyze competition... and here it's looking for complementary businesses — wine bars, farmers markets — that would drive foot traffic to our shop..."*

**Point out**: The ranked scorecard, the competition analysis, the complementary business insight.

### Scenario 2: The Quick Pivot (30 sec)

> "What if I opened a yoga studio in Austin instead?"

**Narrate**: *"Same agent, completely different analysis. Watch how it switches to the wellness spending index, searches for gyms and juice bars as complementary businesses, and finds a totally different set of neighborhoods."*

This proves it's truly general-purpose, not hard-coded.

### Scenario 3: Deep Dive (30 sec)

> "How far is the top recommendation from downtown? And what's the weather like there?"

Shows multi-turn context + Maps route + weather lookup.

### Closing (15 sec)

*"Two Google MCP servers — Maps and BigQuery — orchestrated by Google ADK with Gemini 2.5 Flash, deployed on Cloud Run. Built in three hours. StoreFront AI."*

---

## Key Talking Points for Q&A

**"Why not just use Google Maps directly?"**
> "Maps tells you what's THERE. StoreFront AI tells you what's MISSING — the gap analysis. It combines demographic data with real-world location intelligence to find opportunities, not just listings."

**"How is this different from the Google Bakery codelab?"**
> "The codelab is hard-coded for bakeries in LA. StoreFront AI works for ANY business type — cheese shop, yoga studio, bookstore, barbershop. The agent dynamically adapts its analysis based on the business."

**"What about the data quality?"**
> "In production, this would connect to live census data, commercial real estate APIs, and Yelp/Google Business ratings. The architecture supports it — just add more BigQuery tables or MCP servers."

**"How would you scale this?"**
> "It's already on Cloud Run, so it auto-scales to zero when idle and handles traffic spikes. The MCP servers are Google-managed. The BigQuery data layer can grow to petabytes."

---

## Emergency Fallbacks

| Problem | Fallback |
|---------|----------|
| Cloud Run deploy fails | Demo from `adk web` locally (still shows the agent works) |
| BigQuery MCP auth expires mid-demo | Refresh: `gcloud auth application-default login` before demo |
| Maps MCP rate limit hit | Pre-cache one full demo conversation; worst case, show screenshots |
| Agent gives weird answer | Have 3 pre-tested scenarios; stick to the script |
| Internet is down | Pre-record a screen capture of a successful demo as insurance |

---

## Pre-Demo Checklist

- [ ] Cloud Run URL is accessible
- [ ] `.env` has valid `PROJECT_ID` and `MAPS_API_KEY`
- [ ] BigQuery dataset `storefront_data.neighborhoods` has 90 rows
- [ ] Ran through all 3 demo scenarios successfully on the deployed URL
- [ ] Architecture slide/diagram ready
- [ ] Timer: demo fits in 2.5 minutes
- [ ] Backup: `adk web` running locally as fallback

---

## Project Structure Reference

```
Amsterdam_Hackathon/
├── .gitignore
├── .env.example                 # Template (committed)
├── README.md
├── Hackathon_Instructions.md    # This file
├── requirements.txt
├── storefront_agent/
│   ├── __init__.py
│   ├── agent.py                 # THE BRAIN — LlmAgent + system prompt
│   ├── tools.py                 # Maps MCP + BigQuery MCP connections
│   └── .env                     # Secrets (NOT committed, created by setup)
├── data/
│   └── neighborhoods.csv        # 90 rows, 6 cities
├── setup/
│   ├── setup_env.sh             # GCP APIs + .env creation
│   └── setup_bigquery.sh        # Dataset + table creation
└── cleanup/
    └── cleanup.sh               # Tear down resources
```

---

## Scoring Reminder

| Category | Points | Our Strategy |
|----------|--------|-------------|
| **Technical Excellence** | 50 | Two MCP servers, 6-step agentic reasoning, ADK framework, proper error handling |
| **Unique Features** | Part of 50 | Complementary business analysis (no one else does this), any-business-type flexibility |
| **User Experience** | Part of 50 | Conversational, Location Scorecard output, Google Maps links |
| **Presentation & Demo** | 20 | Scripted 2.5min demo, 3 scenarios, clear architecture explanation, business value pitch |

---

**LET'S GET THAT PODIUM.**
