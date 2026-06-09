# Ynov B3 INFRA - Projet Smart Office 2.0

## Présentation du Projet

**Formation:** Ynov Informatique - Bachelor 3 Infrastructure Réseau  
**Sujet:** Smart Office 2.0 — Infrastructure Réseau Sécurisée  
**Équipe:** Flaujat Sam, Queudeville Alexandre  
**Période:** 2026  

### Contexte

Conception d'une infrastructure IT hybride pour une startup biotechnologie (50 → 200 employés, siège 4 étages, télétravail flexible).

**Documentation complète :** [ci-dessous](#documentation) · **Tableau Trello :** [b3-infra](https://trello.com/b/EXl0H0QS/b3-infra)

---

## Structure du Dépôt

```text
ynov-b3-infra/
├── cloud/
│   └── room-booking/         # PoC réservation de salles (Flask, PostgreSQL, Redis)
├── docs/                     # Tous les livrables UF_INFRA_B3
│   ├── README.md             # Index et statut des documents
│   ├── DAT.md                # Dossier d'Architecture Technique
│   ├── architecture/         # Schémas, IP/VLAN, screenshots PoC
│   ├── security/             # Zero Trust, IAM Entra, firewall
│   ├── database/             # Merise, backup/restore
│   ├── pca_pra/              # BIA, PCA, PRA
│   └── project_management/   # ITSM, backlog, captures Trello
├── infra/
│   ├── network/              # pfSense, VMware, WireGuard, syslog
│   └── azure/                # ACI, container-group, déploiement
├── monitoring/               # Grafana, Loki, Promtail, health-prober
└── .github/workflows/        # azure-deploy.yml → ACR → ACI
```

---

## Architecture hybride

![Architecture hybride — on-prem VMware + Azure](docs/architecture/screenshots/smart_office_hybrid_azure.png)

On-prem (pfSense, VLANs, WireGuard, Grafana/Loki) + Azure France Central (ACI, ACR, Entra ID) + CI/CD GitHub Actions.

Description détaillée : [docs/DAT.md §5](docs/DAT.md#5-architecture-hybride-on-premise--cloud)

---

## Architecture Réseau (VLANs)

![Schéma Logique du Réseau](docs/architecture/screenshots/network_diagram.png)

- [Plan d'Adressage IP & VLAN](docs/architecture/Plan_Adressage_IP_VLAN.md)
- [Installation pfSense](infra/network/pfsense_initial_setup.md)
- [Configuration VLANs](infra/network/pfsense_vlan_config.md)
- [VMware vmnet2](infra/network/vmware_vmnet2_config.md)
- [VPN WireGuard — VLAN20/50](infra/network/pfsense_wireguard_vpn.md)

---

## Stack Technique

| Catégorie | Outils |
|-----------|--------|
| **Réseau** | pfSense 2.7+, 6 VLANs 802.1Q, 10.20.0.0/16 |
| **Virtualisation** | VMware Workstation |
| **Cloud** | Azure France Central — ACR `smartofficeynov`, ACI déployé |
| **IAM** | Microsoft Entra ID (JWT + MSAL ; démo **locale** `localhost:8080/login`) |
| **App** | Docker, Flask, PostgreSQL, Redis |
| **CI/CD** | GitHub Actions → ACR |
| **Monitoring** | Grafana, Loki, Promtail |

---

## Room Booking Service

PoC cloud — réservation de salles (API complète, déployée sur ACI).

<table>
<colgroup>
<col style="width:32%">
<col style="width:30%">
<col style="width:38%">
</colgroup>
<thead>
<tr><th>Accès</th><th>URL</th><th>Auth</th></tr>
</thead>
<tbody>
<tr>
<td><span style="white-space:nowrap"><strong>ACI&nbsp;public</strong></span><br>(PoC&nbsp;cloud)</td>
<td>http://ynov-smartoffice-b3.francecentral.azurecontainer.io:8080</td>
<td><code>AUTH_DISABLED=true</code> (HTTP — Entra SPA exige HTTPS hors localhost)</td>
</tr>
<tr>
<td><span style="white-space:nowrap"><strong>Local&nbsp;+&nbsp;Entra&nbsp;ID</strong></span><br>(démo&nbsp;IAM)</td>
<td>http://localhost:8080/login</td>
<td>JWT Microsoft (tenant dev personnel)</td>
</tr>
</tbody>
</table>

```bash
cd cloud/room-booking
docker compose --env-file .env up --build   # Entra : docs/security/entra_portal_setup.md
curl http://localhost:8080/health
curl http://ynov-smartoffice-b3.francecentral.azurecontainer.io:8080/health
```

Détails : [cloud/room-booking/DETAILS.md](cloud/room-booking/DETAILS.md)

**Pipeline :** `GitHub → ACR → ACI` (cloud) · Entra ID démontré en local

---

## Monitoring (PoC local)

```bash
cd monitoring && docker compose up -d
# Grafana http://localhost:3000 — admin / smartoffice
```

Détails : [monitoring/README.md](monitoring/README.md) · [Scénario d'anomalie](monitoring/anomaly-scenario.md)

---

## Documentation

Index des livrables UF_INFRA_B3 (statut **Fait**) : [docs/README.md](docs/README.md)

### Architecture & DAT

<table>
<colgroup>
<col style="width:38%">
<col style="width:62%">
</colgroup>
<thead>
<tr><th>Document</th><th>Description</th></tr>
</thead>
<tbody>
<tr><td><a href="docs/DAT.md">DAT.md</a></td><td>Dossier d'Architecture Technique (document principal)</td></tr>
<tr><td><a href="docs/architecture/Plan_Adressage_IP_VLAN.md">Plan d'adressage IP & VLAN</a></td><td>Segmentation <code>10.20.0.0/16</code>, 6 VLANs</td></tr>
<tr><td><a href="docs/architecture/screenshots/">Captures PoC réseau & cloud</a></td><td>Schémas PNG, Grafana, VPN, backup, ACI</td></tr>
<tr><td><a href="docs/architecture/EDITING.md">Édition schéma SVG</a></td><td>Guide mise à jour du diagramme hybride</td></tr>
</tbody>
</table>

### Sécurité & IAM

<table>
<colgroup>
<col style="width:38%">
<col style="width:62%">
</colgroup>
<thead>
<tr><th>Document</th><th>Description</th></tr>
</thead>
<tbody>
<tr><td><a href="docs/security/Zero_Trust_IAM.md">Zero Trust & IAM</a></td><td>Modèle Zero Trust, rôles, MFA</td></tr>
<tr><td><a href="docs/security/entra_portal_setup.md">Configuration Entra ID</a></td><td>Portail Azure, MSAL, JWT, démo locale</td></tr>
<tr><td><a href="docs/security/firewall_policies.md">Politiques firewall</a></td><td>Règles pfSense inter-VLAN et WAN</td></tr>
</tbody>
</table>

### Base de données & continuité

<table>
<colgroup>
<col style="width:38%">
<col style="width:62%">
</colgroup>
<thead>
<tr><th>Document</th><th>Description</th></tr>
</thead>
<tbody>
<tr><td><a href="docs/database/MCD_Merise.md">MCD Merise</a></td><td>Modèle conceptuel room-booking</td></tr>
<tr><td><a href="docs/database/backup_restore.md">Backup & restore</a></td><td><code>pg_dump</code>, procédure de restauration</td></tr>
<tr><td><a href="docs/pca_pra/BIA.md">BIA</a></td><td>Analyse d'impact métier</td></tr>
<tr><td><a href="docs/pca_pra/PCA_PRA.md">PCA / PRA</a></td><td>Continuité et reprise d'activité</td></tr>
</tbody>
</table>

### Gestion de projet

<table>
<colgroup>
<col style="width:38%">
<col style="width:62%">
</colgroup>
<thead>
<tr><th>Document</th><th>Description</th></tr>
</thead>
<tbody>
<tr><td><a href="docs/project_management/ITSM.md">ITSM</a></td><td>Gestion des incidents</td></tr>
<tr><td><a href="docs/project_management/backlog_sprints.md">Backlog & sprints</a></td><td>Méthodologie agile, user stories</td></tr>
<tr><td><a href="docs/project_management/screenshots/">Captures Trello</a></td><td>Screenshots du tableau b3-infra</td></tr>
<tr><td><a href="https://trello.com/b/EXl0H0QS/b3-infra">Trello b3-infra</a></td><td>Board Kanban (lien externe)</td></tr>
</tbody>
</table>

### Réseau on-premise

<table>
<colgroup>
<col style="width:38%">
<col style="width:62%">
</colgroup>
<thead>
<tr><th>Document</th><th>Description</th></tr>
</thead>
<tbody>
<tr><td><a href="infra/network/pfsense_initial_setup.md">Installation pfSense</a></td><td>Première configuration</td></tr>
<tr><td><a href="infra/network/pfsense_vlan_config.md">Configuration VLANs</a></td><td>802.1Q, interfaces, règles</td></tr>
<tr><td><a href="infra/network/vmware_vmnet2_config.md">VMware vmnet2</a></td><td>Lab LAN <code>10.20.0.0/16</code></td></tr>
<tr><td><a href="infra/network/pfsense_wireguard_vpn.md">VPN WireGuard</a></td><td>Accès VLAN20/50 à distance</td></tr>
<tr><td><a href="infra/network/pfsense_syslog_loki.md">pfSense → Loki</a></td><td>Syslog vers monitoring</td></tr>
</tbody>
</table>

### Cloud & déploiement

<table>
<colgroup>
<col style="width:38%">
<col style="width:62%">
</colgroup>
<thead>
<tr><th>Document</th><th>Description</th></tr>
</thead>
<tbody>
<tr><td><a href="cloud/room-booking/DETAILS.md">Room-booking — détails</a></td><td>API, stack, endpoints, tests</td></tr>
<tr><td><a href="infra/azure/aci-deploy.md">Déploiement Azure ACI</a></td><td>ACR, container group, pipeline</td></tr>
</tbody>
</table>

### Monitoring

<table>
<colgroup>
<col style="width:38%">
<col style="width:62%">
</colgroup>
<thead>
<tr><th>Document</th><th>Description</th></tr>
</thead>
<tbody>
<tr><td><a href="monitoring/README.md">Stack Grafana / Loki</a></td><td>Déploiement, dashboard, health-prober</td></tr>
<tr><td><a href="monitoring/anomaly-scenario.md">Scénario d'anomalie</a></td><td>Détection incident PoC</td></tr>
</tbody>
</table>

---

## Contribution

1. `git checkout -b feature/nom-descriptif`
2. `git commit -m 'feat: description'`
3. `git push origin feature/nom-descriptif`
4. Ouvrir une Pull Request
