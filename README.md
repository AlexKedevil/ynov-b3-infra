# Ynov B3 INFRA - Projet Smart Office 2.0

## Présentation du Projet

**Formation:** Ynov Informatique - Bachelor 3 Infrastructure Réseau  
**Sujet:** Smart Office 2.0 — Infrastructure Réseau Sécurisée  
**Équipe:** Flaujat Sam, Queudeville Alexandre  
**Période:** 2026  

### Contexte

Conception d'une infrastructure IT hybride pour une startup biotechnologie (50 → 200 employés, siège 4 étages, télétravail flexible).

**Index des livrables :** [docs/README.md](docs/README.md) · **Tableau Trello :** [b3-infra](https://trello.com/b/EXl0H0QS/b3-infra)

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
<col style="width:28%">
<col style="width:32%">
<col style="width:40%">
</colgroup>
<thead>
<tr><th>Accès</th><th>URL</th><th>Auth</th></tr>
</thead>
<tbody>
<tr>
<td><strong>ACI public</strong> (PoC cloud)</td>
<td>http://ynov-smartoffice-b3.francecentral.azurecontainer.io:8080</td>
<td><code>AUTH_DISABLED=true</code> (HTTP — Entra SPA exige HTTPS hors localhost)</td>
</tr>
<tr>
<td><strong>Local + Entra ID</strong><br>(démo&nbsp;IAM)</td>
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

Détails et scénario d'anomalie : [monitoring/README.md](monitoring/README.md)

---

## Contribution

1. `git checkout -b feature/nom-descriptif`
2. `git commit -m 'feat: description'`
3. `git push origin feature/nom-descriptif`
4. Ouvrir une Pull Request
