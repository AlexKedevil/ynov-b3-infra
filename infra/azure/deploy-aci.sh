#!/usr/bin/env bash
# Déploie smartoffice-booking sur ACI avec variables Entra depuis cloud/room-booking/.env
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT/cloud/room-booking/.env}"
MANIFEST="$ROOT/infra/azure/container-group.yaml"
OUT="/tmp/smartoffice-container-group.yaml"
RG="${AZURE_RESOURCE_GROUP:-rg-smartoffice}"
NAME="${ACI_CONTAINER_GROUP:-smartoffice-booking}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE — copy .env.example and configure Entra IDs" >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a && source "$ENV_FILE" && set +a

: "${ACR_SERVER:?Set ACR_SERVER or login: az acr list -o table}"
ACR_USER="${ACR_USER:-$(az acr credential show --name "${ACR_SERVER%%.*}" --query username -o tsv)}"
ACR_PASS="${ACR_PASS:-$(az acr credential show --name "${ACR_SERVER%%.*}" --query passwords[0].value -o tsv)}"

if [[ -n "${AZURE_TENANT_ID:-}" && -n "${AZURE_CLIENT_ID:-}" && \
      -n "${AZURE_SPA_CLIENT_ID:-}" && -n "${AZURE_API_AUDIENCE:-}" && \
      "${AUTH_DISABLED:-true}" == "false" ]]; then
  AUTH_DISABLED=false
  echo "Entra enabled on ACI (AUTH_DISABLED=false)"
else
  AUTH_DISABLED=true
  echo "Entra not fully configured — AUTH_DISABLED=true"
fi

sed -e "s|{{ACR_SERVER}}|$ACR_SERVER|g" \
    -e "s|{{ACR_USER}}|$ACR_USER|g" \
    -e "s|{{ACR_PASS}}|$ACR_PASS|g" \
    -e "s|{{AUTH_DISABLED}}|$AUTH_DISABLED|g" \
    -e "s|{{AZURE_TENANT_ID}}|${AZURE_TENANT_ID:-}|g" \
    -e "s|{{AZURE_CLIENT_ID}}|${AZURE_CLIENT_ID:-}|g" \
    -e "s|{{AZURE_SPA_CLIENT_ID}}|${AZURE_SPA_CLIENT_ID:-}|g" \
    -e "s|{{AZURE_API_AUDIENCE}}|${AZURE_API_AUDIENCE:-}|g" \
    "$MANIFEST" > "$OUT"

az account set --subscription "${AZURE_SUBSCRIPTION:-Azure for Students}" 2>/dev/null || true
az container show --resource-group "$RG" --name "$NAME" &>/dev/null \
  && az container delete --resource-group "$RG" --name "$NAME" --yes

az container create --resource-group "$RG" --file "$OUT"
FQDN=$(az container show --resource-group "$RG" --name "$NAME" --query ipAddress.fqdn -o tsv)
echo "ACI: http://${FQDN}:8080/health"
echo "Login: http://${FQDN}:8080/login"
