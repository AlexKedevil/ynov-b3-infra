#!/usr/bin/env bash
# Assemble le ZIP Moodle depuis docs/ (sans PDF si pandoc absent).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
STAGING="$ROOT/docs/livrable/_staging"
ZIP="$ROOT/docs/livrable/SmartOffice_B3_$(date +%Y%m%d).zip"
rm -rf "$STAGING"
mkdir -p "$STAGING"/{04_PoC_Reseau,05_PoC_Cloud,06_PoC_Monitoring,08_Gestion_projet}

copy_md_as_txt() {
  local src="$1" dest="$2"
  cp "$src" "$dest/$(basename "${src%.md}.txt")"
}

# Index
cat > "$STAGING/README.txt" <<EOF
Smart Office 2.0 - Ynov B3 INFRA
Equipe: Flaujat Sam, Queudeville Alexandre
Depot: https://github.com/AlexKedevil/ynov-b3-infra
Genere: $(date -Iseconds)
EOF

# Markdown sources (txt pour lecture sans outil PDF)
for f in DAT.md; do copy_md_as_txt "$ROOT/docs/$f" "$STAGING"; done
for f in "$ROOT/docs/security"/*.md; do copy_md_as_txt "$f" "$STAGING"; done
for f in "$ROOT/docs/pca_pra"/*.md; do copy_md_as_txt "$f" "$STAGING"; done
copy_md_as_txt "$ROOT/docs/database/MCD_Merise.md" "$STAGING"
copy_md_as_txt "$ROOT/docs/database/backup_restore.md" "$STAGING"
for f in "$ROOT/docs/project_management"/*.md; do copy_md_as_txt "$f" "$STAGING/08_Gestion_projet"; done

# Screenshots
cp -a "$ROOT/docs/architecture/screenshots/." "$STAGING/04_PoC_Reseau/"
cp "$ROOT/docs/project_management/screenshots/"*.png "$STAGING/08_Gestion_projet/" 2>/dev/null || true
cp "$ROOT/docs/project_management/screenshots/grafana_dashboard_poc.png" "$STAGING/06_PoC_Monitoring/" 2>/dev/null || true
cp "$ROOT/docs/project_management/screenshots/aci_room_booking_health.png" "$STAGING/05_PoC_Cloud/" 2>/dev/null || true
cp "$ROOT/docs/architecture/screenshots/grafana_loki_poc.png" "$STAGING/06_PoC_Monitoring/" 2>/dev/null || true
cp "$ROOT/docs/architecture/screenshots/backup_pg_dump_proof.png" "$STAGING/05_PoC_Cloud/" 2>/dev/null || true
cp "$ROOT/docs/architecture/screenshots/vpn_wireguard_ping_proof.png" "$STAGING/04_PoC_Reseau/" 2>/dev/null || true

# PDF optionnel
if command -v pandoc >/dev/null; then
  pandoc "$ROOT/docs/DAT.md" -o "$STAGING/01_DAT.pdf" 2>/dev/null || true
fi

python3 - "$STAGING" "$ZIP" <<'PY'
import sys, zipfile
from pathlib import Path
staging, zip_path = Path(sys.argv[1]), Path(sys.argv[2])
with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
    for f in staging.rglob("*"):
        if f.is_file():
            zf.write(f, f.relative_to(staging))
print(f"ZIP Moodle: {zip_path} ({zip_path.stat().st_size} bytes)")
PY
rm -rf "$STAGING"
