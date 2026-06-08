# Dossier d'Architecture Technique (DAT) — Smart Office 2.0

**Client :** Startup biotechnologie (50 → 200 employés, siège 4 étages, télétravail flexible)  
**Équipe :** Flaujat Sam, Queudeville Alexandre  
**Date :** 2026

> Document principal du projet. Les sections marquées *À compléter* seront remplies au fil des PR.

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

*À compléter : description des 4 étages, baie réseau, points d'accès Wi-Fi, lien FAI.*

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

*À compléter : matrice flux inter-VLAN, accès Internet, VPN télétravail.*

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

Le lab on-premise et Azure ne sont pas reliés physiquement en PoC étudiant ; l'architecture cible documente la liaison logique (VPN, HTTPS, Entra ID).

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

*À compléter : tableau comparatif On-Prem vs Azure (12 mois), hypothèses de coût.*

---

## 8. Politiques de sécurité et IAM

Voir [security/Zero_Trust_IAM.md](security/Zero_Trust_IAM.md) et [security/firewall_policies.md](security/firewall_policies.md).

---

## 9. Stratégie de stockage et sauvegarde

*À compléter : NAS on-prem, stockage objet (Azure Blob), politique de rétention.*

Voir aussi [database/backup_restore.md](database/backup_restore.md).

---

## 10. Services applicatifs et bases de données

- **Service :** room-booking (réservation de salles)
- **Code :** [cloud/room-booking/](../cloud/room-booking/)
- **Modèle données :** [database/MCD_Merise.md](database/MCD_Merise.md)

---

## 11. Supervision et détection

Voir [monitoring/README.md](../monitoring/README.md).

---

## 12. Continuité et reprise d'activité

Voir [pca_pra/BIA.md](pca_pra/BIA.md) et [pca_pra/PCA_PRA.md](pca_pra/PCA_PRA.md).
