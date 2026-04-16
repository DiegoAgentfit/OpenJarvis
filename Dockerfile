# OpenJarvis all-in-one container (backend + bundled frontend).
#
# Build: docker build -t openjarvis .
# Run:   docker run -e OPENAI_API_KEY=sk-... -p 8000:8000 openjarvis
#
# Auto-detected by Railway, Render, Fly.io, Google Cloud Run, etc.

# ── Stage 1: Build frontend SPA into the backend static directory ──────────
FROM node:22-slim AS frontend

WORKDIR /frontend
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm ci --ignore-scripts 2>/dev/null || npm install
COPY frontend/ .
# build:backend outputs to ../src/openjarvis/server/static so the Python
# server can serve the SPA from the same origin as the API.
RUN npm run build:backend

# ── Stage 2: Install Python package + cloud inference SDKs ─────────────────
FROM python:3.12-slim-bookworm AS builder

WORKDIR /app
COPY pyproject.toml README.md ./
COPY src/ src/
COPY --from=frontend /src/openjarvis/server/static src/openjarvis/server/static/

RUN pip install --no-cache-dir uv && \
    uv pip install --system ".[server,inference-cloud]"

# ── Stage 3: Runtime ───────────────────────────────────────────────────────
FROM python:3.12-slim-bookworm

COPY --from=builder /usr/local /usr/local
COPY --from=builder /app /app
WORKDIR /app

# Railway/Render/Fly set PORT automatically; default to 8000 locally.
ENV PORT=8000
EXPOSE 8000

# Use shell form so $PORT expands at runtime.
CMD jarvis serve --host 0.0.0.0 --port ${PORT}
