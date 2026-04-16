#!/usr/bin/env bash
# Start the OpenJarvis backend server.
# Usage: ./scripts/start-server.sh
#
# Requires at least one API key in .env or environment:
#   OPENAI_API_KEY, ANTHROPIC_API_KEY, GEMINI_API_KEY, or OPENROUTER_API_KEY

set -euo pipefail
cd "$(dirname "$0")/.."

# Load .env if it exists
if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

# Check that at least one key is set
if [ -z "${OPENAI_API_KEY:-}" ] && [ -z "${ANTHROPIC_API_KEY:-}" ] && \
   [ -z "${GEMINI_API_KEY:-}" ] && [ -z "${OPENROUTER_API_KEY:-}" ]; then
  echo "ERROR: No API key found."
  echo ""
  echo "Set at least one of these environment variables:"
  echo "  export OPENAI_API_KEY=sk-..."
  echo "  export ANTHROPIC_API_KEY=sk-ant-..."
  echo "  export GEMINI_API_KEY=AIzaSy..."
  echo "  export OPENROUTER_API_KEY=sk-or-..."
  echo ""
  echo "Or copy .env.example to .env and fill in a key."
  exit 1
fi

HOST="${JARVIS_HOST:-0.0.0.0}"
PORT="${JARVIS_PORT:-8000}"

echo "Starting OpenJarvis server on ${HOST}:${PORT}..."
exec uv run jarvis serve --host "$HOST" --port "$PORT" -e cloud
