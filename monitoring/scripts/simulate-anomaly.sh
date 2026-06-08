#!/usr/bin/env bash
# Génère du trafic anormal sur room-booking pour déclencher des logs 4xx/5xx.
set -euo pipefail

BASE_URL="${1:-http://localhost:8080}"

echo "Simulating API anomalies against $BASE_URL"

for _ in $(seq 1 15); do
  curl -sf -o /dev/null "$BASE_URL/rooms/999/availability" || true
  curl -sf -o /dev/null -X POST "$BASE_URL/bookings" \
    -H "Content-Type: application/json" \
    -d '{"room_id":999,"start_time":"bad","end_time":"also-bad"}' || true
done

for _ in $(seq 1 10); do
  curl -sf -o /dev/null "$BASE_URL/rooms/1/availability" || true
done

echo "Done. Check Grafana dashboard 'Smart Office — Logs & Anomalies'."
