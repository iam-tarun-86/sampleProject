# TravelMate CD Rollback Lab

Post-mortem style lab: **automated post-deploy health checking** and **instant rollback** on the TravelMate (Spring Boot + React + MySQL) stack.

## What was added

1. `GET /health` (also `/actuator/health`) — HTTP 200 + JSON `status=UP` when healthy (`HealthController`).
2. Spring Security permits unauthenticated access to `/health` and `/actuator/health`.
3. `.github/workflows/ci-cd.yml` — after `docker compose up`:
   - Active health check: curl loop **5 attempts** to `http://127.0.0.1:8080/health` expecting **HTTP 200**
   - Explicit **rollback** step with `if: failure()` that tears down faulty containers and restores previous-stable / baseline
4. Helper scripts under `scripts/`: `healthcheck.sh`, `deploy.sh`, `rollback.sh`

## Demo sequence

### A. Healthy baseline
Push a healthy commit → Actions `docker-ci` deploys, health passes, images tagged `previous-stable`.

### B. Broken deploy + rollback
Break `/health` (return 500) or break backend config, push → health check fails → rollback step runs → stack restored.

### C. Local Docker Desktop (MASTERPC)
```powershell
cd C:\Users\tarun\Documents\sampleProject   # or clone path
docker compose -f Docker-compose.yml up -d --build
curl.exe -i http://127.0.0.1:8080/health
# break health, redeploy, run scripts\healthcheck.sh / rollback flow
```

Screenshots: `C:\Users\tarun\Documents\cd-rollback-screenshots\`
