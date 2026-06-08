#!/bin/sh
# Simule des logs pfSense (trafic normal + pics de blocages = anomalie)
LOG_FILE="/var/log/pfsense/firewall.log"
mkdir -p /var/log/pfsense

normal() {
  ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  echo "$ts action=pass src=10.20.10.45 dst=10.20.20.10 proto=tcp rule=LAN-to-SERVERS" >> "$LOG_FILE"
}

blocked_scan() {
  ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  src="10.20.99.$((RANDOM % 200 + 1))"
  echo "$ts action=block src=$src dst=10.20.10.1 proto=tcp rule=WAN-block-scan reason=port_scan_detected" >> "$LOG_FILE"
}

echo "pfSense log simulator started" >&2
cycle=0
while true; do
  normal
  normal
  if [ $((cycle % 30)) -eq 0 ]; then
    i=0
    while [ $i -lt 25 ]; do
      blocked_scan
      i=$((i + 1))
    done
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") action=alert msg=anomaly_detected type=port_scan_spike" >> "$LOG_FILE"
  fi
  cycle=$((cycle + 1))
  sleep 5
done
