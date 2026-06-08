# Guide — Reconstruire le board Trello « b3-infra »

> Aligné sur le dépôt **ynov-b3-infra** et le sujet **Smart Office 2.0** (UF_INFRA_B3).  
> Board : [trello.com/b/EXl0H0QS/b3-infra](https://trello.com/b/EXl0H0QS/b3-infra)

L’ancien board mélangeait AWS, Wazuh, MongoDB, VMs Ubuntu AD — **ce n’est pas notre stack**.  
Stack réelle : **pfSense + VMware**, **Azure ACR/ACI**, **Entra ID**, **PostgreSQL + Redis**, **Grafana/Loki**.

---

## Étape 0 — Nettoyer le board

1. **Archiver ou supprimer** les cartes obsolètes :
   - Cloud & DevOps (AWS S3, EC2…)
   - Monitoring (Prometheus, Wazuh…)
   - Systèmes & Services (Ubuntu AD, MongoDB logs…)
   - Load Balancing HAProxy (hors scope PoC)

2. **Renommer les colonnes** (glisser-déposer) :

| Ancienne colonne | Nouvelle colonne |
|------------------|------------------|
| Backlog | **Backlog** (optionnel / hors scope) |
| En cours | **En cours** |
| Fait | **Fait** |

Optionnel : ajouter **En review** entre En cours et Fait (pour les PR GitHub).

---

## Étape 1 — Colonne **Fait** (6 cartes)

Créer ces cartes et **cocher toutes les cases** des checklists.

### Carte 1 : Réseau & pfSense (VMware)

**Labels :** `réseau`, `fait`  
**Membres :** Sam, Alexandre

Checklist :
- [x] Installer pfSense VMware (WAN + LAN vmnet2)
- [x] LAN 10.20.0.1 — hôte 10.20.0.254
- [x] Créer VLANs 10, 20, 30, 40, 50, 60
- [x] Règles firewall par VLAN (captures)
- [x] Plan IP/VLAN 10.20.0.0/16 documenté
- [x] Schéma réseau (Draw.io + PNG)
- [x] Syslog pfSense → Loki (10.20.0.254:1514)

**Liens :** `infra/network/`, `docs/architecture/screenshots/`

---

### Carte 2 : Cloud Azure — room-booking

**Labels :** `cloud`, `fait`

Checklist :
- [x] App Flask room-booking (API CRUD salles/réservations)
- [x] PostgreSQL + Redis (Docker Compose)
- [x] ACR `smartofficeynov.azurecr.io`
- [x] ACI multi-container déployé (France Central)
- [x] URL publique `/health` et `/rooms` OK
- [x] GitHub Actions build + push ACR + deploy ACI

**Liens :** `cloud/room-booking/`, `.github/workflows/azure-deploy.yml`  
**URL :** http://ynov-smartoffice-b3.francecentral.azurecontainer.io:8080

---

### Carte 3 : IAM — Microsoft Entra ID

**Labels :** `sécurité`, `fait`

Checklist :
- [x] JWT validation + décorateurs `require_auth`
- [x] Page login MSAL + endpoint `/auth/config`
- [x] Zero Trust IAM documenté
- [x] Mode démo `AUTH_DISABLED=true` (limitation tenant Ynov)
- [x] Service Principal GitHub → Azure (AZURE_CREDENTIALS)

**Liens :** `docs/security/`, `cloud/room-booking/src/auth.py`

---

### Carte 4 : Monitoring — Grafana / Loki

**Labels :** `monitoring`, `fait`

Checklist :
- [x] Stack Docker : Grafana + Loki + Promtail + syslog-ng
- [x] Dashboard « Smart Office — Logs & Anomalies »
- [x] Logs pfSense VM (réel) dans Grafana
- [x] Script `simulate-anomaly.sh` (erreurs API)
- [x] Scénario documenté (`anomaly-scenario.md`)

**Liens :** `monitoring/`, `infra/network/pfsense_syslog_loki.md`

---

### Carte 5 : Documentation technique (DAT)

**Labels :** `docs`, `fait`

Checklist :
- [x] DAT complet (architecture, flux, TCO, stockage)
- [x] BIA + PCA/PRA
- [x] Merise / MCD room-booking
- [x] Backup/restore PostgreSQL
- [x] Politiques firewall + Zero Trust
- [x] README dépôt à jour

**Liens :** `docs/DAT.md`, `docs/pca_pra/`, `docs/database/`

---

### Carte 6 : CI/CD & Git (PRs)

**Labels :** `devops`, `fait`

Checklist :
- [x] PR #12 — docs prep
- [x] PR #13 — room-booking app
- [x] PR #14 — Entra ID auth
- [x] PR #15 — Azure ACI deploy
- [x] PR #16–#18 — fixes workflow / ACI / ACR images
- [x] PR monitoring stack
- [x] PR pfSense syslog → Loki
- [x] PR DAT / PCA / Merise

**Lien :** https://github.com/AlexKedevil/ynov-b3-infra/pulls

---

## Étape 2 — Colonne **En cours** (1 carte)

### Carte : Livrable Moodle & soutenance

**Labels :** `docs`, `en-cours`

Checklist :
- [ ] Captures Trello → `docs/project_management/screenshots/`
- [ ] Captures Grafana + ACI → dossier livrable
- [ ] Export PDF DAT + PCA + sécurité
- [ ] ZIP Moodle avant 18/06/2026
- [ ] Préparation oral (hors git)

---

## Étape 3 — Colonne **Backlog** (hors scope PoC — optionnel)

Cartes « cible production » — **ne pas cocher** (montre la roadmap) :

| Carte | 1–2 items checklist |
|-------|---------------------|
| **VPN site-to-site Azure** | IPsec pfSense ↔ VNet ; Test bascule |
| **Entra ID production** | App registration admin Ynov ; MFA obligatoire |
| **Haute dispo room-booking** | AKS ou 2× ACI ; Load balancer |
| **SIEM avancé** | Alerting Grafana → Teams ; Rétention logs 90 j |

---

## Étape 4 — Labels Trello recommandés

| Couleur | Label |
|---------|-------|
| Vert | `fait` |
| Bleu | `réseau` |
| Violet | `cloud` |
| Rouge | `sécurité` |
| Orange | `monitoring` |
| Jaune | `docs` |
| Gris | `hors-scope` |

---

## Étape 5 — Captures pour le livrable

Après reconstruction, faire **2 screenshots** :

1. **Vue complète** — colonnes Fait remplies + En cours (Moodle)
2. **Zoom carte** — ex. « Monitoring » avec checklist cochée

Enregistrer dans :
```text
docs/project_management/screenshots/trello_board_overview.png
docs/project_management/screenshots/trello_card_monitoring.png
```

Puis commit dans la PR `feature/project-management-docs`.

---

## Résumé visuel cible

```text
┌─────────────┬──────────────┬──────────────────────────────────────┐
│  Backlog    │  En cours    │  Fait (6 cartes, tout coché)         │
│  (4 cartes  │  Moodle      │  Réseau | Cloud | IAM | Monitoring   │
│   option)   │  export      │  DAT | CI/CD                         │
└─────────────┴──────────────┴──────────────────────────────────────┘
```

Temps estimé : **20–30 min** dans l’UI Trello.
