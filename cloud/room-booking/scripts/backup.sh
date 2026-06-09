#!/usr/bin/env bash
# Sauvegarde PostgreSQL — room-booking (local Docker)
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="backup_$(date +%Y%m%d_%H%M).sql"
docker compose exec -T postgres pg_dump -U roombooking roombooking > "$OUT"
echo "Backup written: $OUT ($(wc -c < "$OUT") bytes)"
head -3 "$OUT"
