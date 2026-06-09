# Backlog et sprints — Méthodologie Agile

---

## Méthodologie

- **Framework :** Scrum / Kanban hybride
- **Outil :** [Trello — b3-infra](https://trello.com/b/EXl0H0QS/b3-infra)
- **Équipe :** Flaujat Sam, Queudeville Alexandre

---

## Structure du board Trello

| Colonne | Usage |
|---------|-------|
| Backlog | Évolutions hors scope PoC (VPN Azure, HA, SIEM avancé) |
| En cours | Soutenance / clôture (Juin 2026) |
| Fait | Livrables mergés (réseau, cloud, IAM, monitoring, docs) |

---

## Sprints

| Sprint | Période | Objectif | Livrables |
|--------|---------|----------|-----------|
| **Sprint 1** | Fév. – Mars 2026 | Architecture réseau on-prem | pfSense, 6 VLANs, VMware vmnet2, plan IP, captures firewall, schéma |
| **Sprint 2** | Mars – Avr. 2026 | PoC cloud + IAM | room-booking, PostgreSQL/Redis, Entra ID (code), docker-compose |
| **Sprint 3** | Avr. – Mai 2026 | Azure + CI/CD | ACR, ACI, GitHub Actions, fixes deploy (memory, ACR mirror) |
| **Sprint 4** | Mai – Juin 2026 | Supervision + docs | Grafana/Loki, syslog pfSense, DAT, BIA, PCA/PRA, Merise |
| **Sprint 5** | Juin 2026 | Clôture projet | Trello final, export Moodle, soutenance |

---

## User stories principales (Done)

| ID | Story | Critère d'acceptation |
|----|-------|----------------------|
| US-01 | Segmenter le réseau en VLANs | 6 VLANs, règles pfSense, captures |
| US-02 | Réserver une salle via API | CRUD rooms/bookings, cache Redis |
| US-03 | Déployer l'app sur Azure | ACI healthy, pipeline GitHub vert |
| US-04 | Authentifier via Entra ID | JWT + MSAL (démo AUTH_DISABLED si 401 tenant) |
| US-05 | Superviser les anomalies | Dashboard Grafana, logs pfSense + API |
| US-06 | Documenter l'architecture | DAT, PCA/PRA, Merise, TCO |

---

## Pull Requests GitHub (historique)

| PR | Thème |
|----|-------|
| #12 | Docs prep, README, skeleton `docs/` |
| #13 | room-booking app + PostgreSQL + Redis |
| #14 | Entra ID auth, Zero Trust docs |
| #15 | Azure ACI deploy + workflow |
| #16–#18 | Fixes workflow, ACI provider, ACR sidecar images |
| — | Monitoring stack (Grafana/Loki) |
| — | pfSense syslog → Loki |
| — | DAT / PCA / Merise / backup |

---

## Captures

| Fichier | Description |
|---------|-------------|
| [screenshots/trello_board_overview.png](screenshots/trello_board_overview.png) | Vue complète du board |
| [screenshots/trello_card_monitoring.png](screenshots/trello_card_monitoring.png) | Détail carte Monitoring |
