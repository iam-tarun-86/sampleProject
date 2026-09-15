#!/usr/bin/env bash
# Instant rollback: remove faulty backend container and start previous-stable image
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
COMPOSE_FILE="${COMPOSE_FILE:-Docker-compose.yml}"

echo "==> ROLLBACK: removing faulty travelmate-backend container"
docker rm -f travelmate-backend >/dev/null 2>&1 || true

if ! docker image inspect travelmate-backend:previous-stable >/dev/null 2>&1; then
  echo "ERROR: travelmate-backend:previous-stable not found. Run a healthy deploy first." >&2
  exit 1
fi

NET=$(docker network ls --format '{{.Name}}' | grep -E 'travelmate|sampleproject' | head -1 || true)
if [[ -z "$NET" ]]; then
  docker compose -f "$COMPOSE_FILE" up -d mysqldb
  sleep 5
  NET=$(docker network ls --format '{{.Name}}' | grep -E 'travelmate|sampleproject' | head -1)
fi

echo "==> ROLLBACK: starting travelmate-backend:previous-stable on network ${NET}"
docker run -d --name travelmate-backend \
  --network "$NET" \
  -p 8080:8080 \
  -e SPRING_DATASOURCE_URL='jdbc:mysql://mysqldb:3306/travelmate_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true' \
  -e SPRING_DATASOURCE_USERNAME=root \
  -e SPRING_DATASOURCE_PASSWORD=root \
  -e SPRING_JPA_HIBERNATE_DDL_AUTO=update \
  travelmate-backend:previous-stable

docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
