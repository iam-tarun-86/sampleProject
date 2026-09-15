#!/usr/bin/env bash
# Deploy TravelMate stack with docker compose
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
COMPOSE_FILE="${COMPOSE_FILE:-Docker-compose.yml}"

echo "==> Building and starting stack (${COMPOSE_FILE})"
docker compose -f "$COMPOSE_FILE" up -d --build
docker compose -f "$COMPOSE_FILE" ps
