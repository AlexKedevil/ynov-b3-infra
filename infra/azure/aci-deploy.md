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
| postgres | `postgres:16-alpine` | SQL |
| redis | `redis:7-alpine` | Cache NoSQL |

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
az account set --subscription "Azure for Students"

export ACR_SERVER=smartofficeynov.azurecr.io
export ACR_USER=<admin-user-acr>
export ACR_PASS=<admin-password-acr>

sed -e "s|{{ACR_SERVER}}|$ACR_SERVER|g" \
    -e "s|{{ACR_USER}}|$ACR_USER|g" \
    -e "s|{{ACR_PASS}}|$ACR_PASS|g" \
    infra/azure/container-group.yaml > /tmp/cg.yaml

az container delete --resource-group rg-smartoffice --name smartoffice-booking --yes
az container create --resource-group rg-smartoffice --file /tmp/cg.yaml
az container show --resource-group rg-smartoffice --name smartoffice-booking \
  --query ipAddress.fqdn -o tsv
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
| App 502 au démarrage | Attendre 30–60 s (postgres init) |
| Entra 401 tenant Ynov | `AUTH_DISABLED=true` dans le manifeste ACI |
