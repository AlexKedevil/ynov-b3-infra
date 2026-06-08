#!/usr/bin/env bash
# Vérifie que Promtail reçoit le syslog (pfSense ou test local).
set -euo pipefail

HOST="${1:-127.0.0.1}"
PORT="${2:-1514}"

echo "1. Envoi d'un message syslog test vers ${HOST}:${PORT}..."
echo '<134>Jun  8 16:00:00 pfSense filterlog: 0,,,1000000103,em1,match,block,in,4,0x0,,,test' \
  | nc -u -w2 "$HOST" "$PORT"

echo "2. Attente ingestion Loki (5s)..."
sleep 5

echo "3. Requête Loki (source=pfsense-vm)..."
result=$(curl -sf -G "http://localhost:3100/loki/api/v1/query" \
  --data-urlencode 'query={job="pfsense",source="pfsense-vm"}' \
  --data-urlencode 'limit=3') || { echo "Loki inaccessible sur :3100"; exit 1; }

count=$(echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(sum(len(s['values']) for s in d['data']['result']))" 2>/dev/null || echo 0)

if [ "$count" -gt 0 ]; then
  echo "OK — $count entrée(s) pfSense dans Loki."
  echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin);
[print(v[1][:100]) for s in d['data']['result'] for v in s['values'][:2]]" 2>/dev/null
else
  echo "Aucune entrée pfSense-vm. Vérifiez: docker compose up, port 1514, config pfSense → 10.20.0.254"
  exit 1
fi
