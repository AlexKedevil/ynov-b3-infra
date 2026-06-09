#!/usr/bin/env bash
# Restauration PostgreSQL — room-booking (local Docker)
set -euo pipefail
cd "$(dirname "$0")/.."
DUMP="${1:?Usage: restore.sh backup_YYYYMMDD_HHMM.sql}"
docker compose stop room-booking 2>/dev/null || true
docker compose exec -T postgres psql -U roombooking -d roombooking \
  -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
docker compose exec -T postgres psql -U roombooking roombooking < "$DUMP"
docker compose start room-booking
curl -sf http://localhost:8080/health && echo " — restore OK"
