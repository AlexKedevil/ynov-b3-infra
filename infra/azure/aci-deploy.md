# Déploiement Azure Container Instances (ACI)

**Région :** France Central  
**Resource group :** `rg-smartoffice`  
**ACR :** `smartofficeynov.azurecr.io`  
**URL publique :** `http://ynov-smartoffice-b3.francecentral.azurecontainer.io:8080`

---

## Architecture ACI

Groupe de conteneurs multi-container (réseau partagé `127.0.0.1`) :

| Conteneur | Image | Rôle |
|-----------|-------|------|
| room-booking | ACR `room-booking:latest` | API Flask |
| postgres | ACR `postgres:16-alpine` | SQL |
| redis | ACR `redis:7-alpine` | Cache NoSQL |

---

## Étape 1 — Service Principal pour GitHub Actions

1. Portail Azure → **Microsoft Entra ID** → **App registrations**  
   Si 401 (tenant Ynov) : utiliser **Cloud Shell** ou demander à l'admin.

   **Alternative via Cloud Shell** (portal.azure.com, icône `>_`) :

```bash
az login
az account set --subscription "Azure for Students"

az ad sp create-for-rbac \
  --name "github-smartoffice-deploy" \
  --role contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-smartoffice \
  --json-auth
```

2. Copier **tout le JSON** de sortie.

3. GitHub → repo `ynov-b3-infra` → **Settings** → **Secrets** → **New repository secret**
   - Name : `AZURE_CREDENTIALS`
   - Value : le JSON complet

---

## Étape 1b — Enregistrer le provider ACI (une fois)

Si le déploiement échoue avec `MissingSubscriptionRegistration` / `Microsoft.ContainerInstance` :

```bash
az account set --subscription "Azure for Students"
az provider register --namespace Microsoft.ContainerInstance --wait
```

Attendre l'état `Registered` (1–5 min), puis relancer le workflow GitHub.

---

## Étape 2 — Déploiement automatique (CI/CD)

Chaque push sur `main` :

1. Build image → push ACR
2. Deploy / update container group `smartoffice-booking`

Workflow : [.github/workflows/azure-deploy.yml](../../.github/workflows/azure-deploy.yml)

---

## Étape 3 — Vérification

```bash
curl http://ynov-smartoffice-b3.francecentral.azurecontainer.io:8080/health
curl http://ynov-smartoffice-b3.francecentral.azurecontainer.io:8080/rooms
```

---

## Déploiement manuel (fallback)

```bash
az login
export ACR_SERVER=smartofficeynov.azurecr.io
# Remplir cloud/room-booking/.env (Entra + AUTH_DISABLED=false)
chmod +x infra/azure/deploy-aci.sh
./infra/azure/deploy-aci.sh
```

---

## Économiser les crédits Student

```bash
# Arrêter le groupe quand pas de démo
az container stop --resource-group rg-smartoffice --name smartoffice-booking

# Relancer
az container start --resource-group rg-smartoffice --name smartoffice-booking
```

---

## Dépannage

| Problème | Solution |
|----------|----------|
| DNS label déjà pris | Changer `dnsNameLabel` dans `container-group.yaml` |
| Deploy job skipped | Ajouter secret `AZURE_CREDENTIALS` |
| `MissingSubscriptionRegistration` Microsoft.ContainerInstance | `az provider register --namespace Microsoft.ContainerInstance --wait` |
| `RegistryErrorResponse` index.docker.io | Images sidecar servies depuis ACR (voir workflow) |
| App 502 au démarrage | Attendre 30–60 s (postgres init) |
| Entra 401 tenant Ynov | Tenant personnel + secrets GitHub ou `deploy-aci.sh` + `.env` |
| `AADSTS50011` sur ACI | Redirect URI SPA : `http://<fqdn>:8080/static/login.html` |
| `/health` → `auth_disabled: true` | Secrets Entra manquants dans le workflow ou `AUTH_DISABLED=true` dans `.env` |
