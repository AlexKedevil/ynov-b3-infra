# Dossier d'Architecture Technique (DAT) — Smart Office 2.0

**Client :** Startup biotechnologie (50 → 200 employés, siège 4 étages, télétravail flexible)  
**Équipe :** Flaujat Sam, Queudeville Alexandre  
**Date :** 2026

> Document principal du projet — Smart Office 2.0 (2026).

---

## Table des matières

1. [Contexte et objectifs](#1-contexte-et-objectifs)
2. [Architecture physique](#2-architecture-physique)
3. [Architecture logique et réseau](#3-architecture-logique-et-réseau)
4. [Flux réseau](#4-flux-réseau)
5. [Architecture hybride On-Premise / Cloud](#5-architecture-hybride-on-premise--cloud)
6. [Choix technologiques et justification](#6-choix-technologiques-et-justification)
7. [Analyse comparative Cloud et TCO](#7-analyse-comparative-cloud-et-tco)
8. [Politiques de sécurité et IAM](#8-politiques-de-sécurité-et-iam)
9. [Stratégie de stockage et sauvegarde](#9-stratégie-de-stockage-et-sauvegarde)
10. [Services applicatifs et bases de données](#10-services-applicatifs-et-bases-de-données)
11. [Supervision et détection](#11-supervision-et-détection)
12. [Continuité et reprise d'activité](#12-continuité-et-reprise-dactivité)

---

## 1. Contexte et objectifs

Smart Office 2.0 couvre la conception d'une infrastructure IT hybride pour un siège social en croissance rapide. Les objectifs :

- Réseau segmenté, scalable et résilient (LAN, WLAN, WAN)
- Sécurité Zero Trust avec gestion des identités
- Service métier conteneurisé (réservation de salles) sur Azure
- Supervision et détection d'anomalies
- Documentation professionnelle conforme aux bonnes pratiques

---

## 2. Architecture physique

### Siège social (4 étages)

| Étage | Usage | Équipements réseau |
|-------|-------|-------------------|
| RDC | Accueil, Wi-Fi invités | 2 AP Wi-Fi (VLAN 40) |
| 1er | Open space + salles réunion | 2 AP (VLAN 20/30), switch accès |
| 2e | Bureaux R&D | 2 AP, switch accès |
| 3e | Direction + salle serveur | Baie 12U, switch core, NAS, serveur VMware |

### Baie réseau (étage 3)

- **Firewall :** pfSense (VM en production cible ; VM VMware en lab)
- **Switch manageable :** VLANs 802.1Q trunk vers pfSense
- **NAS :** sauvegardes pfSense XML, dumps PostgreSQL, rétention 30 jours
- **Serveur virtualisation :** VMware — pfSense, Ubuntu (services internes)

### Connectivité WAN

- Lien FAI fibre pro (symétrique cible 500 Mbps)
- Routeur FAI en mode bridge → pfSense WAN (VLAN 99 / DHCP)
- Lien secours 4G (objectif PCA) — non déployé en PoC étudiant

---

## 3. Architecture logique et réseau

### Plan d'adressage et VLANs

Voir [architecture/Plan_Adressage_IP_VLAN.md](architecture/Plan_Adressage_IP_VLAN.md).

| VLAN | Nom | Sous-réseau | Rôle |
|------|-----|-------------|------|
| 10 | MGMT | 10.20.10.0/24 | Gestion équipements |
| 20 | USERS | 10.20.20.0/24 | Utilisateurs bureau |
| 30 | WIFI_STAFF | 10.20.30.0/24 | Wi-Fi personnel |
| 40 | WIFI_INVITES | 10.20.40.0/24 | Wi-Fi invités (isolé) |
| 50 | SERVEURS | 10.20.50.0/24 | Serveurs internes |
| 60 | DMZ | 10.20.60.0/24 | Services exposés |

### Schémas

- Schéma logique : [architecture/screenshots/network_diagram.png](architecture/screenshots/network_diagram.png)
- Source Draw.io : [architecture/network diagram.xml](architecture/network%20diagram.xml)

### Preuves lab (pfSense + VMware)

Captures dans [architecture/screenshots/](architecture/screenshots/).

---

## 4. Flux réseau

### Matrice inter-VLAN (résumé)

| Source → Destination | Autorisé | Protocole / remarque |
|---------------------|----------|----------------------|
| USERS (20) → SERVEURS (50) | Oui | HTTPS, LDAP, DNS |
| USERS (20) → DMZ (60) | Oui | HTTPS (reverse proxy) |
| USERS (20) → Internet | Oui | HTTP/S, DNS |
| WIFI_STAFF (30) → USERS (20) | Oui | Même politique que bureau |
| WIFI_INVITES (40) → LAN | **Non** | Isolation totale |
| WIFI_INVITES (40) → Internet | Oui | DNS, HTTP/S |
| MGMT (10) → tous VLANs | Oui | SSH, HTTPS admin (admins) |
| DMZ (60) → SERVEURS (50) | Limité | BDD via ports définis |
| Tout → MGMT (10) | Restreint | Admins uniquement |

Détail et captures : [security/firewall_policies.md](security/firewall_policies.md).

### Accès Internet

```text
Poste utilisateur → Switch VLAN → pfSense LAN → NAT → WAN (FAI) → Internet
```

Filtrage : pfSense (pfBlockerNG cible), DNS filtré, logs firewall → Loki.

### Télétravail (cible)

```text
Employé → WireGuard (pfSense, 10.20.100.0/24) → VLAN 20 USERS + VLAN 50 SERVEURS
Employé → HTTPS → room-booking (ACI Azure) + Entra ID
```

Guide lab : [infra/network/pfsense_wireguard_vpn.md](../infra/network/pfsense_wireguard_vpn.md).

VPN site-to-site IPsec vers Azure (VNet) documenté en §5 — non câblé en lab VMware.

---

## 5. Architecture hybride On-Premise / Cloud

```text
[On-Premise — lab VMware]
  pfSense (VLANs, firewall, VPN)
  Ubuntu Server (VLAN SERVEURS)

[Cloud — Azure France Central]
  ACR smartofficeynov
  ACI room-booking
  Microsoft Entra ID (IAM)
```

**PoC étudiant :** le lab VMware (pfSense `10.20.0.0/16`) et Azure France Central ne sont pas reliés par VPN. Les utilisateurs accèdent au cloud via **HTTPS public** (ACI) et à l'IAM via **Entra ID**.

**Architecture cible production :**

```text
[Site Paris — On-Prem]
  pfSense ──IPsec VPN──► Azure Virtual Network Gateway
  VLAN SERVEURS ──► AD/DNS, NAS backup

[Azure France Central]
  ACI room-booking (ou AKS cible)
  ACR smartofficeynov
  Entra ID (SSO, MFA, RBAC)
  Azure Blob (sauvegardes PostgreSQL)
```

| Liaison | Protocole | Rôle |
|---------|-----------|------|
| Utilisateur → cloud | HTTPS + JWT Entra | Accès room-booking |
| Site → Azure | IPsec IKEv2 | Réplication sauvegardes, admin |
| pfSense → monitoring | Syslog UDP | Logs firewall → Grafana/Loki |
| CI/CD | GitHub Actions | Build ACR, deploy ACI |

Voir [infra/network/pfsense_syslog_loki.md](../infra/network/pfsense_syslog_loki.md) pour le syslog pfSense réel vers Loki.

---

## 6. Choix technologiques et justification

| Composant | Choix | Justification |
|-----------|-------|---------------|
| Firewall | pfSense 2.7+ | Open-source, VLANs, VPN, filtrage |
| Virtualisation | VMware Workstation | PoC réseau, snapshots |
| Cloud | Azure for Students | ACR, ACI, Entra ID, crédit étudiant |
| Conteneurisation | Docker | Portabilité, CI/CD |
| CI/CD | GitHub Actions | Intégration dépôt, push ACR |
| BDD SQL | PostgreSQL | Réservations, intégrité relationnelle |
| BDD NoSQL | Redis | Cache disponibilité, sessions |

---

## 7. Analyse comparative Cloud et TCO

Estimation **12 mois** — startup 50 employés, 1 service cloud (room-booking).

### Hypothèses

| Poste | On-Prem | Azure (France Central) |
|-------|---------|------------------------|
| Hébergement room-booking | VM + licence (≈ 2 vCPU, 4 GB) | ACI 1,5 CPU / 2 GB, 24/7 |
| Registry images | N/A | ACR Basic |
| IAM | AD + licences | Entra ID P1 (cible) |
| Monitoring | Grafana auto-hébergé | Grafana Cloud (option) |
| Crédit étudiant | — | Azure for Students (~100 USD) |

### TCO simplifié (ordre de grandeur)

| Composant | On-Prem / an | Azure / an | Retenu PoC |
|-----------|--------------|------------|------------|
| Compute room-booking | 1 200 € (VM) | 180 € (ACI arrêté hors démo) | **Azure ACI** |
| Stockage sauvegardes | 400 € (NAS) | 60 € (Blob 100 GB) | Hybride |
| Firewall | 0 € (pfSense OSS) | — | **On-Prem** |
| CI/CD | 0 € (GitHub Free) | inclus | **GitHub Actions** |
| **Total estimé** | **≈ 1 600 €** | **≈ 240 €** (+ crédit étudiant) | **Hybride** |

### Justification du choix hybride

- **On-Prem :** réseau, sécurité périmétrique, données sensibles R&D, latence bureau
- **Azure :** élasticité, CI/CD, service métier exposé, pas de CAPEX serveur cloud
- **Économie PoC :** `az container stop` hors démonstrations pour préserver le crédit Student

---

## 8. Politiques de sécurité et IAM

Voir [security/Zero_Trust_IAM.md](security/Zero_Trust_IAM.md) et [security/firewall_policies.md](security/firewall_policies.md).

---

## 9. Stratégie de stockage et sauvegarde

| Donnée | Stockage primaire | Sauvegarde | Rétention |
|--------|-------------------|------------|-----------|
| Réservations (PostgreSQL) | ACI / Docker volume | `pg_dump` quotidien | 30 jours |
| Cache Redis | Mémoire ACI | Non persisté (reconstruit) | — |
| Config pfSense | VM VMware | Export XML hebdo → NAS | 12 semaines |
| Images Docker | ACR | Tags `latest` + SHA Git | Illimité (Git) |
| Logs supervision | Loki (local) | Rotation 7 jours | 7 jours |
| Documentation | GitHub | Git + export Moodle | Illimité |

Procédures : [database/backup_restore.md](database/backup_restore.md).

---

## 10. Services applicatifs et bases de données

- **Service :** room-booking (réservation de salles)
- **Code :** [cloud/room-booking/](../cloud/room-booking/)
- **Modèle données :** [database/MCD_Merise.md](database/MCD_Merise.md)

---

## 11. Supervision et détection

Stack PoC : **Grafana + Loki + Promtail + syslog-ng**.

| Source | Collecte | Anomalie détectée |
|--------|----------|-------------------|
| pfSense VM (réel) | Syslog UDP `10.20.0.254:1514` | Blocages firewall (`filterlog`) |
| room-booking | Logs Docker via Promtail | Pics HTTP 4xx/5xx |
| pfSense (fallback) | Simulateur Docker `--profile simulator` | Port scan simulé |

- Dashboard : *Smart Office — Logs & Anomalies*
- Scénario : [monitoring/anomaly-scenario.md](../monitoring/anomaly-scenario.md)
- Configuration pfSense : [infra/network/pfsense_syslog_loki.md](../infra/network/pfsense_syslog_loki.md)

Chaîne incident : détection Grafana → analyse ITSM → action PCA/PRA ([project_management/ITSM.md](project_management/ITSM.md)).

---

## 12. Continuité et reprise d'activité

Voir [pca_pra/BIA.md](pca_pra/BIA.md) et [pca_pra/PCA_PRA.md](pca_pra/PCA_PRA.md).
