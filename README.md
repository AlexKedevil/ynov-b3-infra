# 🎓 Ynov B3 INFRA - Projet Smart Office

## 📋 Présentation du Projet

**Formation:** Ynov Informatique - Bachelor 3  
**UF:** INFRA - Infrastructure & Réseau  
**Sujet:** Smart Office  
**Équipe:** []  
**Période:** [] - []  

### 🎯 Contexte Pédagogique

Ce projet simule la conception d'une infrastructure IT pour une startup française en hyper-croissance qui emménage dans un nouveau siège de 4 étages.

**Objectif pédagogique:** Mobiliser les compétences acquises en:
- Architecture réseau (LAN/WLAN/VLAN/VPN)
- Sécurité (Zero Trust, Pare-feu, SIEM)
- Cloud hybride (On-Premise + AWS/Azure)
- DevOps (Containerisation, CI/CD)
- Gestion de projet agile (Scrum, documentation)


> 📊 **Accéder au Tableau de Bord :** [**b3-infra | Trello Board**](https://trello.com/b/EXl0H0QS/b3-infra)

---


---

## 📁 Structure du Dépôt

```text
ynov-b3-infra/
├── docs/                   # Documentation technique (en français)
│   ├── architecture/       # DAT, schémas, plan d'adressage IP/VLAN
│   ├── security/           # Politiques firewall, IAM, Zero Trust
│   ├── procedures/         # Guides d'installation et de maintenance
│   ├── pca_pra/            # Plans de continuité et reprise (PCA/PRA)
│   └── project_management/ # Backlog, sprints, suivi Kanban
├── infra/                  # Configurations infrastructure
│   ├── network/            # Configs pfSense, VLANs, scripts réseau
│   │   ├── pfsense_initial_setup.md
│   │   ├── pfsense_wizard_config.md
│   │   ├── pfsense_vlan_config.md
│   │   └── vmware_vmnet2_config.md
│   ├── servers/            # Scripts Bash, Ansible pour Ubuntu
│   ├── docker/             # Dockerfiles, docker-compose.yml
│   └── ansible/            # Playbooks d'automatisation
├── cloud/                  # Infrastructure Cloud
│   ├── aws/                # Scripts et configs AWS
│   └── terraform/          # Infrastructure as Code (optionnel)
├── monitoring/             # Supervision et SIEM
│   ├── grafana/            # Dashboards JSON
│   └── wazuh/              # Règles de détection
├── .gitignore
└── README.md
```

---

## 🗺️ Architecture Réseau

![Schéma Logique du Réseau](docs/architecture/screenshots/network_diagram.png)

> 🔗 **Documents de référence:**
> - [📜 Plan d'Adressage IP & Politique VLAN](docs/architecture/Plan_Adressage_IP_VLAN.md)
> - [🛠️ Configuration VLANs pfSense](infra/network/pfsense_vlan_config.md)

---
## 🛠️ Stack Technique (Laboratoire)

| Catégorie | Outils / Technologies |
|:---|:---|
| **Virtualisation** | VMware Workstation 25, GNS3 3.0.6 |
| **OS Serveur** | Ubuntu Server (CLI) |
| **Firewall** | pfSense 2.7+ |
| **Réseau** | VLANs, 802.1Q, DHCP, DNS, NAT, VPN |
| **Conteneurs** | Docker, Docker Compose |
| **Bases de données** | PostgreSQL 14+, MongoDB 6+ |
| **Monitoring** | Grafana, Prometheus, Wazuh (SIEM) |
| **Cloud** | AWS Free Tier (EC2, S3) ou Azure |
| **Gestion** | Git, GitHub, Trello, Draw.io |

---

## 🔗 Ressources & Liens Utiles

- [📚 Documentation pfSense](https://docs.netgate.com/pfsense/)

---

## 👥 Contribution & Collaboration

Ce projet suit une méthodologie Agile. Pour contribuer:

1. Créer une branche: `git checkout -b feature/nom-fonctionnalite`
2. Commiter les changements: `git commit -m 'feat: description claire'`
3. Pusher la branche: `git push origin feature/nom-fonctionnalite`
4. Ouvrir une Pull Request pour revue
