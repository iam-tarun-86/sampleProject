#!/usr/bin/env bash
# Active post-deploy health check: 5 curl attempts expecting HTTP 200
set -euo pipefail
HOST="${1:-127.0.0.1}"
PORT="${2:-8080}"
PATH_SUFFIX="${3:-/health}"
URL="http://${HOST}:${PORT}${PATH_SUFFIX}"
ATTEMPTS="${HEALTH_ATTEMPTS:-5}"
SLEEP_SECS="${HEALTH_SLEEP:-5}"

echo "==> Health check against ${URL} (${ATTEMPTS} attempts)"
for i in $(seq 1 "$ATTEMPTS"); do
  code=$(curl -sS -o /tmp/tm-health-body.txt -w "%{http_code}" --max-time 5 "$URL" || echo "000")
  body=$(cat /tmp/tm-health-body.txt 2>/dev/null || true)
  echo "  attempt ${i}/${ATTEMPTS}: HTTP ${code} body='${body}'"
  if [[ "$code" == "200" ]]; then
    echo "==> HEALTHY"
    exit 0
  fi
  sleep "$SLEEP_SECS"
done
echo "==> UNHEALTHY after ${ATTEMPTS} attempts" >&2
exit 1
