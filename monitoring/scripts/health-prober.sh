#!/bin/sh
# Sonde HTTP -> fichier partagé (Promtail -> Loki -> Grafana stat panels)
set -eu
INTERVAL="${INTERVAL:-30}"
LOG_DIR="${LOG_DIR:-/var/log/healthcheck}"
LOG_FILE="${LOG_DIR}/probes.log"
mkdir -p "$LOG_DIR"

probe() {
  name="$1"
  url="$2"
  timeout="${3:-5}"
  if curl -sf --max-time "$timeout" "$url" >/dev/null 2>&1; then
    status="UP"
    code="200"
  else
    status="DOWN"
    code="000"
  fi
  line="job=healthcheck service=${name} status=${status} http_code=${code} url=${url}"
  echo "$line" >> "$LOG_FILE"
  echo "$line"
}

while true; do
  probe "loki" "http://loki:3100/ready"
  probe "grafana" "http://grafana:3000/api/health"
  probe "promtail" "http://promtail:9080/ready"
  probe "room-booking" "http://host.docker.internal:8080/health"
  probe "aci-azure" "${ACI_HEALTH_URL:-http://ynov-smartoffice-b3.francecentral.azurecontainer.io:8080/health}" 10
  sleep "$INTERVAL"
done
