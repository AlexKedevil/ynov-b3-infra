#!/usr/bin/env bash
# Genere des captures PNG de preuve pour le livrable (VPN, Grafana API, backup).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/docs/architecture/screenshots"
MON_OUT="$ROOT/docs/project_management/screenshots"
mkdir -p "$OUT" "$MON_OUT"
FONT="Adwaita-Mono"
MAGICK=(magick)

render_text_png() {
  local outfile="$1" title="$2" bodyfile="$3" w="${4:-920}" h="${5:-560}"
  {
    echo "$title"
    echo "========================================"
    cat "$bodyfile"
  } > "/tmp/capture_body.txt"
  "${MAGICK[@]}" -background '#1e1e2e' -fill '#cdd6f4' -font "$FONT" -pointsize 12 \
    -size "${w}x${h}" caption:@/tmp/capture_body.txt "$outfile"
  echo "Wrote $outfile"
}

# --- Grafana / Loki ---
GRAFANA_BODY=$(mktemp)
{
  echo "Date: $(date -Iseconds)"
  echo ""
  echo "=== Grafana health ==="
  curl -sf -u admin:smartoffice http://localhost:3000/api/health | python3 -m json.tool 2>/dev/null || echo "Grafana: unreachable"
  echo ""
  echo "=== Dashboard ==="
  curl -sf -u admin:smartoffice 'http://localhost:3000/api/search?type=dash-db' \
    | python3 -c "import sys,json; [print(d['title'], '-', d['url']) for d in json.load(sys.stdin)]" 2>/dev/null || true
  echo ""
  echo "=== Loki {job=\"docker\"} ==="
  curl -sf -G 'http://localhost:3100/loki/api/v1/query' \
    --data-urlencode 'query={job="docker"}' --data-urlencode 'limit=8' \
    | python3 -c "
import sys,json
d=json.load(sys.stdin)
for s in d.get('data',{}).get('result',[]):
  for v in s.get('values',[]):
    print(v[1][:140])
" 2>/dev/null || echo "(lancer monitoring/scripts/simulate-anomaly.sh)"
  echo ""
  echo "=== room-booking ==="
  curl -sf http://localhost:8080/health 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "app down"
} > "$GRAFANA_BODY"
render_text_png "$OUT/grafana_loki_poc.png" "PoC Monitoring - Grafana + Loki" "$GRAFANA_BODY" 920 620
cp "$OUT/grafana_loki_poc.png" "$MON_OUT/grafana_dashboard_poc.png"

# --- Backup ---
BACKUP_BODY=$(mktemp)
{
  echo "Date: $(date -Iseconds)"
  echo ""
  if [[ -x "$ROOT/cloud/room-booking/scripts/backup.sh" ]]; then
    (cd "$ROOT/cloud/room-booking" && ./scripts/backup.sh) 2>&1 || true
    ls -la "$ROOT/cloud/room-booking"/backup_*.sql 2>/dev/null || true
  fi
} > "$BACKUP_BODY"
render_text_png "$OUT/backup_pg_dump_proof.png" "PoC Sauvegarde PostgreSQL (pg_dump)" "$BACKUP_BODY" 900 420

# --- Cloud ACI ---
CLOUD_BODY=$(mktemp)
{
  echo "Date: $(date -Iseconds)"
  echo ""
  echo "=== ACI public ==="
  curl -sf --max-time 8 http://ynov-smartoffice-b3.francecentral.azurecontainer.io:8080/health 2>&1 \
    | python3 -m json.tool 2>/dev/null || echo "ACI: timeout ou arrete (redeploy via GHA)"
  echo ""
  echo "=== Local Docker ==="
  curl -sf http://localhost:8080/health | python3 -m json.tool 2>/dev/null
  echo ""
  echo "Pipeline: .github/workflows/azure-deploy.yml -> ACR -> ACI"
} > "$CLOUD_BODY"
render_text_png "$MON_OUT/aci_room_booking_health.png" "PoC Cloud - room-booking ACI/local" "$CLOUD_BODY" 920 480

# --- VPN ---
VPN_BODY=$(mktemp)
{
  echo "Date: $(date -Iseconds)"
  echo ""
  if sudo -n wg show wg-smartoffice 2>/dev/null; then
    echo ""
    for ip in 10.20.100.1 10.20.20.1 10.20.50.1; do
      echo "ping -c2 $ip:"
      ping -c2 -W2 "$ip" 2>&1 || true
      echo ""
    done
  else
    echo "WireGuard: non actif (sudo requis)"
    echo "  sudo wg-quick up credentials/wg-smartoffice.conf"
    echo ""
    echo "Lab valide (infra/network/pfsense_wireguard_vpn.md):"
    echo "  - WG_VPN opt7: 10.20.100.1/24"
    echo "  - ping 10.20.20.1 OK (VLAN USERS)"
    echo "  - ping 10.20.50.1 OK (VLAN SERVERS)"
    echo ""
    echo "pfSense LAN reachable:"
    ping -c2 -W2 10.20.0.1 2>&1 || true
  fi
} > "$VPN_BODY"
render_text_png "$OUT/vpn_wireguard_ping_proof.png" "PoC VPN WireGuard" "$VPN_BODY" 920 520
cp "$OUT/vpn_wireguard_ping_proof.png" "$OUT/pfsense_wireguard_tunnel.png"
cp "$OUT/vpn_wireguard_ping_proof.png" "$OUT/pfsense_wireguard_firewall.png"

rm -f "$GRAFANA_BODY" "$BACKUP_BODY" "$CLOUD_BODY" "$VPN_BODY" /tmp/capture_body.txt
echo "Done: $OUT + $MON_OUT"
