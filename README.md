# 🎓 Ynov B3 INFRA - Projet Smart Office 2.0

## 📋 Présentation du Projet

**Formation:** Ynov Informatique - Bachelor 3 Infrastructure Réseau  
**Sujet:** Smart Office 2.0 — Infrastructure Réseau Sécurisée  
**Équipe:** Flaujat Sam, Queudeville Alexandre  
**Période:** 2026  

### 🎯 Contexte Pédagogique

Ce projet simule la conception d'une infrastructure IT hybride pour une startup française en hyper-croissance (50 → 200 employés) emménageant dans un nouveau siège de 4 étages.

**Objectifs pédagogiques:**
- ✅ Architecture réseau: VLANs, routage inter-VLAN, DHCP, NAT
- ✅ Sécurité: Zero Trust, pfSense firewall, isolation GUEST
- ✅ Virtualisation: VMware + Ubuntu Server
- ✅ DevOps: Containerisation Docker, CI/CD avec GitHub Actions
- ✅ Cloud hybride: Documentation de déploiement Azure (ACI)
- ✅ Gestion de projet: Agile, Git, Trello, documentation collaborative

> 📊 **Tableau de Bord Trello:** [b3-infra | Trello](https://trello.com/b/EXl0H0QS/b3-infra)

---

## 📁 Structure du Dépôt

```text
ynov-b3-infra/
├── cloud/                    # Services cloud (IaaS/PaaS)
│   └── room-booking/         # Service de réservation de salles (PoC)
│       ├── Dockerfile        # Configuration Docker
│       ├── docker-compose.yml # Orchestration locale
│       └── src/app.py        # Application Python
│
├── docs/                     # Documentation technique (DAT)
│   ├── architecture/         # Schémas, plan d'adressage IP/VLAN
│   │   ├── Plan_Adressage_IP_VLAN.md
│   │   ├── network diagram.xml
│   │   └── screenshots/      # Captures pfSense, tests réseau
│   ├── pca_pra/              # Plans de continuité/reprise
│   ├── procedures/           # Guides d'installation
│   ├── project_management/   # Backlog, sprints, Kanban
│   └── security/             # Politiques firewall, Zero Trust
│
├── infra/                    # Configuration infrastructure on-premise
│   ├── network/              # pfSense, VLANs, VMware
│   │   ├── pfsense_initial_setup.md
│   │   ├── pfsense_wizard_config.md
│   │   ├── pfsense_vlan_config.md
│   │   └── vmware_vmnet2_config.md
│   └── servers/              # Scripts Ubuntu (à venir)
│
├── monitoring/               # Supervision (prévu pour final)
│   ├── grafana/              # Dashboards
│   └── wazuh/                # Règles SIEM
│
├── .gitignore
└── README.md
```

---

## 🗺️ Architecture Réseau

![Schéma Logique du Réseau](docs/architecture/screenshots/network_diagram.png)

> 🔗 **Documents de référence :**
> - [📜 Plan d'Adressage IP & Politique VLAN](docs/architecture/Plan_Adressage_IP_VLAN.md)
> - [🚀 Installation Initiale pfSense](infra/network/pfsense_initial_setup.md)
> - [⚙️ Configuration Wizard pfSense](infra/network/pfsense_wizard_config.md)
> - [🔌 Configuration VLANs pfSense](infra/network/pfsense_vlan_config.md)
> - [🌐 Configuration VMware (vmnet2)](infra/network/vmware_vmnet2_config.md)

---
## 🛠️ Stack Technique (Laboratoire)

| Catégorie | Outils | Statut |
|-----------|--------|--------|
| **Virtualisation** | VMware Workstation, Ubuntu Server | ✅ Opérationnel |
| **Firewall / Routing** | pfSense 2.7+ (VLANs, DHCP, NAT, Firewall) | ✅ Opérationnel |
| **Réseau** | 6 VLANs 802.1Q, adressage 10.20.0.0/16 | ✅ Opérationnel |
| **Containerisation** | Docker, docker-compose (room-booking) | ✅ PoC fonctionnel |
| **CI/CD** | GitHub Actions → Azure Container Registry | ✅ Workflow configuré |
| **Cloud (doc)** | Azure ACI, Container Instances | 📄 Documenté |
| **Gestion** | Git, GitHub, Trello, Draw.io | ✅ Actif |

---

## 🚀 Room Booking Service (Cloud PoC)

Service de démonstration pour le livrable *"Déploiement d'un service containerisé sur une plateforme Cloud"*.

### Architecture cible (Azure)

```
[GitHub] → [GitHub Actions] → [Azure ACR] → [Azure ACI] → [Utilisateurs]
```

### Démarrage local

```bash
cd cloud/room-booking
docker-compose up --build
curl http://localhost:8080
```

### Réponse attendue

```json
{
  "service": "room-booking",
  "version": "1.0.0",
  "status": "healthy",
  "project": "Smart Office 2.0 - B3 INYOV"
}
```

> 📄 **Détails:** Voir `cloud/room-booking/README.md`

---

## 🔗 Ressources

- [📚 Documentation pfSense](https://docs.netgate.com/pfsense/)
- [🐳 Docker Docs](https://docs.docker.com/)
- [☁️ Azure Container Instances](https://learn.microsoft.com/fr-fr/azure/container-instances/)

---

## 👥 Contribution

Ce projet suit une méthodologie Agile. Pour contribuer:

1. Créer une branche: `git checkout -b feature/nom-fonctionnalite`
2. Commiter les changements: `git commit -m 'feat: description claire'`
3. Pusher la branche: `git push origin feature/nom-fonctionnalite`
4. Ouvrir une Pull Request pour revue
