# Deployment Guide

OpenJarvis needs a Python backend running somewhere. The frontend (Vercel) is just the UI. Pick the option that fits your situation.

## Option 1 — Railway (easiest, recommended)

One-click deploy to a managed host. ~$5/mo.

1. Go to [railway.app](https://railway.app) and sign in with GitHub.
2. Click **New Project** → **Deploy from GitHub repo** → select your fork of OpenJarvis.
3. Railway auto-detects `railway.json` and builds the `Dockerfile`.
4. In the project **Variables** tab, add at least one of:
   - `OPENAI_API_KEY`
   - `ANTHROPIC_API_KEY`
   - `GEMINI_API_KEY`
   - `OPENROUTER_API_KEY`
5. Click **Generate Domain** to get a public URL like `https://openjarvis-production.up.railway.app`.
6. Open that URL in a browser — the full app loads (the Dockerfile bundles the frontend).

That's it. The backend serves both the API and the React SPA from one container.

### Point your Vercel deployment at Railway (optional)

If you want the Vercel deployment to use this backend:

1. In Vercel → your project → **Settings** → **Environment Variables**.
2. Add `VITE_API_URL` = `https://your-app.up.railway.app`.
3. Redeploy.

Or skip Vercel entirely and just use the Railway URL.

---

## Option 2 — Render

1. Go to [render.com](https://render.com), sign in with GitHub.
2. Click **New** → **Blueprint** → select the repo.
3. Render reads `render.yaml` and creates the service.
4. Add at least one API key env var in the Render dashboard.
5. Wait for build (5–10 min first time).
6. Visit the provided URL.

---

## Option 3 — Local Docker

Run everything on your laptop with one command:

```bash
docker build -t openjarvis .
docker run -e OPENAI_API_KEY=sk-... -p 8000:8000 openjarvis
```

Open http://localhost:8000.

### docker-compose (with Ollama for local models)

```bash
cd deploy/docker
docker compose up
```

This starts OpenJarvis + Ollama together. Visit http://localhost:8000.

---

## Option 4 — Bare metal (no Docker)

```bash
cp .env.example .env
# edit .env and add your OPENAI_API_KEY
uv sync --extra server --extra inference-cloud
./scripts/start-server.sh
```

---

## Which API keys do I need?

You only need **one** of these. Set as many as you want:

| Provider | Env Var | Get a key |
|---|---|---|
| OpenAI | `OPENAI_API_KEY` | https://platform.openai.com/api-keys |
| Anthropic (Claude) | `ANTHROPIC_API_KEY` | https://console.anthropic.com/settings/keys |
| Google Gemini | `GEMINI_API_KEY` | https://aistudio.google.com/apikey |
| OpenRouter | `OPENROUTER_API_KEY` | https://openrouter.ai/keys |

If multiple are set, the model picker in the UI shows all available models.

---

## Troubleshooting

**"No inference engine available."** — No API key was found at startup. Double-check your env vars are set on the server (not just locally).

**Models list is empty** — Your API key is set but invalid. Check the key in the provider's dashboard.

**Frontend loads but chat doesn't work** — Open browser devtools → Network tab. If requests go to the wrong URL, fix `VITE_API_URL` or the in-app Settings → API Server URL.

**Healthcheck failing on Railway** — First build can take 5–10 min. Check the Deploy logs tab.
