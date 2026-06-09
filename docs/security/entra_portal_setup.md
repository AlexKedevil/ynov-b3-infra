# Configuration Microsoft Entra ID — Guide pas à pas

Ce guide configure l'authentification pour **room-booking** (Smart Office 2.0).

---

## Prérequis

- Abonnement Azure for Students actif
- Accès [portal.azure.com](https://portal.azure.com) → **Microsoft Entra ID**

Notez dès le début :
- **Tenant ID** : Entra ID → Overview → Tenant ID
- Votre compte étudiant `@...` pour les tests

---

## Étape 1 — App Registration API (`room-booking-api`)

1. **Entra ID** → **App registrations** → **New registration**
2. Name : `room-booking-api`
3. Supported account types : **Single tenant**
4. Redirect URI : laisser vide → Register

5. Noter le **Application (client) ID** → `AZURE_CLIENT_ID`

6. **Expose an API** :
   - Set Application ID URI : `api://room-booking-api` (ou `api://<client-id>`)
   - Add a scope :
     - Scope name : `access_as_user`
     - Who can consent : Admins and users
     - Admin consent display name : `Access room-booking API`
   - Noter le scope complet : `api://room-booking-api/access_as_user`  
     → `AZURE_API_AUDIENCE=api://room-booking-api`

7. **App roles** → Create app role :
   - Display name : `Employee`, Value : `Employee`, Allowed member types : Users/Groups
   - Display name : `Admin`, Value : `Admin`, Allowed member types : Users/Groups

8. **API permissions** : rien de plus requis côté API

---

## Étape 2 — App Registration Client SPA (`room-booking-client`)

1. **New registration**
2. Name : `room-booking-client`
3. Single tenant
4. Redirect URI : **Single-page application (SPA)** :
   - `http://localhost:8080/static/login.html`
   - `http://ynov-smartoffice-b3.francecentral.azurecontainer.io:8080/static/login.html` (ACI public)

5. Noter le **Application (client) ID** → `AZURE_SPA_CLIENT_ID`

6. **API permissions** → Add permission → **My APIs** → `room-booking-api`
   - Cocher `access_as_user`
   - **Grant admin consent** (bouton bleu)

---

## Étape 3 — Assigner les rôles à votre compte

1. **Enterprise applications** → `room-booking-api`
2. **Users and groups** → Add user/group
3. Assigner votre compte avec le rôle **Admin** (pour créer des salles en démo)

---

## Étape 4 — MFA (Multi-Factor Authentication)

Option simple (démo) :
1. **Entra ID** → **Users** → votre utilisateur → **Per-user MFA**
2. Activer **Enforced** ou utiliser **Security** → **Multifactor authentication**

Option production (documenter dans le DAT) :
- **Conditional Access** : exiger MFA pour l'accès à `room-booking-api`

---

## Étape 5 — Variables d'environnement

Créer `cloud/room-booking/.env` (non commité, déjà dans `.gitignore` via secrets/) :

```bash
AZURE_TENANT_ID=votre-tenant-id
AZURE_CLIENT_ID=client-id-de-room-booking-api
AZURE_SPA_CLIENT_ID=client-id-de-room-booking-client
AZURE_API_AUDIENCE=api://room-booking-api
AUTH_DISABLED=false
```

Lancer :

```bash
cd cloud/room-booking
docker compose --env-file .env up --build
```

Ouvrir [http://localhost:8080/login](http://localhost:8080/login) → connexion Microsoft → copier le token.

---

## Étape 5b — Entra sur ACI (URL publique)

1. Vérifier les **redirect URI** SPA (étape 2) : localhost **et** FQDN ACI `:8080/static/login.html`.
2. GitHub → repo → **Settings** → **Secrets** → ajouter (valeurs du tenant de démo personnel) :
   - `AZURE_TENANT_ID`
   - `AZURE_CLIENT_ID` (API app)
   - `AZURE_SPA_CLIENT_ID` (SPA app)
   - `AZURE_API_AUDIENCE` (ex. `api://55dc0e92-...`)
3. Push sur `main` → workflow déploie ACI avec `AUTH_DISABLED=false` si les 4 secrets sont présents.

Déploiement manuel depuis `cloud/room-booking/.env` :

```bash
./infra/azure/deploy-aci.sh
```

Vérification :

```bash
curl http://ynov-smartoffice-b3.francecentral.azurecontainer.io:8080/health
# auth_disabled doit être false

curl http://ynov-smartoffice-b3.francecentral.azurecontainer.io:8080/rooms
# → 401 sans jeton

# Navigateur : .../login → Microsoft → curl /rooms avec Bearer
```

---

## Étape 6 — Tester l'API avec jeton

```bash
TOKEN="<access_token depuis la page login>"
curl http://localhost:8080/rooms -H "Authorization: Bearer $TOKEN"
```

Sans jeton (si `AUTH_DISABLED=false`) :

```bash
curl http://localhost:8080/rooms
# → 401 Unauthorized
```

---

## Dépannage

| Erreur | Solution |
|--------|----------|
| `AADSTS50011` redirect URI | Ajouter l'URI exact dans SPA registration |
| `invalid audience` | Vérifier `AZURE_API_AUDIENCE` = Application ID URI |
| `insufficient permissions` | Assigner rôle Admin/Employee dans Enterprise applications |
| `invalid token` | Token expiré — se reconnecter via /login |
