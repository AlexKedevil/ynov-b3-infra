# Documentation Smart Office 2.0 — Index des livrables

Portail de tous les documents requis par le sujet **UF_INFRA_B3** (Smart Office 2.0).

**Équipe :** Flaujat Sam, Queudeville Alexandre  
**Dépôt :** [github.com/AlexKedevil/ynov-b3-infra](https://github.com/AlexKedevil/ynov-b3-infra)

---

## Statut des livrables

| Livrable UF_INFRA_B3 | Fichier | Statut |
|----------------------|---------|--------|
| Dossier d'Architecture Technique (DAT) | [DAT.md](DAT.md) | Fait |
| Plan d'adressage IP / VLANs | [architecture/Plan_Adressage_IP_VLAN.md](architecture/Plan_Adressage_IP_VLAN.md) | Fait |
| Schémas architecture | [architecture/](architecture/) | Fait |
| Politiques de sécurité / Zero Trust / IAM | [security/](security/) | Fait |
| Stratégie stockage et sauvegarde | [DAT.md](DAT.md) §9 + [database/backup_restore.md](database/backup_restore.md) | Fait |
| Analyse des risques (BIA) | [pca_pra/BIA.md](pca_pra/BIA.md) | Fait |
| PCA / PRA | [pca_pra/PCA_PRA.md](pca_pra/PCA_PRA.md) | Fait |
| Modèle base de données (Merise/UML) | [database/MCD_Merise.md](database/MCD_Merise.md) | Fait |
| Sauvegarde / restauration BDD | [database/backup_restore.md](database/backup_restore.md) | Fait |
| Gestion des incidents (ITSM) | [project_management/ITSM.md](project_management/ITSM.md) | Fait |
| Backlog / sprints agile + Trello | [project_management/backlog_sprints.md](project_management/backlog_sprints.md) | Fait |
| PoC réseau (captures) | [architecture/screenshots/](architecture/screenshots/) | Fait |
| PoC cloud (room-booking) | [../cloud/room-booking/](../cloud/room-booking/) | Fait |
| PoC monitoring | [../monitoring/](../monitoring/) | Fait |
| Remise Moodle (18/06/2026) | [livrable/README.md](livrable/README.md) | À faire |

---

## Arborescence

```text
docs/
├── README.md                 # Ce fichier
├── DAT.md                    # Document d'architecture principal
├── architecture/             # Schémas, IP/VLAN, captures réseau
├── security/                 # Zero Trust, IAM Entra, firewall
├── database/                 # Merise, backup/restore
├── pca_pra/                  # BIA, continuité, reprise
├── project_management/       # ITSM, backlog, captures Trello
└── livrable/                 # Export PDF/ZIP pour Moodle
```

---

## Liens rapides

- [Procédures réseau on-premise](../infra/network/)
- [pfSense → Loki](../infra/network/pfsense_syslog_loki.md)
- [Service cloud room-booking](../cloud/room-booking/DETAILS.md)
- [Tableau Trello](https://trello.com/b/EXl0H0QS/b3-infra)
